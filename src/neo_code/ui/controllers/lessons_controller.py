"""
LessonsController — QML-facing façade over features.lessons.loader.

Drives the three-level Học-mode sidebar (topics -> lesson path -> challenge
detail) as an explicit `view` state machine, so LessonSidebar.qml never has
to infer which screen to show from nullability. No grading/progress here yet
— nodes only distinguish "current" (open right now) from "available"; that
lands once an evaluator exists to earn "completed".
"""

from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot

from neo_code.features.lessons.loader import list_topics, load_topic


class LessonsController(QObject):
    viewChanged = pyqtSignal()
    topicsChanged = pyqtSignal()
    nodesChanged = pyqtSignal()
    challengeChanged = pyqtSignal()
    topicTitleChanged = pyqtSignal()
    lessonOpened = pyqtSignal(str)  # starter code, for the editor to seed

    def __init__(self) -> None:
        super().__init__()
        self._topics = list_topics()
        self._view = "topics"
        self._current_topic_id: str | None = None
        self._lessons: list = []
        self._current_lesson_id: str | None = None

    # ── properties ──────────────────────────────────────────────────────
    @pyqtProperty(str, notify=viewChanged)
    def view(self) -> str:
        return self._view

    @pyqtProperty("QVariant", notify=topicsChanged)
    def topics(self):
        return [{"id": t.id, "title": t.title, "icon": t.icon} for t in self._topics]

    @pyqtProperty(str, notify=topicTitleChanged)
    def topicTitle(self) -> str:
        topic = self._current_topic()
        return topic.title if topic else ""

    @pyqtProperty("QVariant", notify=nodesChanged)
    def nodes(self):
        return [
            {
                "id": lesson.id,
                "title": lesson.title,
                "state": "current" if lesson.id == self._current_lesson_id else "available",
            }
            for lesson in self._lessons
        ]

    @pyqtProperty("QVariant", notify=challengeChanged)
    def currentChallenge(self):
        lesson = self._current_lesson()
        if lesson is None:
            return None
        return {
            "title": lesson.title,
            "goal": lesson.goal,
            "instruction": lesson.instruction,
            "hints": lesson.hints,
            "blocks": lesson.blocks,
            "expected": lesson.expected,
        }

    # ── slots ───────────────────────────────────────────────────────────
    @pyqtSlot(str)
    def selectTopic(self, topic_id: str) -> None:
        self._current_topic_id = topic_id
        self._lessons = load_topic(topic_id)
        self._current_lesson_id = None
        self._view = "path"
        self.topicTitleChanged.emit()
        self.nodesChanged.emit()
        self.viewChanged.emit()

    @pyqtSlot(str)
    def selectLesson(self, lesson_id: str) -> None:
        self._current_lesson_id = lesson_id
        self._view = "challenge"
        self.nodesChanged.emit()
        self.challengeChanged.emit()
        self.viewChanged.emit()
        lesson = self._current_lesson()
        self.lessonOpened.emit(lesson.starter if lesson else "")

    @pyqtSlot()
    def back(self) -> None:
        if self._view == "challenge":
            self._current_lesson_id = None
            self._view = "path"
            self.nodesChanged.emit()
            self.challengeChanged.emit()
        elif self._view == "path":
            self._current_topic_id = None
            self._lessons = []
            self._view = "topics"
            self.nodesChanged.emit()
            self.topicTitleChanged.emit()
        self.viewChanged.emit()

    # ── helpers ─────────────────────────────────────────────────────────
    def _current_topic(self):
        return next((t for t in self._topics if t.id == self._current_topic_id), None)

    def _current_lesson(self):
        return next((l for l in self._lessons if l.id == self._current_lesson_id), None)
