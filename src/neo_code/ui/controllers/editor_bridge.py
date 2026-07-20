"""
EditorBridge — attaches the Python syntax highlighter to a QML TextArea.

QML `TextArea` exposes its `QTextDocument` via `QQuickTextDocument`; we attach
the same `PythonHighlighter` used by the old QWidgets editor (validated by the
spike in docs/specs/spike/). The highlighter instance is held on the bridge so
it outlives `attach()`.
"""

from __future__ import annotations

import keyword
import re

from PyQt6.QtCore import QObject, pyqtSlot
from PyQt6.QtGui import QColor, QFont, QSyntaxHighlighter, QTextCharFormat, QTextDocument
from PyQt6.QtQuick import QQuickTextDocument

from neo_code.theme.colors import colors


class PythonHighlighter(QSyntaxHighlighter):
    """Lightweight Python syntax highlighter (ported from the QWidgets editor)."""

    def __init__(self, document: QTextDocument) -> None:
        super().__init__(document)
        self._rules: list[tuple[re.Pattern, QTextCharFormat]] = []
        self._build_rules()

    def _fmt(self, color: str, bold: bool = False, italic: bool = False) -> QTextCharFormat:
        fmt = QTextCharFormat()
        fmt.setForeground(QColor(color))
        if bold:
            fmt.setFontWeight(QFont.Weight.Bold)
        if italic:
            fmt.setFontItalic(True)
        return fmt

    def _build_rules(self) -> None:
        kw_fmt = self._fmt(colors.syn_keyword, bold=True)
        for kw in keyword.kwlist:
            self._rules.append((re.compile(rf"\b{kw}\b"), kw_fmt))

        builtin_fmt = self._fmt(colors.syn_builtin)
        builtins = ["print", "len", "range", "int", "str", "float", "list",
                    "dict", "set", "tuple", "bool", "type", "input", "open",
                    "enumerate", "zip", "map", "filter", "sorted", "abs", "round"]
        for b in builtins:
            self._rules.append((re.compile(rf"\b{b}\b"), builtin_fmt))

        str_fmt = self._fmt(colors.syn_string)
        self._rules.append((re.compile(r'"[^"\\]*(\\.[^"\\]*)*"'), str_fmt))
        self._rules.append((re.compile(r"'[^'\\]*(\\.[^'\\]*)*'"), str_fmt))

        self._rules.append((re.compile(r"\b\d+(\.\d+)?\b"), self._fmt(colors.syn_number)))
        self._rules.append((re.compile(r"@\w+"), self._fmt(colors.syn_decorator)))
        self._comment_fmt = self._fmt(colors.syn_comment, italic=True)

    def highlightBlock(self, text: str) -> None:
        for pattern, fmt in self._rules:
            for m in pattern.finditer(text):
                self.setFormat(m.start(), m.end() - m.start(), fmt)

        # Inline comment: first '#' not inside a string.
        in_str, str_char = False, ""
        for i, ch in enumerate(text):
            if in_str:
                if ch == str_char:
                    in_str = False
            elif ch in ('"', "'"):
                in_str, str_char = True, ch
            elif ch == "#":
                self.setFormat(i, len(text) - i, self._comment_fmt)
                break


class EditorBridge(QObject):
    """Owns the highlighter and attaches it to the QML editor's document."""

    def __init__(self) -> None:
        super().__init__()
        self._highlighter: PythonHighlighter | None = None  # must outlive attach()

    @pyqtSlot(QQuickTextDocument)
    def attach(self, quick_doc: QQuickTextDocument) -> None:
        if quick_doc is None:  # transient null during QML teardown
            return
        self._highlighter = PythonHighlighter(quick_doc.textDocument())
        self._highlighter.rehighlight()
