"""
PlayController — QML-facing façade over the arm session, plus the activity data.

Owns the worker thread ArmSession lives on. Building a real connection blocks
for seconds while telemetrix scans serial ports, so nothing arm-related runs on
the GUI thread; the controller and the session only ever exchange queued
signals.

The connection is opened lazily on first entry to Chơi mode rather than at app
start — a kid who never opens the mode never waits for a port scan.
"""

from __future__ import annotations

from PyQt6.QtCore import QObject, QThread, pyqtProperty, pyqtSignal, pyqtSlot

from neo_code.core.event_bus import event_bus
from neo_code.core.settings import Settings
from neo_code.features.arm import session as arm_session
from neo_code.features.arm.session import ArmSession
from neo_code.features.arm.student_api import HOME_PITCH, HOME_YAW
from neo_code.features.play.loader import load_activity


class PlayController(QObject):
    stateChanged = pyqtSignal()
    statusChanged = pyqtSignal()

    _openRequested = pyqtSignal()
    _closeRequested = pyqtSignal()
    _commandRequested = pyqtSignal(str)

    def __init__(self) -> None:
        super().__init__()
        settings = Settings()
        self._activity = load_activity("open-arm")

        self._status = arm_session.DISCONNECTED
        self._statusDetail = "Chưa kết nối"
        self._yaw = HOME_YAW
        self._pitch = HOME_PITCH
        self._grabbed = False

        self._thread = QThread()
        self._session = ArmSession(
            servos=settings.arm_servos,
            com_port=settings.arm_port,
            force_mock=settings.arm_mock,
        )
        self._session.moveToThread(self._thread)

        self._openRequested.connect(self._session.open)
        self._closeRequested.connect(self._session.close)
        self._commandRequested.connect(self._session.apply)
        self._session.statusChanged.connect(self._on_status)
        self._session.stateChanged.connect(self._on_state)
        self._session.failed.connect(event_bus.stderr_received)

        # Commands arrive from whichever subprocess is running — the script
        # runner via output_parser, or the REPL controller.
        event_bus.arm_command.connect(self._commandRequested)

        self._thread.start()

    # ── properties ──────────────────────────────────────────────────────
    @pyqtProperty(str, notify=statusChanged)
    def status(self) -> str:
        return self._status

    @pyqtProperty(str, notify=statusChanged)
    def statusDetail(self) -> str:
        return self._statusDetail

    @pyqtProperty(bool, notify=statusChanged)
    def ready(self) -> bool:
        """True once commands will actually go somewhere — mock counts."""
        return self._status in (arm_session.CONNECTED, arm_session.MOCK)

    @pyqtProperty(int, notify=stateChanged)
    def yaw(self) -> int:
        return self._yaw

    @pyqtProperty(int, notify=stateChanged)
    def pitch(self) -> int:
        return self._pitch

    @pyqtProperty(bool, notify=stateChanged)
    def grabbed(self) -> bool:
        return self._grabbed

    @pyqtProperty("QVariant", constant=True)
    def activity(self):
        return self._activity

    # ── slots ───────────────────────────────────────────────────────────
    @pyqtSlot()
    def open(self) -> None:
        """Connect on first entry to Chơi mode; a no-op once connected."""
        self._openRequested.emit()

    @pyqtSlot()
    def shutdown(self) -> None:
        """Release the board and stop the worker thread.

        A leaked connection stays in telemetrix's port register and blocks the
        next one, so this runs on app quit, not only on leaving the mode.
        """
        self._closeRequested.emit()
        self._thread.quit()
        self._thread.wait(2000)

    # ── session callbacks ───────────────────────────────────────────────
    def _on_status(self, status: str, detail: str) -> None:
        self._status = status
        self._statusDetail = detail
        self.statusChanged.emit()

    def _on_state(self, yaw: int, pitch: int, grabbed: bool) -> None:
        self._yaw = yaw
        self._pitch = pitch
        self._grabbed = grabbed
        self.stateChanged.emit()
        # Lets the next program's mirror start from where the arm really is.
        event_bus.arm_state_changed.emit(yaw, pitch, grabbed)
