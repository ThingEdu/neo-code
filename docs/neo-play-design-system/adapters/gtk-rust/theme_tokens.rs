//! Neo Play design tokens — Rust constants module for gtk-rs.
//!
//! Auto-derived from tokens/tokens.json. Use these instead of hardcoding
//! hex strings, px values, or font specs anywhere in application code.
//! Colors are also defined in `theme.css` via `@define-color` for use in
//! GTK CSS selectors — keep both in sync if a token value changes.
//!
//! Usage:
//!     use theme_tokens::{Color, Space, Radius, Elevation, TypeStyle, Type};
//!     let rgba = Color::PRIMARY.to_rgba();

/// Hex color tokens, plus an RGBA helper for gtk-rs/gdk.
pub mod color {
    pub struct Hex(pub &'static str);

    impl Hex {
        /// Parse this token into a `gdk::RGBA`. Requires the `gdk` crate.
        pub fn to_rgba(&self) -> gdk::RGBA {
            gdk::RGBA::parse(self.0).expect("invalid token hex color")
        }
    }

    pub const PRIMARY: Hex = Hex("#02D962");
    pub const ON_PRIMARY: Hex = Hex("#FFFFFF");
    pub const PRIMARY_CONTAINER: Hex = Hex("#C6F7D8");
    pub const ON_PRIMARY_CONTAINER: Hex = Hex("#00210F");

    pub const SECONDARY: Hex = Hex("#2E77E7");
    pub const ON_SECONDARY: Hex = Hex("#FFFFFF");
    pub const SECONDARY_CONTAINER: Hex = Hex("#D6E7FF");
    pub const ON_SECONDARY_CONTAINER: Hex = Hex("#001C3B");

    pub const TERTIARY: Hex = Hex("#FE2151");
    pub const ON_TERTIARY: Hex = Hex("#FFFFFF");

    pub const ERROR: Hex = Hex("#B3261E");
    pub const ON_ERROR: Hex = Hex("#FFFFFF");

    pub const SURFACE: Hex = Hex("#FFFFFF");
    pub const ON_SURFACE: Hex = Hex("#1A1C1E");
    pub const SURFACE_VARIANT: Hex = Hex("#E1E2E8");
    pub const OUTLINE: Hex = Hex("#74777F");
}

/// Spacing scale, in px (i32 — use directly for GTK margins/spacing setters).
pub mod space {
    pub const XS: i32 = 4;
    pub const SM: i32 = 8;
    pub const MD: i32 = 16;
    pub const LG: i32 = 24;
    pub const XL: i32 = 32;
    pub const XXL: i32 = 48;
}

/// Corner radius scale, in px.
pub mod radius {
    pub const NONE: i32 = 0;
    pub const XS: i32 = 4;
    pub const SM: i32 = 8;
    pub const MD: i32 = 12;
    pub const LG: i32 = 16;
    pub const XL: i32 = 28;
    /// Not a literal usable radius — for true pill/circular widgets,
    /// use `min(width, height) / 2` at runtime instead.
    pub const FULL_SENTINEL: i32 = 9999;
}

/// Typography scale. Pair with a `pango::FontDescription` in gtk-rs.
pub mod typography {
    #[derive(Clone, Copy)]
    pub struct TypeStyle {
        pub size_px: i32,
        pub line_height_px: i32,
        pub weight: i32, // maps to pango::Weight buckets, e.g. 400 = Normal, 500 = Medium, 700 = Bold
    }

    pub const FONT_FAMILY: &str = "Roboto";

    pub const DISPLAY_LARGE: TypeStyle = TypeStyle { size_px: 57, line_height_px: 64, weight: 400 };
    pub const DISPLAY_MEDIUM: TypeStyle = TypeStyle { size_px: 45, line_height_px: 52, weight: 400 };
    pub const HEADLINE_LARGE: TypeStyle = TypeStyle { size_px: 32, line_height_px: 40, weight: 400 };
    pub const HEADLINE_MEDIUM: TypeStyle = TypeStyle { size_px: 28, line_height_px: 36, weight: 400 };
    pub const TITLE_LARGE: TypeStyle = TypeStyle { size_px: 22, line_height_px: 28, weight: 500 };
    pub const TITLE_MEDIUM: TypeStyle = TypeStyle { size_px: 16, line_height_px: 24, weight: 500 };
    pub const TITLE_SMALL: TypeStyle = TypeStyle { size_px: 14, line_height_px: 20, weight: 500 };
    pub const BODY_LARGE: TypeStyle = TypeStyle { size_px: 16, line_height_px: 24, weight: 400 };
    pub const BODY_MEDIUM: TypeStyle = TypeStyle { size_px: 14, line_height_px: 20, weight: 400 };
    pub const BODY_SMALL: TypeStyle = TypeStyle { size_px: 12, line_height_px: 16, weight: 400 };
    pub const LABEL_LARGE: TypeStyle = TypeStyle { size_px: 14, line_height_px: 20, weight: 500 };
    pub const LABEL_MEDIUM: TypeStyle = TypeStyle { size_px: 12, line_height_px: 16, weight: 500 };
    pub const LABEL_SMALL: TypeStyle = TypeStyle { size_px: 11, line_height_px: 16, weight: 500 };

    /// Build a `pango::FontDescription` from a TypeStyle (requires the `pango` crate).
    pub fn font_description(style: TypeStyle) -> pango::FontDescription {
        let mut desc = pango::FontDescription::new();
        desc.set_family(FONT_FAMILY);
        desc.set_size(style.size_px * pango::SCALE);
        desc.set_weight(match style.weight {
            w if w >= 700 => pango::Weight::Bold,
            w if w >= 500 => pango::Weight::Medium,
            _ => pango::Weight::Normal,
        });
        desc
    }
}

/// Elevation levels, expressed as (blur_px, x_offset, y_offset, alpha 0.0-1.0)
/// matching the box-shadow values already applied via theme.css. Provided here
/// mainly for cases where a shadow needs to be drawn manually (e.g. custom
/// GtkDrawingArea/Snapshot rendering) rather than through CSS.
pub mod elevation {
    pub struct Shadow {
        pub blur_px: f64,
        pub x_offset: f64,
        pub y_offset: f64,
        pub alpha: f64,
    }

    pub const LEVEL_0: Shadow = Shadow { blur_px: 0.0, x_offset: 0.0, y_offset: 0.0, alpha: 0.0 };
    pub const LEVEL_1: Shadow = Shadow { blur_px: 2.0, x_offset: 0.0, y_offset: 1.0, alpha: 0.08 };
    pub const LEVEL_2: Shadow = Shadow { blur_px: 3.0, x_offset: 0.0, y_offset: 1.0, alpha: 0.12 };
    pub const LEVEL_3: Shadow = Shadow { blur_px: 8.0, x_offset: 0.0, y_offset: 4.0, alpha: 0.14 };
    pub const LEVEL_4: Shadow = Shadow { blur_px: 10.0, x_offset: 0.0, y_offset: 6.0, alpha: 0.16 };
    pub const LEVEL_5: Shadow = Shadow { blur_px: 12.0, x_offset: 0.0, y_offset: 8.0, alpha: 0.18 };
}
