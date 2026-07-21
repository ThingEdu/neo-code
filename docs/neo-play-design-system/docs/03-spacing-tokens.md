# Design Tokens — Spacing

Base unit: 4px. General layout should step in 8px increments per Material Design 3 convention; 4px is reserved for fine/dense adjustments only.

## Token Table

| Token | JSON key | CSS variable | Value | Typical use |
|---|---|---|---|---|
| xs | `space.xs` | `--space-xs` | 4px | Icon-to-text gaps, dense/compact spacing only |
| sm | `space.sm` | `--space-sm` | 8px | Compact component padding, chip spacing, gap between related inline elements |
| md | `space.md` | `--space-md` | 16px | Default padding for cards, buttons, list items (M3 standard unit) |
| lg | `space.lg` | `--space-lg` | 24px | Section spacing, screen-edge margins |
| xl | `space.xl` | `--space-xl` | 32px | Major section breaks between distinct content blocks |
| xxl | `space.xxl` | `--space-xxl` | 48px | Large screen margins, empty states, hero sections |

## JSON Design Tokens

```json
{
  "space": {
    "xs": { "$value": "4px", "$type": "dimension" },
    "sm": { "$value": "8px", "$type": "dimension" },
    "md": { "$value": "16px", "$type": "dimension" },
    "lg": { "$value": "24px", "$type": "dimension" },
    "xl": { "$value": "32px", "$type": "dimension" },
    "xxl": { "$value": "48px", "$type": "dimension" }
  }
}
```

## CSS Variables

```css
:root {
  --space-xs: 4px;
  --space-sm: 8px;
  --space-md: 16px;
  --space-lg: 24px;
  --space-xl: 32px;
  --space-xxl: 48px;
}
```

## Tailwind config equivalent

```js
// tailwind.config.js
theme: {
  extend: {
    spacing: {
      xs: '4px',
      sm: '8px',
      md: '16px',
      lg: '24px',
      xl: '32px',
      xxl: '48px',
    }
  }
}
```

## Rules for implementation (for AI agents)

- All padding/margin/gap values must be one of the tokens above — never an arbitrary px value (no 10px, 13px, 20px, etc.)
- Default component internal padding = **md (16px)** unless the component is explicitly "compact"/"dense", in which case use **sm (8px)**
- Use **xs (4px)** sparingly — icon/text gaps, or nested-corner padding calculations (see shape doc), not general layout
- Screen-edge margins default to **lg (24px)** on mobile, can increase to **xl/xxl** on tablet/desktop breakpoints
