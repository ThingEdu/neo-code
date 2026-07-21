# Design Tokens — Shape & Corner Radius

Based on Google Material Design 3's official shape scale. This is the primary standard; a supplementary nesting formula covers cases the scale doesn't fit.

## Token Table

| Token | JSON key | CSS variable | Radius | Typical use |
|---|---|---|---|---|
| None | `shape.none` | `--radius-none` | 0px | Full-bleed surfaces, dividers |
| Extra Small | `shape.xs` | `--radius-xs` | 4px | Small chips, tooltips |
| Small | `shape.sm` | `--radius-sm` | 8px | Buttons, small cards, text fields |
| Medium | `shape.md` | `--radius-md` | 12px | Standard cards, dialogs |
| Large | `shape.lg` | `--radius-lg` | 16px | Large cards, bottom sheets |
| Extra Large | `shape.xl` | `--radius-xl` | 28px | Prominent containers, large modals |
| Full | `shape.full` | `--radius-full` | 9999px | FABs, pill buttons, avatars |

## JSON Design Tokens

```json
{
  "shape": {
    "none": { "$value": "0px", "$type": "dimension" },
    "xs": { "$value": "4px", "$type": "dimension" },
    "sm": { "$value": "8px", "$type": "dimension" },
    "md": { "$value": "12px", "$type": "dimension" },
    "lg": { "$value": "16px", "$type": "dimension" },
    "xl": { "$value": "28px", "$type": "dimension" },
    "full": { "$value": "9999px", "$type": "dimension" }
  }
}
```

## CSS Variables

```css
:root {
  --radius-none: 0px;
  --radius-xs: 4px;
  --radius-sm: 8px;
  --radius-md: 12px;
  --radius-lg: 16px;
  --radius-xl: 28px;
  --radius-full: 9999px;
}
```

## Supplementary Nesting Rule

For a custom/non-standard nested component not covered by the scale above (e.g. a button sitting inside a card with non-standard padding), calculate the inner radius as:

```
innerRadius = max(0, outerRadius - padding)
```

| Example | Outer radius | Padding | Inner radius |
|---|---|---|---|
| Card → Button | 16px (lg) | 8px (sm) | 8px |
| Card → Inner content block | 24px | 16px (md) | 8px |
| Small chip | 8px (sm) | 4px (xs) | 4px |

If the calculated inner radius would be ≤ 0, use a straight edge (0px / `--radius-none`) instead of a negative or overly sharp mismatch.

## Rules for implementation (for AI agents)

- Always try a scale token (none/xs/sm/md/lg/xl/full) first — only fall back to the nesting formula for genuinely custom/nested cases.
- Buttons and text fields → **sm (8px)**. Standard cards/dialogs → **md (12px)**. Large cards/sheets → **lg (16px)**. FABs/avatars/pills → **full**.
- Don't introduce one-off radius values (e.g. 10px, 14px, 20px) outside this scale.
