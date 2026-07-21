"""
Neo Play design tokens — PyQt6 constants module.

Auto-derived from tokens/tokens.json. Import these instead of hardcoding
hex colors, px spacing, radii, or font specs anywhere in the app.

Usage:
    from theme_tokens import Color, Space, Radius, Type, Elevation
    widget.setStyleSheet(f"background-color: {Color.PRIMARY}; border-radius: {Radius.SM}px;")
"""

from dataclasses import dataclass
from PyQt6.QtGui import QColor, QFont
from PyQt6.QtWidgets import QGraphicsDropShadowEffect


class Color:
    """Hex color tokens. Wrap in QColor(...) where a QColor object is needed."""
    PRIMARY = "#02D962"
    ON_PRIMARY = "#FFFFFF"
    PRIMARY_CONTAINER = "#C6F7D8"
    ON_PRIMARY_CONTAINER = "#00210F"

    SECONDARY = "#2E77E7"
    ON_SECONDARY = "#FFFFFF"
    SECONDARY_CONTAINER = "#D6E7FF"
    ON_SECONDARY_CONTAINER = "#001C3B"

    TERTIARY = "#FE2151"
    ON_TERTIARY = "#FFFFFF"

    ERROR = "#B3261E"
    ON_ERROR = "#FFFFFF"

    SURFACE = "#FFFFFF"
    ON_SURFACE = "#1A1C1E"
    SURFACE_VARIANT = "#E1E2E8"
    OUTLINE = "#74777F"

    @staticmethod
    def q(hex_value: str) -> QColor:
        """Convenience: get a QColor from any hex token above."""
        return QColor(hex_value)


class Space:
    """Spacing scale in px (use directly as ints for margins/padding/spacing)."""
    XS = 4
    SM = 8
    MD = 16
    LG = 24
    XL = 32
    XXL = 48


class Radius:
    """Corner radius scale in px."""
    NONE = 0
    XS = 4
    SM = 8
    MD = 12
    LG = 16
    XL = 28
    FULL = 9999  # use min(width, height) / 2 in practice for pill/circular widgets


@dataclass
class TypeStyle:
    size: int
    line_height: int
    weight: int


class Type:
    """
    Typography scale. `size` maps to QFont.setPointSize/setPixelSize (use pixel size
    to match the design spec exactly); `weight` maps to QFont.Weight buckets below.
    """
    FONT_FAMILY = "Roboto"  # fallback handled by Qt font substitution if not installed

    DISPLAY_LARGE = TypeStyle(size=57, line_height=64, weight=400)
    DISPLAY_MEDIUM = TypeStyle(size=45, line_height=52, weight=400)
    HEADLINE_LARGE = TypeStyle(size=32, line_height=40, weight=400)
    HEADLINE_MEDIUM = TypeStyle(size=28, line_height=36, weight=400)
    TITLE_LARGE = TypeStyle(size=22, line_height=28, weight=500)
    TITLE_MEDIUM = TypeStyle(size=16, line_height=24, weight=500)
    TITLE_SMALL = TypeStyle(size=14, line_height=20, weight=500)
    BODY_LARGE = TypeStyle(size=16, line_height=24, weight=400)
    BODY_MEDIUM = TypeStyle(size=14, line_height=20, weight=400)
    BODY_SMALL = TypeStyle(size=12, line_height=16, weight=400)
    LABEL_LARGE = TypeStyle(size=14, line_height=20, weight=500)
    LABEL_MEDIUM = TypeStyle(size=12, line_height=16, weight=500)
    LABEL_SMALL = TypeStyle(size=11, line_height=16, weight=500)

    @staticmethod
    def qfont(style: TypeStyle) -> QFont:
        """Build a QFont from a TypeStyle. Weight 500+ maps to QFont.Weight.Medium/DemiBold."""
        font = QFont(Type.FONT_FAMILY)
        font.setPixelSize(style.size)
        if style.weight >= 700:
            font.setWeight(QFont.Weight.Bold)
        elif style.weight >= 500:
            font.setWeight(QFont.Weight.Medium)
        else:
            font.setWeight(QFont.Weight.Normal)
        return font


class Elevation:
    """
    Elevation levels. QSS has no real box-shadow support, so use
    QGraphicsDropShadowEffect on the widget instead (see `effect()` below).
    (blur_radius, x_offset, y_offset, alpha 0-255)
    """
    LEVELS = {
        0: (0, 0, 0, 0),
        1: (4, 0, 1, 20),
        2: (6, 0, 1, 30),
        3: (12, 0, 4, 36),
        4: (16, 0, 6, 40),
        5: (20, 0, 8, 46),
    }

    @staticmethod
    def effect(level: int) -> QGraphicsDropShadowEffect:
        """Return a configured QGraphicsDropShadowEffect for the given elevation level (0-5)."""
        blur, x, y, alpha = Elevation.LEVELS.get(level, Elevation.LEVELS[0])
        effect = QGraphicsDropShadowEffect()
        effect.setBlurRadius(blur)
        effect.setXOffset(x)
        effect.setYOffset(y)
        effect.setColor(QColor(0, 0, 0, alpha))
        return effect
