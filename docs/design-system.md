## Neo Play — Design System (Google Material Design 3 Aligned)

This design system combines the Neo Play / ThingEdu brand palette with **Google's Material Design 3 (M3)** conventions. Where our original draft conflicted with official Material guidance, Material's convention takes priority for consistency, accessibility, and easier Android/Compose implementation.

### 1. Color System

Material 3 organizes color into **roles** (Primary, Secondary, Tertiary, Neutral/Surface, Error), each with a base, "on" (text/icon), and "container" (fill) variant. Our brand colors are mapped into these official roles below.

| Role              | Token        | Hex                      | Usage                                                                                         |
| ----------------- | ------------ | ------------------------ | --------------------------------------------------------------------------------------------- |
| Primary           | Primary      | #02D962 (ThingEdu Green) | Prominent buttons, active states, key brand elements — represents ThingEdu, the app publisher |
|                   | On-Primary   | #FFFFFF                  | Text/icons on top of Primary                                                                  |
| Secondary         | Secondary    | #2E77E7 (ThingEdge Blue) | Secondary buttons, filter chips, links — represents ThingEdge, the retailer brand             |
|                   | On-Secondary | #FFFFFF                  | Text/icons on top of Secondary                                                                |
| Tertiary          | Tertiary     | #FE2151 (Rogo Red)       | Contrasting accents, "Powered by Rogo Solutions" attribution, used sparingly                  |
|                   | On-Tertiary  | #FFFFFF                  | Text/icons on top of Tertiary                                                                 |
| Neutral / Surface | Surface      | #FFFFFF (White)          | App backgrounds, cards, sheets, the neutral base canvas                                       |
|                   | On-Surface   | #1A1C1E                  | Default body text/icons on surface (near-black, not pure black, per M3 convention)            |
| Error             | Error        | #B3261E                  | Error states, validation messages, destructive actions                                        |
|                   | On-Error     | #FFFFFF                  | Text/icons on top of Error                                                                    |

#### Resolved Conflict: Error Color

Our original palette used **Rogo Red as "tertiary"** with no dedicated error color. Material 3 requires a **separate, dedicated Error role** distinct from brand accents, since Tertiary is meant for decorative/expressive use while Error must be reserved exclusively for error/destructive states to avoid user confusion. Per Google convention: **Rogo Red stays Tertiary (brand use)**, and a standard Material error red (**#B3261E**) is added as its own role for actual errors/destructive actions.

#### Usage Guidelines

* Use **Primary** for the single most prominent action per screen (don't overuse — M3 favors restraint)

* Use **Secondary** for supporting actions, chips, and selected states

* Use **Tertiary** sparingly for accents/attribution, not for functional states

* Use **Error** exclusively for errors/destructive actions — never reuse Tertiary for this

* All color pairs (e.g. Primary/On-Primary) must meet WCAG AA contrast (4.5:1 for text)

### 2. Typography

Material 3 defines a type scale with 5 categories × 3 sizes (Large/Medium/Small) = 15 styles. Recommended baseline for Neo Play apps:

| Style          | Size / Line Height | Weight  | Usage                           |
| -------------- | ------------------ | ------- | ------------------------------- |
| Display Large  | 57px / 64px        | Regular | Hero/splash text (rare)         |
| Headline Large | 32px / 40px        | Regular | Screen titles                   |
| Title Large    | 22px / 28px        | Medium  | Section/card titles             |
| Title Medium   | 16px / 24px        | Medium  | List item titles, dialog titles |
| Body Large     | 16px / 24px        | Regular | Primary body text               |
| Body Medium    | 14px / 20px        | Regular | Secondary body text             |
| Label Large    | 14px / 20px        | Medium  | Buttons, prominent labels       |
| Label Small    | 11px / 16px        | Medium  | Captions, badges, helper text   |

Recommended typeface: **Roboto** or **Google Sans** (Android-native, pairs naturally with Material components); a brand display font can be layered in for Headline/Display styles only if desired.

### 3. Spacing System

Material 3 uses a base **4dp unit**, with most layout spacing expressed in **8dp increments** and 4dp reserved for fine adjustments (icon-text gaps, dense components). This refines (not conflicts with) our original 4px convention — we keep 4px as the atomic unit but standardize on 8px steps for general layout.

| Token | Value | Typical Use                                                  |
| ----- | ----- | ------------------------------------------------------------ |
| xs    | 4px   | Icon-to-text gaps, dense/compact spacing only                |
| sm    | 8px   | Compact component padding, chip spacing                      |
| md    | 16px  | Default padding for cards, buttons, list items (M3 standard) |
| lg    | 24px  | Section spacing, screen-edge margins                         |
| xl    | 32px  | Major section breaks                                         |
| xxl   | 48px  | Large screen margins, empty states                           |

### 4. Shape (Corner Radius)

Material 3 defines an official **shape scale** of corner-radius tokens. This replaces our original custom "inner = outer − padding" formula as the primary standard, since it gives predictable, component-consistent results across the whole system:

| Token       | Radius        | Typical Use                        |
| ----------- | ------------- | ---------------------------------- |
| None        | 0px           | Full-bleed surfaces, dividers      |
| Extra Small | 4px           | Small chips, tooltips              |
| Small       | 8px           | Buttons, small cards, text fields  |
| Medium      | 12px          | Standard cards, dialogs            |
| Large       | 16px          | Large cards, bottom sheets         |
| Extra Large | 28px          | Prominent containers, large modals |
| Full        | 9999px (pill) | FABs, pill buttons, avatars        |

**Nesting guidance (kept as supplementary rule):** for custom/non-standard nested components not covered by the scale above, use `inner radius = outer radius − padding` (minimum 0px) so nested corners stay visually concentric.

### 5. Elevation & Surfaces

Material 3 favors subtle **tonal elevation** (slight surface color shifts) over heavy drop shadows.

| Level | Use                             |
| ----- | ------------------------------- |
| 0     | Base background                 |
| 1     | Cards, resting surfaces         |
| 2     | Buttons (default state)         |
| 3     | Dialogs, menus                  |
| 4–5   | Navigation drawers, modal sheet |
