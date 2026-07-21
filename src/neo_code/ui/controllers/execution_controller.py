"""
ExecutionController — QML-facing façade over the execution event_bus signals.

QML calls `run(code)` / `stop()`; the already-registered `Runner` does the work.
Exposes a `running` property so the toolbar can enable/disable Run vs Stop.
"""

from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot

from neo_code.core.event_bus import event_bus


class ExecutionController(QObject):
    runningChanged = pyqtSignal()

    def __init__(self) -> None:
        super().__init__()
        self._running = False
        event_bus.execution_started.connect(self._on_started)
        event_bus.execution_finished.connect(self._on_finished)

    @pyqtProperty(bool, notify=runningChanged)
    def running(self) -> bool:
        return self._running

    def _on_started(self) -> None:
        self._running = True
        self.runningChanged.emit()

    def _on_finished(self, _exit_code: int) -> None:
        self._running = False
        self.runningChanged.emit()

    @pyqtSlot(str)
    def run(self, code: str) -> None:
        if not self._running:
            event_bus.execution_requested.emit(code)

    @pyqtSlot()
    def stop(self) -> None:
        event_bus.execution_stop_requested.emit()

    @pyqtSlot(str)
    def sendInput(self, text: str) -> None:
        """Answer a running program's input() prompt."""
        if self._running:
            event_bus.execution_input_submitted.emit(text)

    @pyqtSlot(bool)
    def setReplMode(self, active: bool) -> None:
        event_bus.repl_mode_changed.emit(active)
