"""
Design tokens — Neo Play design standard (spacing, radius, icons).

Exposed to QML alongside the palette as the `Theme` context object, plus the
Material Design Icons glyph map (`Mdi`) and font family. Spacing follows
Android's 4dp grid; radius follows the nesting rule inner = outer − padding.
"""

from dataclasses import asdict
from pathlib import Path

from neo_code.theme.colors import colors

# ── Spacing (4px grid) ─────────────────────────────────────────────────────
SPACING = {
    "space_xs": 4,     # icon-to-text gaps, tight inline
    "space_sm": 8,     # compact padding, chip spacing
    "space_md": 12,    # standard internal padding (small components)
    "space_base": 16,  # default card / button / list-item padding
    "space_lg": 24,    # section spacing, screen-edge margins
    "space_xl": 32,    # major section breaks
}

# ── Corner radius (inner = outer − padding) ────────────────────────────────
RADIUS = {
    "radius_chip": 10,    # buttons, chips, list rows
    "radius_card": 16,    # cards
    "radius_lg": 20,      # trays / large containers
    "radius_inner": 8,    # content block inside a 16px-padded card
    "radius_pill": 999,   # pill controls (steppers)
}

# ── Typography ─────────────────────────────────────────────────────────────
UI_FONT_FAMILY = "Nunito"          # friendly, rounded, highly readable
MONO_FONT_FAMILY = "JetBrains Mono"  # code editor / terminal / REPL
UI_FONT_PATH = Path(__file__).parent.parent / "resources" / "fonts" / "Nunito.ttf"
MONO_FONT_PATH = Path(__file__).parent.parent / "resources" / "fonts" / "JetBrainsMono.ttf"

TYPE = {
    "font_family": UI_FONT_FAMILY,
    "mono_family": MONO_FONT_FAMILY,
    "font_caption": 11,   # metadata, group labels
    "font_body": 13,      # body, list items
    "font_title": 15,     # card / section titles (semibold)
    "font_heading": 18,   # panel headings (bold)
}

# ── Sizing (kid touch targets ≥ 40px) ──────────────────────────────────────
SIZING = {
    "control_sm": 32,
    "control_base": 40,
    "control_lg": 48,
    "row_height": 38,
    "icon_size": 18,
}

# ── Material Design Icons ──────────────────────────────────────────────────
MDI_FONT_FAMILY = "Material Design Icons"
MDI_FONT_PATH = Path(__file__).parent.parent / "resources" / "fonts" / "materialdesignicons-webfont.ttf"

# name → codepoint (from @mdi/font 7.4). Add here as new icons are used.
_MDI_CODEPOINTS = {
    "book_open": 0xF14F7,        # book-open-variant  → home: "Học" mode
    "arrow_left": 0xF004D,       # arrow-left         → back to home
    "play": 0xF040A,            # play               → run
    "stop": 0xF04DB,            # stop               → stop
    "console": 0xF07B7,          # console-line       → REPL
    "cog": 0xF08BB,             # cog-outline        → settings
    "file_plus": 0xF0EED,        # file-plus-outline  → new
    "folder_open": 0xF0DCF,      # folder-open-outline→ open
    "save": 0xF0818,            # content-save-outline→ save
    "minus": 0xF0374,           # minus              → stepper down
    "plus": 0xF0415,            # plus               → stepper up
    "format_size": 0xF027F,      # format-size        → font size setting
    "keyboard_tab": 0xF0312,     # keyboard-tab       → tab width setting
    "close": 0xF0156,           # close              → dialog close
    "broom": 0xF00E2,           # broom              → clear console
    "code_tags": 0xF0174,        # code-tags          → console header
    "python": 0xF0320,          # language-python    → REPL header
    "chevron_right": 0xF0142,    # chevron-right      → REPL send / prompt
    "chevron_left": 0xF0141,     # chevron-left       → collapse sidebar
    "target": 0xF04FE,          # target             → expected-output pane, challenge card
    "circle_outline": 0xF0766,   # circle-outline     → lesson not started
    "check_filled": 0xF05E0,     # check-circle       → lesson completed
    "puzzle": 0xF0A66,          # puzzle-outline     → code block palette
    "lightbulb": 0xF06E9,        # lightbulb-on-outline→ hint panel
    "lock": 0xF033E,            # lock-outline       → locked lesson node
}

# name → glyph character, for the `Mdi` context object (Mdi.play, …)
MDI = {name: chr(cp) for name, cp in _MDI_CODEPOINTS.items()}


def build_theme() -> dict:
    """Palette + spacing + radius + type + sizing, merged for the QML `Theme` object."""
    return {**asdict(colors), **SPACING, **RADIUS, **TYPE, **SIZING}
