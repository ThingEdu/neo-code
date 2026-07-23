"""
child_env — the environment handed to student subprocesses.

Shared by the script runner and the REPL, which need the same three things and
would otherwise drift: UTF-8, an importable `neo_code`, and (in Chơi mode) the
arm's current pose.

The pose is tracked here rather than passed in because both consumers need it
and neither owns it — one listener on the bus feeds both.
"""

from __future__ import annotations

from pathlib import Path

from PyQt6.QtCore import QProcessEnvironment

import neo_code
from neo_code.core.event_bus import event_bus
from neo_code.features.arm.student_api import HOME_PITCH, HOME_YAW

# Where `import neo_code` has to resolve from inside the child. Installed
# normally this is already on the child's path, but a bare source checkout run
# via `python -m neo_code` relies on cwd, which the child does not inherit.
_PACKAGE_PARENT = str(Path(neo_code.__file__).resolve().parent.parent)

_arm_state: dict = {"yaw": HOME_YAW, "pitch": HOME_PITCH, "grabbed": False}


def _on_arm_state(yaw: int, pitch: int, grabbed: bool) -> None:
    _arm_state.update(yaw=yaw, pitch=pitch, grabbed=grabbed)


event_bus.arm_state_changed.connect(_on_arm_state)


def build(mode: str = "plain") -> QProcessEnvironment:
    """Environment for a child process running in *mode* ("plain" or "arm")."""
    env = QProcessEnvironment.systemEnvironment()
    env.insert("PYTHONIOENCODING", "utf-8")
    env.insert("PYTHONUTF8", "1")

    existing = env.value("PYTHONPATH", "")
    env.insert(
        "PYTHONPATH",
        f"{_PACKAGE_PARENT}:{existing}" if existing else _PACKAGE_PARENT,
    )

    if mode == "arm":
        # Seeds the subprocess's mirror of the joint angles, so a program picks
        # up from where the arm actually is rather than assuming it is homed.
        env.insert("NEO_ARM_YAW", str(_arm_state["yaw"]))
        env.insert("NEO_ARM_PITCH", str(_arm_state["pitch"]))
        env.insert("NEO_ARM_GRIP", "1" if _arm_state["grabbed"] else "0")

    return env
