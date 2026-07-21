#!/usr/bin/env python3
"""
Render the launcher PNGs from the master icon SVG.

The .deb ships pre-rendered PNGs (the build container has no rasteriser), so
they are committed. Re-run this whenever src/neo_code/resources/icons/neo-code.svg
changes:

    python3 scripts/render_icon.py

Uses Qt's own SVG renderer — the same one the app ships with — so what you see
here is what the target device draws.
"""

from __future__ import annotations

import sys
from pathlib import Path

from PyQt6.QtCore import QRectF, Qt
from PyQt6.QtGui import QGuiApplication, QImage, QPainter
from PyQt6.QtSvg import QSvgRenderer

REPO = Path(__file__).resolve().parent.parent
ICON_DIR = REPO / "src" / "neo_code" / "resources" / "icons"
MASTER = ICON_DIR / "neo-code.svg"
THEME_DIR = REPO / "packaging" / "icons" / "hicolor"

# freedesktop hicolor sizes — 16 through 512 covers panels, menus and settings.
SIZES = (16, 24, 32, 48, 64, 128, 256, 512)

# Shipped inside the Python package for QGuiApplication.setWindowIcon(). A PNG
# rather than the SVG so the runtime needs no Qt SVG image plugin.
RUNTIME_SIZE = 256


def main() -> int:
    if not MASTER.exists():
        print(f"ERROR: master artwork missing: {MASTER}", file=sys.stderr)
        return 1

    app = QGuiApplication(sys.argv)  # noqa: F841 — QImage/QPainter need an instance
    renderer = QSvgRenderer(str(MASTER))
    if not renderer.isValid():
        print(f"ERROR: could not parse {MASTER}", file=sys.stderr)
        return 1

    def rasterise(size: int) -> QImage:
        img = QImage(size, size, QImage.Format.Format_ARGB32)
        img.fill(Qt.GlobalColor.transparent)
        painter = QPainter(img)
        painter.setRenderHint(QPainter.RenderHint.Antialiasing)
        renderer.render(painter, QRectF(0, 0, size, size))
        painter.end()
        return img

    for size in SIZES:
        out_dir = THEME_DIR / f"{size}x{size}" / "apps"
        out_dir.mkdir(parents=True, exist_ok=True)
        out = out_dir / "neo-code.png"
        if not rasterise(size).save(str(out)):
            print(f"ERROR: failed to write {out}", file=sys.stderr)
            return 1
        print(f"  {out.relative_to(REPO)}")

    runtime = ICON_DIR / "neo-code.png"
    if not rasterise(RUNTIME_SIZE).save(str(runtime)):
        print(f"ERROR: failed to write {runtime}", file=sys.stderr)
        return 1
    print(f"  {runtime.relative_to(REPO)}")

    # The scalable copy is the master itself, so the theme stays in sync.
    scalable = THEME_DIR / "scalable" / "apps"
    scalable.mkdir(parents=True, exist_ok=True)
    (scalable / "neo-code.svg").write_bytes(MASTER.read_bytes())
    print(f"  {(scalable / 'neo-code.svg').relative_to(REPO)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
