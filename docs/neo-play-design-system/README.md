# Neo Play Design System

This package contains the full Neo Play / ThingEdu design system, based on **Google Material Design 3 (M3)** conventions combined with the Neo Play brand palette. It's structured to be directly usable by AI coding agents (Claude Code, Codex, etc.) as well as human developers/designers.

## Note for AI coding agents (Claude Code, Codex, etc.)

- Treat every table in `docs/` as the **source of truth** for token names and values. Do not invent new hex codes, spacing values, or radii — always pull from the tables here.
- Machine-readable token files are in `tokens/`:
  - `tokens/tokens.json` — all design tokens in one file (W3C Design Tokens Community Group format)
  - `tokens/tokens.css` — all tokens as CSS custom properties
  - `tokens/tailwind.config.snippet.js` — Tailwind config extension snippet
- Token names are given in **three forms** in the docs: a design-token JSON key (framework-agnostic), a CSS custom property, and where relevant a platform-native equivalent (Android XML / Jetpack Compose). Use whichever matches the target codebase.
- If a component isn't explicitly covered in `docs/06-component-usage.md`, derive its styling from the closest matching role/token rather than introducing a new one-off value.
- If the target codebase already has a `tokens/` or `theme/` directory, prefer generating/updating files there using the structures in this package, rather than inlining raw hex/px values across components.
- Base system: **Google Material Design 3 (M3)**, customized with Neo Play / ThingEdu brand colors. Where brand preference conflicted with M3 convention, M3 convention was kept as primary (see each doc's "conflict resolution" notes).

## Contents

| File | Covers |
|---|---|
| `docs/01-color-tokens.md` | Color roles, hex values, CSS vars, JSON tokens, Android/Compose mapping |
| `docs/02-typography-tokens.md` | Type scale, font stack, CSS vars, JSON tokens |
| `docs/03-spacing-tokens.md` | Spacing scale, CSS vars, JSON tokens, Tailwind config |
| `docs/04-shape-tokens.md` | Corner radius scale, CSS vars, JSON tokens, nesting fallback rule |
| `docs/05-elevation-tokens.md` | Elevation levels, shadow/tint values |
| `docs/06-component-usage.md` | How tokens map onto real components (buttons, cards, inputs, nav, dialogs, FAB) |
| `tokens/tokens.json` | All tokens combined, machine-readable (web/JS/general use) |
| `tokens/tokens.css` | All tokens as CSS custom properties (web) |
| `tokens/tailwind.config.snippet.js` | Tailwind theme extension |

## Platform Adapters

The core tokens are web-flavored (CSS variables, JSON). For desktop toolkits that don't
support CSS custom properties or `var()`, use the adapters below instead — they contain
the same values pre-translated into each toolkit's native format:

| Folder | Toolkit | Contents |
|---|---|---|
| `adapters/pyqt6/` | PyQt6 (Python) | `theme_tokens.py` (constants + helpers) + `theme.qss` (stylesheet) |
| `adapters/gtk-rust/` | GTK4 + gtk-rs (Rust) | `theme_tokens.rs` (constants module) + `theme.css` (GTK CSS with `@define-color`) |

Each adapter folder has its own README with usage examples and toolkit-specific
limitations (e.g. neither QSS nor GTK CSS support generic length variables, so
spacing/radius values are hardcoded per rule rather than referencing a variable).

## Design Principles

1. **Consistency over invention** — always reuse a token; never hardcode a new value inline
2. **Accessibility first** — all foreground/background pairs must meet WCAG AA (4.5:1 for body text, 3:1 for large text/UI components)
3. **Restraint with brand color** — Primary (ThingEdu Green) should dominate one clear action per screen; avoid rainbow UI
4. **Platform-native feel** — prefer Material 3 component conventions (buttons, cards, nav) over custom one-offs unless there's a strong product reason

## Brand Color Reference

| Name | Hex | Role | Represents |
|---|---|---|---|
| ThingEdu Green | `#02D962` | Primary | ThingEdu — the primary app publisher |
| ThingEdge Blue | `#2E77E7` | Secondary | ThingEdge — retailer brand of ThingEdu |
| Rogo Red | `#FE2151` | Tertiary | "Powered by Rogo Solutions" attribution |
| White | `#FFFFFF` | Neutral | Base surface/background color |

Source of truth also lives in the **neo-play** Plane project pages:
- Design System — Index & AI Agent Guide
- Design Tokens — Color System
- Design Tokens — Typography
- Design Tokens — Spacing
- Design Tokens — Shape & Corner Radius
- Design Tokens — Elevation & Surfaces
- Component Usage Guidelines
