"""
Wire protocol for arm commands crossing the subprocess boundary.

Student code runs in a QProcess and so cannot hold the serial port (the main
process does — see docs/specs/play_mode.md §4). Every arm call is therefore
written to stdout as one prefixed line, which the main process picks up and
applies to the board.

The \\x1e (ASCII record separator) prefix is what keeps a student's own print()
output from ever being mistaken for a command.

Commands carry *absolute* targets, never relative moves: the subprocess has
already validated the move against its mirror of the joint angles, so the main
process applies what it is told and never re-does the arithmetic.

No Qt imports here — this module is imported by the student's subprocess.
"""

import json

PREFIX = "\x1e@@ARM "

# Joint names on the wire.
YAW = "yaw"      # upper arm — rotates the whole arm left/right
PITCH = "pitch"  # lower arm — raises/lowers the elbow
GRIP = "grip"    # gripper — carries a bool, not an angle

JOINTS = (YAW, PITCH, GRIP)


def encode(joint: str, value: int | bool) -> str:
    """One command line, without its trailing newline."""
    return PREFIX + json.dumps({"j": joint, "v": value}, separators=(",", ":"))


def decode(line: str) -> tuple[str, int | bool] | None:
    """Parse a command line back to (joint, value), or None if it isn't one.

    Accepts a line with leading text: a student's `print(..., end="")` leaves
    stdout mid-line, so the next command can end up glued to the tail of their
    output. Callers split on PREFIX and pass the remainder here.
    """
    start = line.find(PREFIX)
    if start < 0:
        return None
    try:
        data = json.loads(line[start + len(PREFIX):])
        joint = str(data["j"])
        value = data["v"]
    except (json.JSONDecodeError, KeyError, TypeError):
        return None
    if joint not in JOINTS:
        return None
    return joint, value
