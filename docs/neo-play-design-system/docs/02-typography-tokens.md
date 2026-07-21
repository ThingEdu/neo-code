# Design Tokens — Typography

Based on Google Material Design 3's type scale: 5 categories (Display, Headline, Title, Body, Label) × 3 sizes (Large, Medium, Small).

## Font Family

| Role | Font | Fallback stack |
|---|---|---|
| Primary UI font | Roboto (Android-native) or Google Sans | `-apple-system, "Segoe UI", Roboto, Arial, sans-serif` |
| Optional brand display font | (only for Display/Headline, if brand wants extra flavor) | falls back to Roboto |

## Type Scale Token Table

| Style | JSON token key | CSS variable | Size / Line-height | Weight | Usage |
|---|---|---|---|---|---|
| Display Large | `type.displayLarge` | `--type-display-lg` | 57px / 64px | 400 | Hero/splash text (rare) |
| Display Medium | `type.displayMedium` | `--type-display-md` | 45px / 52px | 400 | Large promotional text |
| Headline Large | `type.headlineLarge` | `--type-headline-lg` | 32px / 40px | 400 | Screen titles |
| Headline Medium | `type.headlineMedium` | `--type-headline-md` | 28px / 36px | 400 | Sub-screen titles |
| Title Large | `type.titleLarge` | `--type-title-lg` | 22px / 28px | 500 | Section/card titles |
| Title Medium | `type.titleMedium` | `--type-title-md` | 16px / 24px | 500 | List item titles, dialog titles |
| Title Small | `type.titleSmall` | `--type-title-sm` | 14px / 20px | 500 | Compact headers, tab labels |
| Body Large | `type.bodyLarge` | `--type-body-lg` | 16px / 24px | 400 | Primary body text |
| Body Medium | `type.bodyMedium` | `--type-body-md` | 14px / 20px | 400 | Secondary body text |
| Body Small | `type.bodySmall` | `--type-body-sm` | 12px / 16px | 400 | Fine print, metadata |
| Label Large | `type.labelLarge` | `--type-label-lg` | 14px / 20px | 500 | Buttons, prominent labels |
| Label Medium | `type.labelMedium` | `--type-label-md` | 12px / 16px | 500 | Small buttons, chips |
| Label Small | `type.labelSmall` | `--type-label-sm` | 11px / 16px | 500 | Captions, badges, helper text |

## JSON Design Tokens

```json
{
  "type": {
    "fontFamily": { "$value": "Roboto, -apple-system, 'Segoe UI', Arial, sans-serif", "$type": "fontFamily" },
    "displayLarge": { "$value": { "fontSize": "57px", "lineHeight": "64px", "fontWeight": 400 }, "$type": "typography" },
    "displayMedium": { "$value": { "fontSize": "45px", "lineHeight": "52px", "fontWeight": 400 }, "$type": "typography" },
    "headlineLarge": { "$value": { "fontSize": "32px", "lineHeight": "40px", "fontWeight": 400 }, "$type": "typography" },
    "headlineMedium": { "$value": { "fontSize": "28px", "lineHeight": "36px", "fontWeight": 400 }, "$type": "typography" },
    "titleLarge": { "$value": { "fontSize": "22px", "lineHeight": "28px", "fontWeight": 500 }, "$type": "typography" },
    "titleMedium": { "$value": { "fontSize": "16px", "lineHeight": "24px", "fontWeight": 500 }, "$type": "typography" },
    "titleSmall": { "$value": { "fontSize": "14px", "lineHeight": "20px", "fontWeight": 500 }, "$type": "typography" },
    "bodyLarge": { "$value": { "fontSize": "16px", "lineHeight": "24px", "fontWeight": 400 }, "$type": "typography" },
    "bodyMedium": { "$value": { "fontSize": "14px", "lineHeight": "20px", "fontWeight": 400 }, "$type": "typography" },
    "bodySmall": { "$value": { "fontSize": "12px", "lineHeight": "16px", "fontWeight": 400 }, "$type": "typography" },
    "labelLarge": { "$value": { "fontSize": "14px", "lineHeight": "20px", "fontWeight": 500 }, "$type": "typography" },
    "labelMedium": { "$value": { "fontSize": "12px", "lineHeight": "16px", "fontWeight": 500 }, "$type": "typography" },
    "labelSmall": { "$value": { "fontSize": "11px", "lineHeight": "16px", "fontWeight": 500 }, "$type": "typography" }
  }
}
```

## CSS Variables

```css
:root {
  --font-family-base: Roboto, -apple-system, "Segoe UI", Arial, sans-serif;
  --type-display-lg: 400 57px/64px var(--font-family-base);
  --type-display-md: 400 45px/52px var(--font-family-base);
  --type-headline-lg: 400 32px/40px var(--font-family-base);
  --type-headline-md: 400 28px/36px var(--font-family-base);
  --type-title-lg: 500 22px/28px var(--font-family-base);
  --type-title-md: 500 16px/24px var(--font-family-base);
  --type-title-sm: 500 14px/20px var(--font-family-base);
  --type-body-lg: 400 16px/24px var(--font-family-base);
  --type-body-md: 400 14px/20px var(--font-family-base);
  --type-body-sm: 400 12px/16px var(--font-family-base);
  --type-label-lg: 500 14px/20px var(--font-family-base);
  --type-label-md: 500 12px/16px var(--font-family-base);
  --type-label-sm: 500 11px/16px var(--font-family-base);
}
/* usage: font: var(--type-body-lg); */
```

## Rules for implementation (for AI agents)

- Never hardcode font-size/line-height pairs inline — always use the matching type token/CSS variable.
- Screen/page titles → Headline; section/card headers → Title; paragraph/body copy → Body; buttons/tags/badges → Label.
- Don't mix a Display or Headline style into small UI chrome (buttons, chips) — reserve Label/Title for those.
- If a new one-off text style seems needed, check if a nearby existing token (e.g. Title Small vs Body Large) already fits before adding something new.
