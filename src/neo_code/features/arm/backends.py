"""
Arm backends — the two things that can be on the other end of a servo write.

Deliberately thinner than neo-robot's Arm/Hand/RobotArm hierarchy. Those
classes existed to hold joint state and range-check moves; both of those now
live in `student_api`, where an out-of-range move raises where the kid can see
it. What is left on this side is one method: put servo N at angle A.

`MockBackend` is what runs when no board is connected, which is what makes the
whole mode developable and screenshot-verifiable without hardware.
"""

from __future__ import annotations

import contextlib
import io

# Gripper is a servo like any other; these are the two positions it takes.
GRIP_CLOSED_ANGLE = 0
GRIP_OPEN_ANGLE = 60


class MockBackend:
    """Simulated board — accepts writes and remembers nothing else."""

    name = "mock"

    def set_servo(self, servo: int, angle: int) -> None:
        pass

    def shutdown(self) -> None:
        pass


class TelemetrixBackend:
    """Real ThingBot board over `thingbot-telemetrix`.

    Constructing this is slow (serial discovery sleeps several seconds and
    polls) and chatty on stdout, so it is only ever built on ArmSession's
    worker thread, with stdout captured.
    """

    name = "hardware"

    def __init__(self, com_port: str | None = None) -> None:
        # Imported here, not at module scope: the package is optional, and a
        # missing one must degrade to MockBackend rather than break app start.
        from thingbot_telemetrix import Telemetrix

        # Telemetrix prints its port-scanning progress; that is diagnostics for
        # a CLI tool, not something to leak into a GUI app's own stdout.
        sink = io.StringIO()
        with contextlib.redirect_stdout(sink):
            self._board = Telemetrix(com_port=com_port) if com_port else Telemetrix()
        self._thingbot = self._board.thingbot()

    def set_servo(self, servo: int, angle: int) -> None:
        self._thingbot.control_servo(servo, angle)

    def shutdown(self) -> None:
        # A leaked connection stays in telemetrix's port register and blocks
        # the next one, so failures here are swallowed rather than propagated.
        with contextlib.suppress(Exception):
            self._board.shutdown()
