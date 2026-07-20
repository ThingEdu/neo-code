"""
LessonsController — lesson catalog + live grading for QML.

Exposes the world/lesson tree (with per-lesson progress) as a plain list, and
grades the current lesson when execution finishes — reusing the Qt-clean
`evaluator` and `progress_store`. The main editor is where kids write code; this
controller watches the same execution signals the terminal does.
"""

from __future__ import annotations

from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot

from neo_code.core.event_bus import event_bus
from neo_code.features.lessons.evaluator import evaluate_lesson
from neo_code.features.lessons.loader import load_lesson_pack
from neo_code.features.lessons.progress_store import get_progress, record_attempt


class LessonsController(QObject):
    worldsChanged = pyqtSignal()
    lessonChanged = pyqtSignal("QVariant")        # detail dict, or None for list view
    feedbackChanged = pyqtSignal(str, str)        # message, state: none|running|success|fail
    progressChanged = pyqtSignal(str, int, int)   # lesson_id, stars, attempts

    def __init__(self) -> None:
        super().__init__()
        self._pack = load_lesson_pack()
        self._challenge: dict | None = None
        self._lesson_id: str | None = None
        self._stdout: list[str] = []
        self._stderr: list[str] = []

        event_bus.execution_started.connect(self._on_started)
        event_bus.execution_finished.connect(self._on_finished)
        event_bus.stdout_received.connect(lambda t: self._stdout.append(t))
        event_bus.stderr_received.connect(lambda t: self._stderr.append(t))

    @pyqtProperty("QVariant", notify=worldsChanged)
    def worlds(self) -> list:
        out = []
        for world in self._pack.get("worlds", []):
            lessons = []
            for lesson in world.get("lessons", []):
                p = get_progress(lesson["id"])
                lessons.append({
                    "id": lesson["id"],
                    "title": lesson.get("title", ""),
                    "stars": p.stars,
                    "attempts": p.attempts,
                    "completed": p.completed,
                })
            out.append({"id": world.get("id", ""), "title": world.get("title", ""), "lessons": lessons})
        return out

    @pyqtSlot(str)
    def selectLesson(self, lesson_id: str) -> None:
        for world in self._pack.get("worlds", []):
            for lesson in world.get("lessons", []):
                if lesson.get("id") == lesson_id:
                    self._challenge = lesson.get("challenge", {})
                    self._lesson_id = lesson_id
                    p = get_progress(lesson_id)
                    self.lessonChanged.emit({
                        "id": lesson_id,
                        "title": lesson.get("title", ""),
                        "goal": self._challenge.get("goal", ""),
                        "hint": self._challenge.get("hint", ""),
                        "starter_code": self._challenge.get("starter_code", ""),
                        "stars": p.stars,
                        "attempts": p.attempts,
                    })
                    self.feedbackChanged.emit(
                        "Viết code trong trình soạn thảo rồi bấm Chạy.", "none")
                    return

    @pyqtSlot()
    def back(self) -> None:
        self._challenge = None
        self._lesson_id = None
        self.lessonChanged.emit(None)

    # ── Grading (only while a lesson is open) ──────────────────────────────
    def _on_started(self) -> None:
        if self._challenge is None:
            return
        self._stdout = []
        self._stderr = []
        self.feedbackChanged.emit("Đang chạy…", "running")

    def _on_finished(self, exit_code: int) -> None:
        if self._challenge is None:
            return
        success, message = evaluate_lesson(
            self._challenge, "\n".join(self._stdout), "\n".join(self._stderr), exit_code)
        self.feedbackChanged.emit(message, "success" if success else "fail")
        if self._lesson_id:
            p = record_attempt(self._lesson_id, success)
            self.progressChanged.emit(self._lesson_id, p.stars, p.attempts)
            self.worldsChanged.emit()   # refresh stars in the list
