# NEO Code — Design System

Single source of truth for the NEO Code UI. Every QML component must follow this
standard and the Neo Play (ThingEdu) branding. Synthesized from the
`.agents/skills/high-end-visual-design` and `stitch-design-taste` taste guides,
constrained by the audience.

## 1. Visual theme & atmosphere

**Friendly Light, for kids** (ref: Grasshopper / Scratch / Mimo). A bright, warm
soft-white canvas with white cards on hairline borders and one vibrant green
accent. Built for students aged 6–12: **large touch targets, gentle contrast,
generous breathing room, predictable layout, encouraging.** Motion is minimal and
physical — a gentle press response, never decorative. Depth reads through *layered
light surfaces* (canvas `#F7F9FC` → white cards) + whisper borders, never heavy
shadows or blur (ARM-friendly). Consoles are **integrated light panels with a
header**, not black boxes — harmony over contrast.

- **Density:** Airy (2–3) — few elements per view, lots of space.
- **Variance:** Predictable (2–3) — kids need consistency, not asymmetric surprise.
- **Motion:** Restrained (2) — tactile press feedback only; no cinematic motion.

> **Why this departs from the skill defaults (variance 8 / motion 6):** both taste
> guides state that accessibility-first / kids / trust-first audiences *override*
> aesthetic preference. A child learning to code needs a quiet, legible, forgiving
> interface — so we keep the guides' craft (depth, spacing, rounding, restraint on
> emoji/borders/shadows) and drop their marketing-site flamboyance.

## 2. Color palette & roles (Neo Play branding — friendly light)

Elevation: white cards/trays on the soft-white `background` canvas + whisper
borders; `surface_2` for recessed wells (code blocks, inputs).

| Name | Hex | Role | `Theme` token |
|---|---|---|---|
| Canvas | `#F7F9FC` | Soft-white canvas (sidebar content, window) | `background` |
| Panel | `#FFFFFF` | Toolbar, activity rail | `panel_bg` |
| Surface | `#FFFFFF` | Cards, trays | `surface` |
| Surface-2 | `#F2F5FA` | Recessed wells (code, inputs, gutter) | `surface_2` |
| Row hover | `#EDF1F7` | Hover / pressed row | `surface_alt` |
| Whisper | `#E7ECF3` | Hairline borders | `border` |
| Ink | `#1E2233` | Primary text | `text` |
| Steel | `#6B7280` | Secondary text, captions | `text_secondary` |
| **ThingEdu Green** | `#02D962` | **The accent** — CTA, active, progress | `primary` |
| Mint | `#E8FBF0` | Green-tinted selected / icon badge / rail pill | `primary_soft` |
| ThingEdge Blue | `#2E77E7` | Secondary/interactive — links, selected, secondary buttons | `secondary` |
| Rogo Red | `#FE2151` | Destructive/alert only — Stop, errors | `tertiary` |

**One dominant accent:** green decorates; blue and red are *semantic states*, not
decoration. Never all three in one component. No neon/glow. **Contrast:** the
bright green is a light surface → its text is **dark** (`primary_text` `#05231A`,
`run_text`), passing WCAG AA. Blue/red carry white text. Syntax colors are tuned
darker for readability on the white editor.

## 3. Spacing — 4px grid (`Theme.space_*`)

`xs 4 · sm 8 · md 12 · base 16 · lg 24 · xl 32`. **Padding is generous:** cards and
dialogs pad at `base` (16), sections gap at `lg` (24). Breathing room over density.

## 4. Radius — nesting rule (`Theme.radius_*`)

Rounded and friendly. `inner = outer − padding`, concentric.

| Token | Value | Use |
|---|---|---|
| `radius_chip` | 10 | buttons, chips, list rows |
| `radius_card` | 16 | cards |
| `radius_lg` | 20 | trays / large containers |
| `radius_inner` | 8 | content block inside a 16-padded card |
| `radius_pill` | 999 | pill controls (steppers) |

One radius scale, applied consistently (shape-consistency lock).

## 5. Depth — surfaces, not blur

The ARM target (2 GB) makes runtime blur/drop-shadows expensive, and the skills
warn against harsh shadows anyway. **Depth comes from layered surfaces + hairline
borders (the "double-bezel"):** an outer `surface` tray (`radius_lg`) holds inner
white cards (`radius_card`, whisper border). Concentric, GPU-cheap, calm. No
`DropShadow`/blur effects.

## 6. Typography (`Theme.font_*`)

Bundled fonts (no system-default / Inter): **Nunito** for all UI (`font_family`,
set as the app default in `app.py`) — friendly, rounded, highly readable for kids;
**JetBrains Mono** for code / terminal / REPL (`mono_family`). Never serif in a
software UI. Hierarchy by **weight and color**, not size screaming. Fonts ship in
`resources/fonts/` and load via `QFontDatabase.addApplicationFont`.

| Token | px | Use |
|---|---|---|
| `font_caption` | 11 | metadata, group labels |
| `font_body` | 13 | body, list items |
| `font_title` | 15 | card/section titles (bold) |
| `font_heading` | 18 | panel headings (bold) |

## 7. Components

- **Buttons.** Min height 40 (kid touch target ≥ 40–44px). Icon + label **centered**,
  `space_xs` gap, `radius_chip`. Tactile: `scale 0.97` on press (transform only).
  - *Primary* = solid green fill, white text (Run, main CTA).
  - *Destructive* = solid red fill (Stop only).
  - *Secondary* = solid blue fill (copy-to-editor, load-sample).
  - *Utility* = ghost (transparent → `surface_alt` on hover) with ink text.
  - Always pass WCAG AA contrast; never text-on-same-color.
- **Cards.** `surface` fill (or white inside a tray), whisper border, `radius_card`,
  `base` padding. Titled cards lead with an ultra-light MDI icon in the accent.
- **List rows.** ≥ 36px tall, `radius_chip`, hover = `surface_alt`, selected = `primary_soft`.
- **Grouped sections.** A `surface` tray (`radius_lg`, `sm`+ padding) groups related
  rows — never a heavy divider.
- **Inputs / steppers.** Label above control. Focus ring in accent. Kid-friendly
  `−`/`+` steppers (pill) over tiny spin arrows.
- **Icons.** Material Design Icons, **outline/light** weight, via the `Icon` component
  (`Icon { name: "play" }`). No emoji, no hand-drawn SVG. Codepoints in
  `theme/design.py`. One icon family.

## 8. Anti-patterns (banned)

Emoji as icons · pure black `#000` · neon/glow shadows · runtime blur on ARM ·
heavy 1px grey borders (use whisper) · serif in UI · more than one decorative
accent · cramped padding · tiny touch targets (< 40px) · asymmetric/novelty layout
(kids need predictable) · decorative motion.

## 9. Code mapping

`theme/colors.py` (palette) + `theme/design.py` (`SPACING`, `RADIUS`, `TYPE`,
`SIZING`, MDI map) → merged by `build_theme()` into the QML `Theme` object. Icons
via `Mdi` + `mdiFont`. Reusable QML: `Icon`, `AppButton` (tactile, variant-driven).
