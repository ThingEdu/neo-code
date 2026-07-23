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
import sys
from pathlib import Path

# Gripper is a servo like any other; these are the two positions it takes.
GRIP_CLOSED_ANGLE = 0
GRIP_OPEN_ANGLE = 60


def _telemetrix_class() -> type:
    """Return the `Telemetrix` class, preferring a real installation.

    A properly installed `thingbot-telemetrix` wins, so a newer one on the
    machine is not shadowed by the copy we bundle. Failing that, the bundled
    copy in `_vendor/` is put on `sys.path` under its own top-level name — it
    imports itself absolutely, so it cannot be imported as a submodule of
    `neo_code`. See `_vendor/README.md`.
    """
    try:
        from thingbot_telemetrix import Telemetrix
    except ModuleNotFoundError:
        vendor = Path(__file__).resolve().parents[2] / "_vendor"
        if not vendor.is_dir():
            raise
        if str(vendor) not in sys.path:
            sys.path.append(str(vendor))
        from thingbot_telemetrix import Telemetrix
    return Telemetrix


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
        # Resolved here, not at module scope: importing it is the slow, failure
        # -prone part, and a failure must degrade to MockBackend rather than
        # break app start.
        Telemetrix = _telemetrix_class()

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
