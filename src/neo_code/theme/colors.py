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

    tertiary:         str = "#FE2151"   # Rogo red — brand accent only, never destructive/error
    tertiary_hover:   str = "#D91742"
    tertiary_text:    str = "#FFFFFF"

    error:            str = "#B3261E"   # M3 error red — errors/destructive actions only
    error_hover:      str = "#96201A"
    error_text:       str = "#FFFFFF"

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

    # ── Editor / console — both dark "device" panels, deliberately two
    # different shades (editor: soft dark slate-blue, console: neutral
    # charcoal) so they read as distinct surfaces rather than one block. ────
    editor_bg:        str = "#1A1D29"   # soft dark slate-blue — editor body
    editor_bg_alt:    str = "#20242F"   # editor header / gutter chrome
    editor_text:      str = "#DCE0EA"
    editor_line_hl:   str = "#242838"   # current-line highlight (subtle lighten)
    editor_selection: str = "#173C2C"   # selection (dark desaturated green)

    # Console (Terminal + REPL) — VS Code Dark+ pairing, a neutral charcoal
    # distinct from the editor's slate-blue so output reads as its own device.
    terminal_bg:            str = "#1E1E1E"   # console body
    terminal_bg_alt:        str = "#252526"   # console header / input bar
    terminal_well_bg:       str = "#3C3C3C"   # REPL input recessed well
    terminal_border:        str = "#3C3C3C"   # hairlines on dark
    terminal_text:          str = "#D4D4D4"
    terminal_text_secondary: str = "#9D9D9D"  # header label, info lines
    terminal_text_disabled: str = "#6A6A6A"   # placeholder
    terminal_error:         str = "#F14C4C"   # bright enough to read on dark
    terminal_success:       str = "#89D185"

    # ── Syntax highlighting (readable on the dark editor) ──────────────────
    syn_keyword:      str = "#4FD98A"   # keywords  — green
    syn_builtin:      str = "#63A4FF"   # builtins  — blue
    syn_string:       str = "#F2A65A"   # strings   — orange
    syn_number:       str = "#B48EFF"   # numbers   — purple
    syn_comment:      str = "#7C8494"   # comments  — grey
    syn_decorator:    str = "#FFC078"   # decorators— amber

    # ── Content panel ──────────────────────────────────────────────────────
    panel_header_bg:  str = "#FFFFFF"
    panel_header_text: str = "#6B7280"

    # ── Toolbar ────────────────────────────────────────────────────────────
    toolbar_bg:       str = "#FFFFFF"
    toolbar_border:   str = "#E7ECF3"

    # ── Run button (on-primary text) ────────────────────────────────────────
    run_text:         str = "#05231A"   # dark on green (AA)


# Module-level singleton — import this everywhere
colors = _Palette()
