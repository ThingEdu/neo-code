"""
Lesson curriculum loader — pure data access, no Qt.

Reads from resources/curriculums/: a single topics.json manifest, plus one
<topic_id>/<order>.<lesson_id>.json per lesson. Loading is two-tier on
purpose — listing topics only touches the one small manifest; a topic's
lessons are read only once that topic is selected — so opening the app never
loads curriculum content the student hasn't navigated to yet.
"""

import json
from dataclasses import dataclass, field
from pathlib import Path

CURRICULUMS_ROOT = Path(__file__).parent.parent.parent / "resources" / "curriculums"


@dataclass
class Topic:
    id: str
    title: str
    order: int
    icon: str = "puzzle"


@dataclass
class Lesson:
    id: str
    title: str
    goal: str
    instruction: str
    expected: str
    order: int
    starter: str = ""
    hints: list = field(default_factory=list)
    blocks: list = field(default_factory=list)


def _read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def list_topics(root: Path = CURRICULUMS_ROOT) -> list[Topic]:
    """Every topic's metadata only — never opens a lesson file."""
    manifest = root / "topics.json"
    if not manifest.is_file():
        return []
    topics = [
        Topic(
            id=data["id"],
            title=data["title"],
            order=int(data.get("order", 0)),
            icon=data.get("icon", "puzzle"),
        )
        for data in _read_json(manifest)
    ]
    topics.sort(key=lambda t: t.order)
    return topics


def load_topic(topic_id: str, root: Path = CURRICULUMS_ROOT) -> list[Lesson]:
    """All lessons for one topic, sorted by their filename's order prefix."""
    topic_dir = root / topic_id
    if not topic_dir.is_dir():
        return []
    lessons = []
    for lesson_file in topic_dir.glob("*.json"):
        order = int(lesson_file.name.split(".", 1)[0])
        data = _read_json(lesson_file)
        lessons.append(Lesson(
            id=data["id"],
            title=data["title"],
            goal=data["goal"],
            instruction=data["instruction"],
            expected=data["expected"],
            order=order,
            starter=data.get("starter", ""),
            hints=data.get("hints", []),
            blocks=data.get("blocks", []),
        ))
    lessons.sort(key=lambda l: l.order)
    return lessons
