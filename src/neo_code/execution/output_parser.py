"""
output_parser — reads stdout lines from the subprocess and forwards them.

Every line is emitted as stdout_received. (Historically JSON `{"cmd": …}` lines
were diverted to a `canvas_command` signal for the removed turtle feature; that
path is gone, so student output containing JSON is no longer swallowed.)
"""

from neo_code.core.event_bus import event_bus


def parse_line(line: str) -> None:
    """Called for each line of subprocess stdout."""
    event_bus.stdout_received.emit(line.rstrip("\n"))
