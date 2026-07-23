"""
NEO Code — PyQt6 + QML bootstrap.

Constructs the QML engine, exposes the theme and controller/bridge objects to
QML via context properties, and loads MainWindow.qml.
"""

from __future__ import annotations

import sys

from PyQt6.QtGui import QFont, QFontDatabase, QGuiApplication, QIcon
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtCore import QUrl

from neo_code.theme.design import (
    APP_ICON_PATH, MDI, MDI_FONT_FAMILY, MDI_FONT_PATH,
    MONO_FONT_PATH, UI_FONT_FAMILY, UI_FONT_PATH,
    build_theme,
)
from neo_code.ui.bridge import SignalBusBridge
from neo_code.ui.controllers.editor_bridge import EditorBridge
from neo_code.ui.controllers.execution_controller import ExecutionController
from neo_code.ui.controllers.file_controller import FileController
from neo_code.ui.controllers.lessons_controller import LessonsController
from neo_code.ui.controllers.play_controller import PlayController
from neo_code.ui.controllers.repl_controller import ReplController
from neo_code.ui.controllers.settings_controller import SettingsController
from neo_code.ui.qml_loader import main_qml_path


class NeoCodeApp:
    """Owns the QGuiApplication, the QML engine, and the Python-side objects."""

    def __init__(self, argv: list[str]) -> None:
        self._app = QGuiApplication(argv)
        self._app.setApplicationName("NEO Code")
        self._app.setOrganizationName("ThingEdu")
        # Matches the .desktop file's themed icon name, so Wayland compositors
        # pair the window with the launcher entry.
        self._app.setDesktopFileName("neo-code")
        self._app.setWindowIcon(QIcon(str(APP_ICON_PATH)))

        QFontDatabase.addApplicationFont(str(MDI_FONT_PATH))
        QFontDatabase.addApplicationFont(str(UI_FONT_PATH))
        QFontDatabase.addApplicationFont(str(MONO_FONT_PATH))
        # Default UI font for every QML Label/Text unless overridden.
        self._app.setFont(QFont(UI_FONT_FAMILY, 10))

        # Runner self-registers on the event bus.
        from neo_code.execution.runner import Runner
        self._runner = Runner()

        # Objects exposed to QML. Kept as attributes so they outlive load().
        self._bridge = SignalBusBridge()
        self._execution = ExecutionController()
        self._files = FileController()
        self._editor = EditorBridge()
        self._settings = SettingsController()
        self._repl = ReplController()
        self._lessons = LessonsController()
        self._play = PlayController()
        # A leaked serial connection stays in telemetrix's port register and
        # blocks the next one, so the arm is released on the way out.
        self._app.aboutToQuit.connect(self._play.shutdown)

        self._engine = QQmlApplicationEngine()
        ctx = self._engine.rootContext()
        # Palette + spacing + radius → a JS object in QML: Theme.primary, Theme.space_md, etc.
        ctx.setContextProperty("Theme", build_theme())
        ctx.setContextProperty("Mdi", MDI)                 # Mdi.play, Mdi.cog, …
        ctx.setContextProperty("mdiFont", MDI_FONT_FAMILY)
        ctx.setContextProperty("signalBus", self._bridge)
        ctx.setContextProperty("execution", self._execution)
        ctx.setContextProperty("files", self._files)
        ctx.setContextProperty("editorBridge", self._editor)
        ctx.setContextProperty("settings", self._settings)
        ctx.setContextProperty("replController", self._repl)
        ctx.setContextProperty("lessonsController", self._lessons)
        ctx.setContextProperty("playController", self._play)

        self._engine.load(QUrl.fromLocalFile(str(main_qml_path())))
        if not self._engine.rootObjects():
            raise RuntimeError("Failed to load MainWindow.qml")

    def exec(self) -> int:
        return self._app.exec()
