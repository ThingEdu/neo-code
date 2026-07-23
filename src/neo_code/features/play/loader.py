"""
Chơi activity loader — pure data access, no Qt.

Reads resources/play/<id>.json. Same shape as the curriculum loader, minus
everything lesson-shaped: an activity has an instruction and an API reference,
but no goal, hints or expected output — Chơi is a sandbox, not a challenge.
"""

import json
from pathlib import Path

from neo_code.features.arm.student_api import StudentArmAPI

PLAY_ROOT = Path(__file__).parent.parent.parent / "resources" / "play"


def load_activity(activity_id: str, root: Path = PLAY_ROOT) -> dict:
    """One activity, as the plain dict QML binds to."""
    path = root / f"{activity_id}.json"
    if not path.is_file():
        return {"id": activity_id, "title": "", "instruction": "", "api": []}

    data = json.loads(path.read_text(encoding="utf-8"))
    data["api"] = [
        group for group in data.get("api", [])
        if _keep_group(group)
    ]
    return data


def _keep_group(group: dict) -> bool:
    """Drop any entry the student API doesn't actually provide.

    The manifest documents methods that live in student_api.py. Left unchecked
    the two drift, and a kid taps a chip that inserts a call raising
    AttributeError — the one error the panel itself caused.
    """
    entries = [e for e in group.get("entries", []) if hasattr(StudentArmAPI, e.get("method", ""))]
    group["entries"] = entries
    return bool(entries)
