"""QML path helpers — locate the bundled .qml files at runtime."""

from pathlib import Path


def find_qml_root() -> Path:
    """Absolute path to the QML directory (works from source and installed)."""
    return Path(__file__).parent / "qml"


def main_qml_path() -> Path:
    """Absolute path to the MainWindow.qml entry point."""
    return find_qml_root() / "MainWindow.qml"
