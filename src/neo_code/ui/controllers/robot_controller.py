"""
RobotController — mission catalog + board scan for QML.

Exposes the module/mission tree and a serial-port scan. There is no serial
protocol yet (matches the old feature): scanning just globs /dev/tty* via
`robot_connection.find_serial_ports`.
"""

from __future__ import annotations

from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot

from neo_code.features.robot.loader import load_robot_pack
from neo_code.features.robot.robot_connection import find_serial_ports


class RobotController(QObject):
    missionChanged = pyqtSignal("QVariant")   # detail dict, or None for list
    statusChanged = pyqtSignal(str)

    def __init__(self) -> None:
        super().__init__()
        self._pack = load_robot_pack()

    @pyqtProperty("QVariant", constant=True)
    def modules(self) -> list:
        return [
            {
                "id": m.get("id", ""),
                "title": m.get("title", ""),
                "missions": [
                    {"id": ms.get("id", ""), "title": ms.get("title", "")}
                    for ms in m.get("missions", [])
                ],
            }
            for m in self._pack.get("modules", [])
        ]

    @pyqtSlot(str)
    def selectMission(self, mission_id: str) -> None:
        for module in self._pack.get("modules", []):
            for mission in module.get("missions", []):
                if mission.get("id") == mission_id:
                    self.missionChanged.emit({
                        "id": mission_id,
                        "title": mission.get("title", ""),
                        "goal": mission.get("goal", ""),
                        "api_hint": mission.get("api_hint", ""),
                        "starter_code": mission.get("starter_code", ""),
                    })
                    return

    @pyqtSlot()
    def back(self) -> None:
        self.missionChanged.emit(None)

    @pyqtSlot()
    def scanPorts(self) -> None:
        ports = find_serial_ports()
        if ports:
            self.statusChanged.emit("Đã tìm thấy: " + ", ".join(ports))
        else:
            self.statusChanged.emit("Không tìm thấy board. Cắm board USB rồi thử lại.")
