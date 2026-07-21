# GTK (Rust / gtk-rs) Adapter

GTK4 CSS supports `@define-color` for color tokens (used in `theme.css`), and
even supports `box-shadow`, but it does **not** support generic custom
properties for lengths (spacing/radius) — those are hardcoded per rule in
`theme.css`, each commented with its source token.

This adapter splits the tokens into two files that must be kept in sync:

- **`theme_tokens.rs`** — Rust `const`/struct module (`color`, `space`,
  `radius`, `typography`, `elevation`) for anything set in code (fonts,
  dynamic sizing, custom-drawn shadows).
- **`theme.css`** — a GTK4 CSS stylesheet using `@define-color` for colors
  and literal px values for spacing/radius/shadows, with CSS classes
  (`.primary-button`, `.card`, `.chip`, etc.) to apply via `widget.add_css_class(...)`.

## Usage

**Cargo.toml** (typical deps for this adapter):
```toml
[dependencies]
gtk = { version = "0.9", package = "gtk4" }
gdk = { version = "0.9", package = "gdk4" }
pango = "0.20"
```

**Loading the stylesheet:**
```rust
use gtk::{gdk, CssProvider, STYLE_PROVIDER_PRIORITY_APPLICATION};
use gtk::prelude::*;

let provider = CssProvider::new();
provider.load_from_path("theme.css");
gtk::style_context_add_provider_for_display(
    &gdk::Display::default().expect("no display"),
    &provider,
    STYLE_PROVIDER_PRIORITY_APPLICATION,
);
```

**Applying a class to a widget:**
```rust
let button = gtk::Button::with_label("Save");
button.add_css_class("primary-button"); // picks up rule from theme.css
```

**Using token constants directly in code:**
```rust
mod theme_tokens; // theme_tokens.rs from this folder
use theme_tokens::{space, radius, color};

box_.set_spacing(space::MD);
let rgba = color::PRIMARY.to_rgba();
```

## Notes / limitations

- **Pill radius**: `radius::FULL_SENTINEL` (9999) isn't a literal usable
  radius — for a true pill/circular widget, compute `min(width, height) / 2`
  at runtime and set it via a dynamically-generated CSS class or inline
  provider, since static CSS can't reference a widget's own size.
- **Hover/pressed color shades**: `theme.css` uses GTK CSS's `shade()`
  function (e.g. `shade(@color_primary, 0.92)`) to darken tokens for
  hover/active states, so those don't need separate hardcoded hex values.
- **Custom-drawn shadows**: `theme_tokens.rs`'s `elevation` module exists for
  cases where you're manually drawing (e.g. via `GtkDrawingArea`/`Snapshot`)
  rather than relying on the CSS `box-shadow` already in `theme.css`.
- Keep `theme_tokens.rs` and `theme.css` in sync manually — if
  `tokens/tokens.json` in the parent package changes, update both files to
  match.
