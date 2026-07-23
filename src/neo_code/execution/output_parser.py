"""
output_parser — reads stdout lines from the subprocess and forwards them.

Most lines are ordinary program output. Chơi-mode arm commands share the same
stream, tagged with a control-character prefix (features/arm/protocol.py); they
are diverted to `arm_command` and never shown to the kid — the same mechanism
this module was originally built around for the removed turtle feature.
"""

from neo_code.core.event_bus import event_bus
from neo_code.features.arm import protocol


def parse_line(line: str) -> None:
    """Called for each line of subprocess stdout."""
    line = line.rstrip("\n")
    start = line.find(protocol.PREFIX)
    if start < 0:
        event_bus.stdout_received.emit(line)
        return

    # A student's `print(..., end="")` leaves stdout mid-line, so a command can
    # arrive glued to the tail of their own output. Everything before the
    # prefix is theirs and still belongs on the console.
    head = line[:start]
    if head:
        event_bus.stdout_received.emit(head)
    event_bus.arm_command.emit(line[start:])
