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
    # mode is "plain" or "arm"; "arm" runs the script through play_bootstrap so
    # Chơi code gets an `arm` object (see execution/runner.py).
    execution_requested = pyqtSignal(str, str)  # (code, mode)
    execution_stop_requested = pyqtSignal()
    execution_started = pyqtSignal()
    execution_finished = pyqtSignal(int)        # (exit_code,)
    execution_input_submitted = pyqtSignal(str)  # (line,) — typed answer for input()
    repl_mode_changed = pyqtSignal(bool, str)   # (active, mode) — mode as above

    # ── Robotic arm (Chơi mode) ────────────────────────────────────────────
    # One protocol line from the student's subprocess, for ArmSession to apply.
    arm_command = pyqtSignal(str)               # (line,)
    # Applied state, so the runner can seed the next program's mirror.
    arm_state_changed = pyqtSignal(int, int, bool)  # (yaw, pitch, grabbed)

    # ── Subprocess output ──────────────────────────────────────────────────
    stdout_received = pyqtSignal(str)           # (text,) — one complete line
    # The current line has no newline yet — typically an input() prompt. Carries
    # the whole unterminated line each time, so consumers replace rather than
    # append.
    stdout_partial = pyqtSignal(str)            # (text,)
    stderr_received = pyqtSignal(str)           # (text,)


# Module-level singleton — import this everywhere
event_bus = EventBus()
