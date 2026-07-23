"""
ReplController — a live `python3 -i` console for QML.

Owns the QProcess and does the ANSI/prompt filtering (ported from the old
QWidgets repl_panel.py); QML renders the emitted lines. Starts/stops with REPL
mode (driven by `event_bus.repl_mode_changed`).

In Chơi mode the session also gets an `arm` object. `python -i` cannot take
`-m`, so the script path's play_bootstrap trick doesn't apply — PYTHONSTARTUP
is the hook meant for this. That puts arm commands on the same stdout the kid's
output comes back on, so this controller has to split them out; hence the line
buffer, which a chunk-at-a-time reader would otherwise not need.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

from PyQt6.QtCore import QObject, QProcess, pyqtSignal, pyqtSlot

from neo_code.core.event_bus import event_bus
from neo_code.execution import child_env
from neo_code.features.arm import protocol

_ARM_STARTUP = Path(__file__).resolve().parent.parent.parent / "execution" / "arm_startup.py"

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
        self._out_buf = ""          # stdout received but not yet a whole line
        event_bus.repl_mode_changed.connect(self._on_mode_changed)

    def _on_mode_changed(self, active: bool, mode: str) -> None:
        self.start(mode) if active else self.stop()

    # ── Lifecycle ──────────────────────────────────────────────────────────
    @pyqtSlot(str)
    def start(self, mode: str = "plain") -> None:
        if self._process and self._process.state() != QProcess.ProcessState.NotRunning:
            return
        self._process = QProcess(self)
        self._process.setProcessChannelMode(QProcess.ProcessChannelMode.SeparateChannels)
        env = child_env.build(mode)
        if mode == "arm":
            env.insert("PYTHONSTARTUP", str(_ARM_STARTUP))
        self._process.setProcessEnvironment(env)
        self._process.readyReadStandardOutput.connect(self._on_stdout)
        self._process.readyReadStandardError.connect(self._on_stderr)
        self._process.finished.connect(self._on_finished)
        self._out_buf = ""
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
        self._out_buf = ""

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
        if not text:
            return

        self._out_buf += text
        while "\n" in self._out_buf:
            line, self._out_buf = self._out_buf.split("\n", 1)
            self._route(line)

        # Whatever is left is an unterminated line. Emit it now unless it could
        # still be a half-written arm command — holding *all* tails back would
        # swallow a plain `print(..., end="")`, which used to show immediately.
        if self._out_buf and protocol.PREFIX[0] not in self._out_buf:
            self._route(self._out_buf)
            self._out_buf = ""

    def _route(self, line: str) -> None:
        """Send one line to the console, or divert it to the arm."""
        start = line.find(protocol.PREFIX)
        if start < 0:
            if line.strip():
                self.output.emit(line, "out")
            return
        head = line[:start]
        if head.strip():
            self.output.emit(head, "out")
        event_bus.arm_command.emit(line[start:])

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
