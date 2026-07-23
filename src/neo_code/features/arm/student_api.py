"""
`arm` — the object student code drives in Chơi mode.

Runs inside the student's subprocess, so it never touches the serial port: each
call validates the move, updates a local mirror of the joint angles, and writes
one protocol line for the main process to apply.

The mirror is authoritative because the running script (or REPL session) is the
only writer — nothing else moves the arm while it runs. It is seeded from the
NEO_ARM_* environment variables so a program picks up where the last one left
off rather than assuming the arm is homed.

Error messages are Vietnamese and reach the kid as an ordinary traceback in the
console, with the line number matching what they see in the editor.

No Qt imports here — this module is imported by the student's subprocess.
"""

from __future__ import annotations

import os
import sys
import time

from neo_code.features.arm import protocol

MIN_ANGLE = 0
MAX_ANGLE = 180

# Home pose, and the fallback when the environment carries nothing usable.
HOME_YAW = 90
HOME_PITCH = 90


def _env_angle(name: str, fallback: int) -> int:
    try:
        return max(MIN_ANGLE, min(MAX_ANGLE, int(os.environ[name])))
    except (KeyError, ValueError):
        return fallback


class StudentArmAPI:
    """Flat, beginner-friendly facade injected as ``arm``."""

    def __init__(self) -> None:
        self._yaw = _env_angle("NEO_ARM_YAW", HOME_YAW)
        self._pitch = _env_angle("NEO_ARM_PITCH", HOME_PITCH)
        self._grabbed = os.environ.get("NEO_ARM_GRIP") == "1"

    # ── wire ────────────────────────────────────────────────────────────
    def _send(self, joint: str, value: int | bool) -> None:
        # Written straight to the stream rather than via print(), which a
        # student is free to rebind.
        sys.stdout.write(protocol.encode(joint, value) + "\n")
        sys.stdout.flush()

    @staticmethod
    def _check_step(angle: int) -> int:
        angle = int(angle)
        if angle < MIN_ANGLE or angle > MAX_ANGLE:
            raise ValueError("Góc phải nằm trong khoảng 0 đến 180")
        return angle

    # ── xoay (yaw — upper arm) ──────────────────────────────────────────
    def turn_left(self, angle: int = 90) -> None:
        """Xoay cánh tay sang trái *angle* độ."""
        angle = self._check_step(angle)
        if self._yaw - angle < MIN_ANGLE:
            raise ValueError(f"Chỉ có thể xoay trái {self._yaw} độ")
        self.set_yaw(self._yaw - angle)

    def turn_right(self, angle: int = 90) -> None:
        """Xoay cánh tay sang phải *angle* độ."""
        angle = self._check_step(angle)
        if self._yaw + angle > MAX_ANGLE:
            raise ValueError(f"Chỉ có thể xoay phải {MAX_ANGLE - self._yaw} độ")
        self.set_yaw(self._yaw + angle)

    def set_yaw(self, angle: int) -> None:
        """Đặt góc xoay của cánh tay (0 đến 180)."""
        angle = self._check_step(angle)
        self._yaw = angle
        self._send(protocol.YAW, angle)

    # ── nâng hạ (pitch — lower arm) ─────────────────────────────────────
    def lift_up(self, angle: int = 90) -> None:
        """Nâng cánh tay lên *angle* độ."""
        angle = self._check_step(angle)
        if self._pitch - angle < MIN_ANGLE:
            raise ValueError(f"Chỉ có thể nâng lên {self._pitch} độ")
        self.set_pitch(self._pitch - angle)

    def lower_down(self, angle: int = 90) -> None:
        """Hạ cánh tay xuống *angle* độ."""
        angle = self._check_step(angle)
        if self._pitch + angle > MAX_ANGLE:
            raise ValueError(f"Chỉ có thể hạ xuống {MAX_ANGLE - self._pitch} độ")
        self.set_pitch(self._pitch + angle)

    def set_pitch(self, angle: int) -> None:
        """Đặt góc nâng hạ của cánh tay (0 đến 180)."""
        angle = self._check_step(angle)
        self._pitch = angle
        self._send(protocol.PITCH, angle)

    # ── kẹp (gripper) ───────────────────────────────────────────────────
    def grab(self) -> None:
        """Kẹp vật lại."""
        self._grabbed = True
        self._send(protocol.GRIP, True)

    def release(self) -> None:
        """Thả vật ra."""
        self._grabbed = False
        self._send(protocol.GRIP, False)

    # ── thời gian ───────────────────────────────────────────────────────
    def delay(self, seconds: float) -> None:
        """Dừng lại *seconds* giây (có thể là số lẻ, ví dụ 0.5)."""
        time.sleep(float(seconds))

    # ── đọc trạng thái ──────────────────────────────────────────────────
    @property
    def yaw(self) -> int:
        """Góc xoay hiện tại."""
        return self._yaw

    @property
    def pitch(self) -> int:
        """Góc nâng hạ hiện tại."""
        return self._pitch

    @property
    def is_grabbed(self) -> bool:
        """True khi kẹp đang giữ vật."""
        return self._grabbed
