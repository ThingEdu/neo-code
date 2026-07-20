"""
SettingsController — QML-facing accessor for persisted app settings.

Minimal for now (font size, tab width — what the editor needs); the settings
dialog in Phase 3 step 8 expands it. `word_wrap` is intentionally dropped:
the QML gutter assumes uniform line height (see docs/specs/qt6_migration.md).
"""

from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot

from neo_code.core.settings import Settings


class SettingsController(QObject):
    changed = pyqtSignal()

    def __init__(self) -> None:
        super().__init__()
        self._settings = Settings()

    @pyqtProperty(int, notify=changed)
    def fontSize(self) -> int:
        return self._settings.font_size

    @pyqtProperty(int, notify=changed)
    def tabWidth(self) -> int:
        return self._settings.tab_width

    @pyqtSlot(int)
    def setFontSize(self, value: int) -> None:
        value = max(8, min(32, value))
        if value != self._settings.font_size:
            self._settings.font_size = value
            self._settings.save()
            self.changed.emit()

    @pyqtSlot(int)
    def setTabWidth(self, value: int) -> None:
        value = max(2, min(8, value))
        if value != self._settings.tab_width:
            self._settings.tab_width = value
            self._settings.save()
            self.changed.emit()
