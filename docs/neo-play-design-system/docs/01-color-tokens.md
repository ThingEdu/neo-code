# Design Tokens — Color System

Base: Google Material Design 3 color roles, mapped to Neo Play / ThingEdu brand colors. A dedicated Error role was added since M3 requires Error to be distinct from brand Tertiary.

## Token Table

| Role | JSON token key | CSS variable | Hex | Android XML | Usage |
|---|---|---|---|---|---|
| Primary | `color.primary` | `--color-primary` | `#02D962` | `@color/md_theme_primary` | Main CTAs, active states, brand emphasis (ThingEdu) |
| On Primary | `color.onPrimary` | `--color-on-primary` | `#FFFFFF` | `@color/md_theme_onPrimary` | Text/icons on Primary |
| Primary Container | `color.primaryContainer` | `--color-primary-container` | `#C6F7D8` | `@color/md_theme_primaryContainer` | Lighter fill for selected/tonal buttons |
| On Primary Container | `color.onPrimaryContainer` | `--color-on-primary-container` | `#00210F` | `@color/md_theme_onPrimaryContainer` | Text/icons on Primary Container |
| Secondary | `color.secondary` | `--color-secondary` | `#2E77E7` | `@color/md_theme_secondary` | Secondary actions, links, chips (ThingEdge) |
| On Secondary | `color.onSecondary` | `--color-on-secondary` | `#FFFFFF` | `@color/md_theme_onSecondary` | Text/icons on Secondary |
| Secondary Container | `color.secondaryContainer` | `--color-secondary-container` | `#D6E7FF` | `@color/md_theme_secondaryContainer` | Filter chips, tonal secondary buttons |
| On Secondary Container | `color.onSecondaryContainer` | `--color-on-secondary-container` | `#001C3B` | `@color/md_theme_onSecondaryContainer` | Text/icons on Secondary Container |
| Tertiary | `color.tertiary` | `--color-tertiary` | `#FE2151` | `@color/md_theme_tertiary` | Decorative accents, "Powered by Rogo" attribution |
| On Tertiary | `color.onTertiary` | `--color-on-tertiary` | `#FFFFFF` | `@color/md_theme_onTertiary` | Text/icons on Tertiary |
| Error | `color.error` | `--color-error` | `#B3261E` | `@color/md_theme_error` | Errors, destructive actions — never reuse Tertiary for this |
| On Error | `color.onError` | `--color-on-error` | `#FFFFFF` | `@color/md_theme_onError` | Text/icons on Error |
| Surface | `color.surface` | `--color-surface` | `#FFFFFF` | `@color/md_theme_surface` | App background, cards, sheets |
| On Surface | `color.onSurface` | `--color-on-surface` | `#1A1C1E` | `@color/md_theme_onSurface` | Default body text/icons |
| Surface Variant | `color.surfaceVariant` | `--color-surface-variant` | `#E1E2E8` | `@color/md_theme_surfaceVariant` | Dividers, outlines, disabled fills |
| Outline | `color.outline` | `--color-outline` | `#74777F` | `@color/md_theme_outline` | Borders, input field outlines |

## JSON Design Tokens (W3C Design Tokens format)

```json
{
  "color": {
    "primary": { "$value": "#02D962", "$type": "color" },
    "onPrimary": { "$value": "#FFFFFF", "$type": "color" },
    "primaryContainer": { "$value": "#C6F7D8", "$type": "color" },
    "onPrimaryContainer": { "$value": "#00210F", "$type": "color" },
    "secondary": { "$value": "#2E77E7", "$type": "color" },
    "onSecondary": { "$value": "#FFFFFF", "$type": "color" },
    "secondaryContainer": { "$value": "#D6E7FF", "$type": "color" },
    "onSecondaryContainer": { "$value": "#001C3B", "$type": "color" },
    "tertiary": { "$value": "#FE2151", "$type": "color" },
    "onTertiary": { "$value": "#FFFFFF", "$type": "color" },
    "error": { "$value": "#B3261E", "$type": "color" },
    "onError": { "$value": "#FFFFFF", "$type": "color" },
    "surface": { "$value": "#FFFFFF", "$type": "color" },
    "onSurface": { "$value": "#1A1C1E", "$type": "color" },
    "surfaceVariant": { "$value": "#E1E2E8", "$type": "color" },
    "outline": { "$value": "#74777F", "$type": "color" }
  }
}
```

## CSS Variables

```css
:root {
  --color-primary: #02D962;
  --color-on-primary: #FFFFFF;
  --color-primary-container: #C6F7D8;
  --color-on-primary-container: #00210F;
  --color-secondary: #2E77E7;
  --color-on-secondary: #FFFFFF;
  --color-secondary-container: #D6E7FF;
  --color-on-secondary-container: #001C3B;
  --color-tertiary: #FE2151;
  --color-on-tertiary: #FFFFFF;
  --color-error: #B3261E;
  --color-on-error: #FFFFFF;
  --color-surface: #FFFFFF;
  --color-on-surface: #1A1C1E;
  --color-surface-variant: #E1E2E8;
  --color-outline: #74777F;
}
```

## Conflict Resolution Notes

- Original brand draft had no Error color and implied Rogo Red could double as an alert/negative color. **Resolved:** Rogo Red stays Tertiary-only; a standard Material error red (`#B3261E`) was added as its own role.
- Container/On-Container variants (e.g. `primaryContainer`) did not exist in the original draft — added because M3 components (filled tonal buttons, chips, selected states) require them.

## Rules for implementation (for AI agents)

- Never use raw hex values directly in component code — always reference the token/CSS variable.
- Always pair a base role with its "on" counterpart for text/icon contrast (e.g. `background: var(--color-primary)` → `color: var(--color-on-primary)`).
- Use `*Container` variants for lower-emphasis/tonal versions of a component (e.g. a selected chip background), not the base role.
- Do not use Tertiary or Secondary as a substitute for Error.
