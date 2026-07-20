"""
FileController — QML-facing file operations backed by core.FileManager.

QML owns the native FileDialog (QtQuick.Dialogs); this controller does the I/O
and reports the current path + starting folder for the dialog.
"""

from pathlib import Path

from PyQt6.QtCore import QObject, QUrl, pyqtSignal, pyqtProperty, pyqtSlot

from neo_code.core.file_manager import FileManager
from neo_code.core.settings import Settings


class FileController(QObject):
    currentPathChanged = pyqtSignal()

    def __init__(self) -> None:
        super().__init__()
        self._files = FileManager()
        self._settings = Settings()

    @pyqtProperty(str, notify=currentPathChanged)
    def currentPath(self) -> str:
        return str(self._files.current_path) if self._files.has_file else ""

    @pyqtProperty(bool, notify=currentPathChanged)
    def hasFile(self) -> bool:
        return self._files.has_file

    @pyqtProperty(QUrl, constant=True)
    def lastOpenFolder(self) -> QUrl:
        return QUrl.fromLocalFile(self._settings.last_open_dir)

    @pyqtSlot()
    def newFile(self) -> None:
        self._files.new_file()
        self.currentPathChanged.emit()

    @pyqtSlot(QUrl)
    def openFile(self, url: QUrl) -> None:
        path = url.toLocalFile()
        if not path:
            return
        self._files.open_file(path)
        self._remember_dir(path)
        self.currentPathChanged.emit()

    @pyqtSlot(str)
    def save(self, content: str) -> bool:
        """Save to the current file. Returns False if there is no path yet."""
        if not self._files.has_file:
            return False
        self._files.save_file(content)
        self.currentPathChanged.emit()
        return True

    @pyqtSlot(QUrl, str)
    def saveAs(self, url: QUrl, content: str) -> None:
        path = url.toLocalFile()
        if not path:
            return
        self._files.save_file(content, path)
        self._remember_dir(path)
        self.currentPathChanged.emit()

    def _remember_dir(self, path: str) -> None:
        self._settings.last_open_dir = str(Path(path).parent)
        self._settings.save()
