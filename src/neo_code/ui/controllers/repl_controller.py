"""
ReplController — a live `python3 -i` console for QML.

Owns the QProcess and does the ANSI/prompt filtering (ported from the old
QWidgets repl_panel.py); QML renders the emitted lines. Starts/stops with REPL
mode (driven by `event_bus.repl_mode_changed`).
"""

from __future__ import annotations

import re
import sys

from PyQt6.QtCore import QObject, QProcess, QProcessEnvironment, pyqtSignal, pyqtSlot

from neo_code.core.event_bus import event_bus

# Strip ANSI CSI/OSC sequences and readline bracket markers that `python -i`
# emits via stderr.
_CTRL_RE = re.compile(
    r"\x1b\[[0-?]*[ -/]*[@-~]"   # CSI
    r"|\x1b\][^\x07\x1b]*\x07"   # OSC ... BEL
    r"|\x1b\][^\x1b]*\x1b\\"     # OSC ... ST
    r"|\x1b[@-Z\\-_]"            # Fe
    r"|[\x01\x02\x07\x0f\x0e]"   # SOH, STX, BEL, SI, SO
)

# `python -i` writes prompts + banner to stderr — drop them; tracebacks pass through.
_STDERR_SKIP_STARTSWITH = (
    "Python ", "[GCC ", "[Clang ", 'Type "help"', 'Type "copyright"',
)


class ReplController(QObject):
    # kind ∈ {"echo", "out", "err", "info"}
    output = pyqtSignal(str, str)
    cleared = pyqtSignal()

    def __init__(self) -> None:
        super().__init__()
        self._process: QProcess | None = None
        event_bus.repl_mode_changed.connect(self._on_mode_changed)

    def _on_mode_changed(self, active: bool) -> None:
        self.start() if active else self.stop()

    # ── Lifecycle ──────────────────────────────────────────────────────────
    @pyqtSlot()
    def start(self) -> None:
        if self._process and self._process.state() != QProcess.ProcessState.NotRunning:
            return
        self._process = QProcess(self)
        self._process.setProcessChannelMode(QProcess.ProcessChannelMode.SeparateChannels)
        env = QProcessEnvironment.systemEnvironment()
        env.insert("PYTHONIOENCODING", "utf-8")
        env.insert("PYTHONUTF8", "1")
        self._process.setProcessEnvironment(env)
        self._process.readyReadStandardOutput.connect(self._on_stdout)
        self._process.readyReadStandardError.connect(self._on_stderr)
        self._process.finished.connect(self._on_finished)
        self.cleared.emit()
        self._process.start(sys.executable, ["-X", "utf8", "-u", "-i"])

    @pyqtSlot()
    def stop(self) -> None:
        if self._process is None:
            return
        if self._process.state() != QProcess.ProcessState.NotRunning:
            self._process.kill()
            self._process.waitForFinished(500)
        self._process = None

    # ── I/O ────────────────────────────────────────────────────────────────
    @pyqtSlot(str)
    def submit(self, text: str) -> None:
        self.output.emit(">>> " + text, "echo")
        if self._process and self._process.state() == QProcess.ProcessState.Running:
            self._process.write((text + "\n").encode())

    @pyqtSlot()
    def _on_stdout(self) -> None:
        if self._process is None:
            return
        text = _CTRL_RE.sub("", self._process.readAllStandardOutput().data().decode(errors="replace"))
        if text.strip():
            self.output.emit(text.rstrip("\n"), "out")

    @pyqtSlot()
    def _on_stderr(self) -> None:
        if self._process is None:
            return
        text = _CTRL_RE.sub("", self._process.readAllStandardError().data().decode(errors="replace"))
        filtered = self._filter_stderr(text)
        if filtered:
            self.output.emit(filtered, "err")

    @classmethod
    def _filter_stderr(cls, text: str) -> str:
        kept = []
        for line in text.splitlines():
            s = line.strip()
            if s in (">>>", "...", ">>> ", "... "):
                continue
            if any(s.startswith(p) for p in _STDERR_SKIP_STARTSWITH):
                continue
            kept.append(line)
        return "\n".join(kept)

    @pyqtSlot(int, QProcess.ExitStatus)
    def _on_finished(self, _code: int, _status) -> None:
        self.output.emit("[Phiên tương tác đã kết thúc]", "info")
