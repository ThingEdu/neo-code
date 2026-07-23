"""
ArmSession — owns the one connection to the arm, on its own thread.

Lives on a QThread (see PlayController) because building a TelemetrixBackend
blocks for several seconds while it scans serial ports. Everything reaches it
through queued signals, so the GUI never stalls on the board.

It holds the authoritative joint state for the *app* — the status pane reads
it. The running script holds its own mirror for validation; the two agree
because the script is the only writer while it runs
(docs/specs/play_mode.md §4).
"""

from __future__ import annotations

import sys

from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot

from neo_code.features.arm import protocol
from neo_code.features.arm.backends import (
    GRIP_CLOSED_ANGLE,
    GRIP_OPEN_ANGLE,
    MockBackend,
    TelemetrixBackend,
)
from neo_code.features.arm.student_api import HOME_PITCH, HOME_YAW

# status values mirrored to QML
DISCONNECTED = "disconnected"
CONNECTING = "connecting"
CONNECTED = "connected"
MOCK = "mock"


class ArmSession(QObject):
    # status, human-readable Vietnamese detail
    statusChanged = pyqtSignal(str, str)
    # yaw, pitch, gripper closed
    stateChanged = pyqtSignal(int, int, bool)
    # something went wrong applying a command, for the console
    failed = pyqtSignal(str)

    def __init__(self, servos: dict, com_port: str | None, force_mock: bool) -> None:
        super().__init__()
        self._servos = servos
        self._com_port = com_port
        self._force_mock = force_mock
        self._backend = None
        self._yaw = HOME_YAW
        self._pitch = HOME_PITCH
        self._grabbed = False

    # ── lifecycle ───────────────────────────────────────────────────────
    @pyqtSlot()
    def open(self) -> None:
        if self._backend is not None:
            return
        if self._force_mock:
            self._backend = MockBackend()
            self.statusChanged.emit(MOCK, "Chế độ mô phỏng")
        else:
            self.statusChanged.emit(CONNECTING, "Đang kết nối…")
            try:
                self._backend = TelemetrixBackend(self._com_port)
                self.statusChanged.emit(CONNECTED, "Đã kết nối")
            except Exception as exc:  # noqa: BLE001 — any failure means no board
                # Never block the mode on missing hardware: a kid with no robot
                # plugged in still gets to write and run code. The technical
                # reason goes to the log, not to a six-year-old's screen.
                print(f"neo-code: arm unavailable, using simulation ({exc!r})", file=sys.stderr)
                self._backend = MockBackend()
                self.statusChanged.emit(MOCK, "Chế độ mô phỏng")
        self._home()

    @pyqtSlot()
    def close(self) -> None:
        if self._backend is None:
            return
        self._backend.shutdown()
        self._backend = None
        self.statusChanged.emit(DISCONNECTED, "Chưa kết nối")

    # ── commands ────────────────────────────────────────────────────────
    @pyqtSlot(str)
    def apply(self, line: str) -> None:
        """Apply one decoded protocol line from the student's subprocess."""
        decoded = protocol.decode(line)
        if decoded is None or self._backend is None:
            return
        joint, value = decoded
        try:
            if joint == protocol.GRIP:
                self._grabbed = bool(value)
                angle = GRIP_CLOSED_ANGLE if self._grabbed else GRIP_OPEN_ANGLE
                self._backend.set_servo(self._servos["grip"], angle)
            else:
                angle = max(0, min(180, int(value)))
                self._backend.set_servo(self._servos[joint], angle)
                if joint == protocol.YAW:
                    self._yaw = angle
                else:
                    self._pitch = angle
        except Exception as exc:  # noqa: BLE001 — a dead board must not kill the app
            self.failed.emit(f"Lỗi cánh tay: {exc}")
            return
        self.stateChanged.emit(self._yaw, self._pitch, self._grabbed)

    def _home(self) -> None:
        self.apply(protocol.encode(protocol.YAW, HOME_YAW))
        self.apply(protocol.encode(protocol.PITCH, HOME_PITCH))
        self.apply(protocol.encode(protocol.GRIP, False))
