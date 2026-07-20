"""
SignalBusBridge — re-emits `event_bus` signals as QML-friendly QObject signals.

`event_bus` stays the internal source of truth (components emit/connect to it as
before). QML can only bind to signals on an object exposed via a context
property, so this bridge forwards the subset QML needs. Pattern mirrors
`neo-stopmotion/app.py`.
"""

from PyQt6.QtCore import QObject, pyqtSignal

from neo_code.core.event_bus import event_bus


class SignalBusBridge(QObject):
    # ── Execution ──────────────────────────────────────────────────────────
    executionStarted = pyqtSignal()
    executionFinished = pyqtSignal(int)          # exit_code
    replModeChanged = pyqtSignal(bool)           # True = REPL active

    # ── Subprocess output ──────────────────────────────────────────────────
    stdoutReceived = pyqtSignal(str)
    stderrReceived = pyqtSignal(str)

    # ── File lifecycle ─────────────────────────────────────────────────────
    fileNew = pyqtSignal()
    fileOpened = pyqtSignal(str, str)            # path, content
    fileSaved = pyqtSignal(str)                  # path

    def __init__(self) -> None:
        super().__init__()
        event_bus.execution_started.connect(self.executionStarted)
        event_bus.execution_finished.connect(self.executionFinished)
        event_bus.repl_mode_changed.connect(self.replModeChanged)
        event_bus.stdout_received.connect(self.stdoutReceived)
        event_bus.stderr_received.connect(self.stderrReceived)
        event_bus.file_new.connect(self.fileNew)
        event_bus.file_opened.connect(self.fileOpened)
        event_bus.file_saved.connect(self.fileSaved)
