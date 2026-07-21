# PyQt6 Adapter

PyQt6's QSS (Qt Style Sheets) is CSS-like but **does not support** CSS custom
properties (`var(--x)`) or `box-shadow`. So this adapter splits the tokens
into two files that must be kept in sync:

- **`theme_tokens.py`** — Python constants (`Color`, `Space`, `Radius`, `Type`,
  `Elevation`) for anything you set in code (fonts, drop-shadow effects,
  layout margins/spacing, dynamic colors).
- **`theme.qss`** — a literal QSS stylesheet (hardcoded hex/px values, each
  commented with its source token) for styling via `setObjectName()` +
  `setStyleSheet()`.

## Usage

```python
from PyQt6.QtWidgets import QApplication, QPushButton
from theme_tokens import Color, Type, Elevation

app = QApplication([])
with open("theme.qss") as f:
    app.setStyleSheet(f.read())

btn = QPushButton("Save")
btn.setObjectName("PrimaryButton")   # picks up QSS rule from theme.qss
btn.setGraphicsEffect(Elevation.effect(1))  # real drop shadow, since QSS can't do it
```

## Notes / limitations

- **Shadows/elevation**: QSS has no real shadow support. Use
  `Elevation.effect(level)` from `theme_tokens.py`, which returns a configured
  `QGraphicsDropShadowEffect` — apply it with `widget.setGraphicsEffect(...)`.
- **Pill radius**: `Radius.FULL` (9999) isn't literally usable as a QSS
  `border-radius` — for a true pill/circular widget, set
  `border-radius: {height // 2}px` dynamically in code instead.
- **Hover/pressed color shades**: QSS can't derive tints from a base color, so
  hover/pressed variants in `theme.qss` are pre-computed literal hex values
  (slightly darker than the base token). If the brand color changes, regenerate
  these manually or via a small script using `QColor.darker()`.
- Keep `theme_tokens.py` and `theme.qss` in sync manually — if `tokens/tokens.json`
  in the parent package changes, update both files to match.
