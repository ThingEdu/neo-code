"""
Color palette for NEO Code — Neo Play (ThingEdu) standard, FRIENDLY LIGHT.

Direction: Grasshopper / Scratch — a bright, warm, encouraging kids-coding look.
Soft cool-white canvas, white cards, one vibrant green accent, gentle contrast.

Brand anchors:
  Primary   #02D962  ThingEdu Green   — the single accent (CTA, active, progress)
  Secondary #2E77E7  ThingEdge Blue   — secondary/interactive semantic
  Tertiary  #FE2151  Rogo Red         — destructive/alert only
  Canvas    #F7F9FC  Soft cool white

Depth via layered light surfaces + hairline borders (no heavy shadows on ARM).
Reference `colors` anywhere; in QML use `Theme.<token>` (never hardcode hex).
"""

from dataclasses import dataclass


@dataclass(frozen=True)
class _Palette:
    # ── Brand ──────────────────────────────────────────────────────────────
    primary:          str = "#02D962"   # ThingEdu green — the accent
    primary_hover:    str = "#05C459"   # slightly deeper on hover
    primary_dim:      str = "#A7EDC6"   # light green — disabled fill
    primary_soft:     str = "#E8FBF0"   # light green tint — selected / badges
    primary_text:     str = "#05231A"   # DARK text on bright green (AA contrast)

    secondary:        str = "#2E77E7"   # ThingEdge blue
    secondary_hover:  str = "#2361C4"
    secondary_text:   str = "#FFFFFF"

    tertiary:         str = "#FE2151"   # Rogo red
    tertiary_hover:   str = "#D91742"
    tertiary_text:    str = "#FFFFFF"

    # ── Surfaces (elevation: canvas → surface_2 → surface/panel) ───────────
    background:       str = "#F7F9FC"   # soft cool-white canvas
    panel_bg:         str = "#FFFFFF"   # sidebars, toolbar
    surface:          str = "#FFFFFF"   # cards, trays
    surface_2:        str = "#F2F5FA"   # recessed wells, code blocks
    surface_alt:      str = "#EDF1F7"   # hover / pressed row
    border:           str = "#E7ECF3"   # whisper hairline
    border_strong:    str = "#D5DCE6"

    # ── Text family ────────────────────────────────────────────────────────
    text:             str = "#1E2233"   # ink
    text_secondary:   str = "#6B7280"
    text_disabled:    str = "#AAB1BF"

    # ── Editor / console ───────────────────────────────────────────────────
    editor_bg:        str = "#FFFFFF"
    editor_text:      str = "#1E2233"
    editor_line_hl:   str = "#F1FAF4"   # current-line highlight (soft green)
    editor_selection: str = "#C8EFD9"   # selection (light green)

    terminal_bg:      str = "#FBFCFE"   # light console
    terminal_text:    str = "#2A2F3E"
    terminal_error:   str = "#E11D48"
    terminal_success: str = "#059646"

    # ── Syntax highlighting (readable on white) ────────────────────────────
    syn_keyword:      str = "#0A9D4C"   # keywords  — green
    syn_builtin:      str = "#2563EB"   # builtins  — blue
    syn_string:       str = "#C2410C"   # strings   — orange
    syn_number:       str = "#7C3AED"   # numbers   — purple
    syn_comment:      str = "#9AA3B2"   # comments  — grey
    syn_decorator:    str = "#D97706"   # decorators— amber

    # ── Activity bar (white rail, green-soft selection) ────────────────────
    activity_bar_bg:      str = "#FFFFFF"
    activity_bar_active:  str = "#02D962"
    activity_bar_icon:    str = "#8A92A3"
    activity_bar_icon_hl: str = "#1E2233"

    # ── Content panel ──────────────────────────────────────────────────────
    panel_header_bg:  str = "#FFFFFF"
    panel_header_text: str = "#6B7280"

    # ── Toolbar ────────────────────────────────────────────────────────────
    toolbar_bg:       str = "#FFFFFF"
    toolbar_border:   str = "#E7ECF3"

    # ── Run / Stop buttons ─────────────────────────────────────────────────
    run_bg:           str = "#02D962"
    run_bg_hover:     str = "#05C459"
    run_text:         str = "#05231A"   # dark on green (AA)
    stop_bg:          str = "#FE2151"
    stop_bg_hover:    str = "#D91742"
    stop_text:        str = "#FFFFFF"


# Module-level singleton — import this everywhere
colors = _Palette()
