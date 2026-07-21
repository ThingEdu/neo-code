# Design Tokens — Elevation & Surfaces

Material Design 3 favors subtle **tonal elevation** (a slight tint shift toward Primary as elements rise) over heavy drop shadows. Use light shadows for web/desktop where tonal tinting alone isn't enough to convey depth.

## Token Table

| Level | JSON key | CSS variable | Box-shadow (web fallback) | Typical use |
|---|---|---|---|---|
| 0 | `elevation.0` | `--elevation-0` | none | Base background |
| 1 | `elevation.1` | `--elevation-1` | `0px 1px 2px rgba(0,0,0,0.08)` | Cards, resting surfaces |
| 2 | `elevation.2` | `--elevation-2` | `0px 1px 3px rgba(0,0,0,0.12)` | Buttons (default state), raised chips |
| 3 | `elevation.3` | `--elevation-3` | `0px 4px 8px rgba(0,0,0,0.14)` | Dialogs, menus, dropdowns |
| 4 | `elevation.4` | `--elevation-4` | `0px 6px 10px rgba(0,0,0,0.16)` | Navigation drawers |
| 5 | `elevation.5` | `--elevation-5` | `0px 8px 12px rgba(0,0,0,0.18)` | Modal bottom sheets, top-most overlays |

## JSON Design Tokens

```json
{
  "elevation": {
    "0": { "$value": "none", "$type": "shadow" },
    "1": { "$value": "0px 1px 2px rgba(0,0,0,0.08)", "$type": "shadow" },
    "2": { "$value": "0px 1px 3px rgba(0,0,0,0.12)", "$type": "shadow" },
    "3": { "$value": "0px 4px 8px rgba(0,0,0,0.14)", "$type": "shadow" },
    "4": { "$value": "0px 6px 10px rgba(0,0,0,0.16)", "$type": "shadow" },
    "5": { "$value": "0px 8px 12px rgba(0,0,0,0.18)", "$type": "shadow" }
  }
}
```

## CSS Variables

```css
:root {
  --elevation-0: none;
  --elevation-1: 0px 1px 2px rgba(0,0,0,0.08);
  --elevation-2: 0px 1px 3px rgba(0,0,0,0.12);
  --elevation-3: 0px 4px 8px rgba(0,0,0,0.14);
  --elevation-4: 0px 6px 10px rgba(0,0,0,0.16);
  --elevation-5: 0px 8px 12px rgba(0,0,0,0.18);
}
/* usage: box-shadow: var(--elevation-1); */
```

## Rules for implementation (for AI agents)

- Prefer raising elevation level over adding a border to indicate a surface "floats" above another.
- On Android/Compose, pair elevation with M3's tonal surface tint (surface color shifts slightly toward Primary at higher elevation) rather than shadow alone.
- Don't stack multiple custom shadows — use exactly one elevation token per surface.
