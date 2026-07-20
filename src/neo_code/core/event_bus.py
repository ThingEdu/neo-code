"""
EventBus — singleton QObject with typed Qt signals.

All inter-component communication goes through this object.
No component should call another component directly to trigger behaviour.

Usage:
    from neo_code.core.event_bus import event_bus

    # Connect
    event_bus.file_opened.connect(my_slot)

    # Emit
    event_bus.file_opened.emit(path, content)
"""

from PyQt6.QtCore import QObject, pyqtSignal


class EventBus(QObject):

    # ── File lifecycle ─────────────────────────────────────────────────────
    file_new = pyqtSignal()                     # new blank file requested
    file_opened = pyqtSignal(str, str)          # (path, content)
    file_saved = pyqtSignal(str)                # (path,)

    # ── Execution ──────────────────────────────────────────────────────────
    execution_requested = pyqtSignal(str)       # (code,)
    execution_stop_requested = pyqtSignal()
    execution_started = pyqtSignal()
    execution_finished = pyqtSignal(int)        # (exit_code,)
    repl_mode_changed = pyqtSignal(bool)        # True = REPL active, False = script mode

    # ── Subprocess output ──────────────────────────────────────────────────
    stdout_received = pyqtSignal(str)           # (text,)
    stderr_received = pyqtSignal(str)           # (text,)


# Module-level singleton — import this everywhere
event_bus = EventBus()
