# Component Usage Guidelines

Maps the token systems (color, typography, spacing, shape, elevation) onto real UI components. Use this as the direct lookup when implementing or reviewing a specific component.

## Button (Primary)
- Background: `--color-primary` · Text: `--color-on-primary`
- Padding: `--space-sm` vertical, `--space-md` horizontal
- Radius: `--radius-sm`
- Text style: `--type-label-lg`
- Elevation: `--elevation-1` resting, `--elevation-2` on hover/press

## Button (Secondary / Tonal)
- Background: `--color-secondary-container` · Text: `--color-on-secondary-container`
- Padding/radius/text style: same as Primary button
- Elevation: none by default (flat tonal style)

## Card
- Background: `--color-surface` · Text: `--color-on-surface`
- Padding: `--space-md`
- Radius: `--radius-md`
- Elevation: `--elevation-1`
- Title text: `--type-title-md` · Body text: `--type-body-md`

## Text Field / Input
- Border: `1px solid var(--color-outline)`; focused state uses `--color-primary`
- Padding: `--space-sm`
- Radius: `--radius-sm`
- Label text: `--type-label-md` · Input text: `--type-body-lg`
- Error state: border/label color → `--color-error`, helper text uses `--type-body-sm`

## Chip
- Background: `--color-secondary-container` (selected) or `--color-surface-variant` (unselected)
- Padding: `--space-xs` vertical, `--space-sm` horizontal
- Radius: `--radius-full`
- Text style: `--type-label-md`

## Dialog / Modal
- Background: `--color-surface`
- Padding: `--space-lg`
- Radius: `--radius-lg`
- Elevation: `--elevation-3`
- Title: `--type-title-lg` · Body: `--type-body-md`

## Bottom Sheet / Nav Drawer
- Background: `--color-surface`
- Radius: `--radius-xl` (top corners only for bottom sheets)
- Elevation: `--elevation-4` (drawer) / `--elevation-5` (modal bottom sheet)

## FAB (Floating Action Button)
- Background: `--color-primary` · Icon: `--color-on-primary`
- Radius: `--radius-full` (or `--radius-lg` for the "extended FAB" square variant)
- Elevation: `--elevation-2`, rising to `--elevation-3` on press

## Error / Validation Message
- Text/icon color: `--color-error` — never `--color-tertiary`
- Text style: `--type-body-sm`

## Navigation Bar (bottom/top)
- Background: `--color-surface`, `--elevation-2`
- Active icon/label: `--color-primary` · Inactive: `--color-outline`
- Label text: `--type-label-md`

## For AI agents: implementation checklist

1. Identify the component type from the list above (or the closest match)
2. Pull exact token names from the relevant Design Tokens doc — never invent a new value
3. Verify color contrast pairs (base + "on" role) meet WCAG AA
4. If a genuinely new component type is needed, propose new token mappings here rather than hardcoding ad hoc styles, and add it to this table for future consistency
