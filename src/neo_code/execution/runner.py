"""
runner — executes student code in an isolated QProcess.

Uses QProcess so stdout/stderr callbacks arrive on the Qt event loop —
no manual threading or GLib.idle_add() needed.

Listens to:
  event_bus.execution_requested       (code: str, mode: str)
  event_bus.execution_stop_requested
  event_bus.execution_input_submitted (line: str)  — written to the child's stdin

Emits:
  event_bus.execution_started
  event_bus.execution_finished   (exit_code: int)
  event_bus.stdout_received      (text: str)      — one complete line, via output_parser
  event_bus.stdout_partial       (text: str)      — unterminated line, i.e. an input() prompt
  event_bus.stderr_received      (text: str)

Two modes. "plain" runs the student's file directly; "arm" (Chơi) runs it
through play_bootstrap, which injects `arm` without touching the file, so
traceback line numbers still match the editor.
"""

import sys
import os
from pathlib import Path

from PyQt6.QtCore import QObject, QProcess, QTimer, pyqtSlot

from neo_code.core.event_bus import event_bus
from neo_code.execution.proxy_injector import prepare_script
from neo_code.execution import child_env, output_parser
from neo_code.features.arm import protocol

# Cap on time the script spends *running*. The clock pauses while the script is
# blocked on input() — otherwise a child typing an answer gets killed mid-word.
# It does not pause for a program that keeps producing output, so runaway loops
# are still caught.
_TIMEOUT_MS = 30_000

# Quiet period before an unterminated line is treated as a prompt and shown.
# Output arrives in arbitrary chunks, so a line mid-write must not be mistaken
# for a program waiting on stdin.
_PARTIAL_FLUSH_MS = 60


class Runner(QObject):
    def __init__(self) -> None:
        super().__init__()
        self._process: QProcess | None = None
        self._tmp_script: Path | None = None
        self._out_buf = ""            # stdout received but not yet a whole line
        self._timeout_remaining = _TIMEOUT_MS

        self._timeout_timer = QTimer(self)
        self._timeout_timer.setSingleShot(True)
        self._timeout_timer.timeout.connect(self._on_timeout)

        # Debounces the unterminated tail of stdout into a prompt.
        self._flush_timer = QTimer(self)
        self._flush_timer.setSingleShot(True)
        self._flush_timer.setInterval(_PARTIAL_FLUSH_MS)
        self._flush_timer.timeout.connect(self._flush_partial)

        event_bus.execution_requested.connect(self._on_execution_requested)
        event_bus.execution_stop_requested.connect(self._on_stop_requested)
        event_bus.execution_input_submitted.connect(self._on_input_submitted)

    # ── Slots ─────────────────────────────────────────────────────────────────

    @pyqtSlot(str, str)
    def _on_execution_requested(self, code: str, mode: str) -> None:
        if self._process and self._process.state() != QProcess.ProcessState.NotRunning:
            return  # already running

        self._tmp_script = prepare_script(code)
        self._out_buf = ""

        self._process = QProcess(self)
        self._process.setProcessChannelMode(QProcess.ProcessChannelMode.SeparateChannels)
        self._process.setProcessEnvironment(child_env.build(mode))
        self._process.readyReadStandardOutput.connect(self._on_stdout)
        self._process.readyReadStandardError.connect(self._on_stderr)
        self._process.finished.connect(self._on_finished)

        args = ["-X", "utf8", "-u"]
        if mode == "arm":
            args += ["-m", "neo_code.execution.play_bootstrap"]
        args.append(str(self._tmp_script))

        event_bus.execution_started.emit()
        self._process.start(sys.executable, args)

        self._timeout_remaining = _TIMEOUT_MS
        self._timeout_timer.start(_TIMEOUT_MS)

    @pyqtSlot()
    def _on_stop_requested(self) -> None:
        self._kill_process()

    @pyqtSlot(str)
    def _on_input_submitted(self, text: str) -> None:
        """Send a typed line to the running script's stdin."""
        if self._process is None or self._process.state() != QProcess.ProcessState.Running:
            return
        # input() takes the newline off stdin, never off stdout, so the prompt
        # would otherwise sit in our buffer forever and get glued to whatever
        # the script prints next. The console has already merged the prompt and
        # the answer into one finished line, so drop it here.
        self._out_buf = ""
        self._flush_timer.stop()
        self._resume_timeout()
        self._process.write((text + "\n").encode("utf-8"))

    # ── Process callbacks ─────────────────────────────────────────────────────

    @pyqtSlot()
    def _on_stdout(self) -> None:
        if self._process is None:
            return
        data = bytes(self._process.readAllStandardOutput()).decode("utf-8", errors="replace")
        if not data:
            return
        # Producing output means it is working, not waiting on the child.
        self._resume_timeout()

        # Chunks split anywhere, including mid-line, so buffer until a newline.
        self._out_buf += data
        while "\n" in self._out_buf:
            line, self._out_buf = self._out_buf.split("\n", 1)
            output_parser.parse_line(line)

        if self._out_buf:
            self._flush_timer.start()
        else:
            self._flush_timer.stop()

    def _flush_partial(self) -> None:
        """Nothing more arrived — show the unterminated line as a prompt."""
        if self._process is None or not self._out_buf:
            return
        # A half-written arm command is not a prompt; showing it would flash
        # protocol noise at the kid. Its newline is always right behind it.
        if protocol.PREFIX in self._out_buf:
            return
        event_bus.stdout_partial.emit(self._out_buf)
        # It has stopped producing output mid-line; assume it is blocked on
        # input() and stop charging it for the time the child spends typing.
        self._pause_timeout()

    @pyqtSlot()
    def _on_stderr(self) -> None:
        if self._process is None:
            return
        data = bytes(self._process.readAllStandardError()).decode("utf-8", errors="replace")
        self._resume_timeout()
        for line in data.splitlines():
            event_bus.stderr_received.emit(line)

    @pyqtSlot(int, QProcess.ExitStatus)  # noqa: enum ref resolves under PyQt6
    def _on_finished(self, exit_code: int, _status) -> None:
        # A final print(..., end="") leaves text with no newline; emit it rather
        # than dropping it on the floor.
        if self._out_buf:
            output_parser.parse_line(self._out_buf)
            self._out_buf = ""
        self._cleanup()
        event_bus.execution_finished.emit(exit_code)

    def _on_timeout(self) -> None:
        event_bus.stderr_received.emit("⏱  Execution timed out (30s limit).")
        self._kill_process()

    # ── Timeout bookkeeping ───────────────────────────────────────────────────

    def _pause_timeout(self) -> None:
        if self._timeout_timer.isActive():
            self._timeout_remaining = max(self._timeout_timer.remainingTime(), 1000)
            self._timeout_timer.stop()

    def _resume_timeout(self) -> None:
        if not self._timeout_timer.isActive():
            self._timeout_timer.start(self._timeout_remaining)

    # ── Helpers ───────────────────────────────────────────────────────────────

    def _kill_process(self) -> None:
        if self._process and self._process.state() != QProcess.ProcessState.NotRunning:
            self._process.kill()
            self._process.waitForFinished(1000)

    def _cleanup(self) -> None:
        self._timeout_timer.stop()
        self._flush_timer.stop()
        self._out_buf = ""
        if self._tmp_script and self._tmp_script.exists():
            try:
                os.unlink(self._tmp_script)
            except OSError:
                pass
        self._tmp_script = None
        self._process = None
