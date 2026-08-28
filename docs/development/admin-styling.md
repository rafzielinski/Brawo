# Admin styling guide

Contributor reference for Brawo CMS admin CSS. Implementation map: [admin-internals.md](admin-internals.md).

## Theming model

The admin UI is themed from a single seed color. Set `--brawo-accent` on `:root` (or any ancestor of `.brawo-admin`) to retheme the entire interface.

```css
:root {
  --brawo-accent: oklch(83.905% 0.16629 157.184);
}
```

Everything else derives from that accent in [`variables.css`](../../app/assets/stylesheets/brawo_cms/admin/variables.css):

| Token | Derivation |
|-------|------------|
| `--brawo-light` | `oklch(from var(--brawo-accent) …)` — main content surface |
| `--brawo-dark` | same hue family, darker — body text on light surfaces |
| `--brawo-chrome` | from `--brawo-dark` — navbar, sidebar, outer shell |
| `--brawo-accent-on-light` / `-on-dark` | `color-mix` — accent foreground on surfaces |
| `--brawo-accent-strong` / `-faint` | `color-mix` — hover fills and subtle highlights |

Browsers without `oklch(from …)` support get fallback mixes in the `@supports not` block in `variables.css`.

## Shade scale

Tokens use a consistent suffix pattern:

| Suffix | Meaning |
|--------|---------|
| *(base)* | Primary value |
| `-soft` | Lighter / muted surface |
| `-strong` | Darker / emphasized |
| `-faint` | Very subtle tint or border |

Examples: `--brawo-light-soft`, `--brawo-dark-faint`, `--brawo-chrome-border`.

## Foreground rules

| Context | Token |
|---------|-------|
| Text on accent-filled buttons/badges | `--brawo-on-accent` |
| Links and accent text on light stage | `--brawo-accent-on-light` |
| Accent text on chrome (navbar, sidebar) | `--brawo-accent-on-dark` |
| Hover accent on light stage | `--brawo-accent-strong-on-light` |
| Secondary / muted body text | `--brawo-dark-soft` |
| Muted text on chrome | `--brawo-chrome-faint` |
| Default body text on stage | `--brawo-dark` |
| Default text on chrome | `--brawo-light` |

## Semantic colors

Success, warning, and error are **fixed** OKLCH values — not derived from accent. Use for alerts, validation, and status only:

- `--brawo-success` / `-soft` / `-faint`
- `--brawo-warning` / `-strong` / `-soft` / `-faint`
- `--brawo-error` / `-strong` / `-soft` / `-faint`
- `--brawo-info-soft` / `-faint`

## Layout and radius tokens

| Token | Value | Use |
|-------|-------|-----|
| `--brawo-admin-sidebar-width` | `12.5rem` | Sidebar column |
| `--brawo-admin-navbar-height` | `3.5rem` | Navbar min-height |
| `--brawo-admin-layout-gap` | `0.75rem` | Shell grid gap |
| `--brawo-admin-chrome-inset` | `0.25rem` | Body padding on chrome |
| `--brawo-page-builder-outline-width` | `17.5rem` | Outline column |
| `--brawo-radius-xs` | `0.375rem` | Small controls |
| `--brawo-radius-sm` | `0.25rem` | Field preview boxes |
| `--brawo-radius-md` | `0.4375rem` | Small buttons, block headers |
| `--brawo-radius` | `0.5rem` | Cards, panels |
| `--brawo-radius-lg` | `0.625rem` | Empty states, Coloris picker |
| `--brawo-radius-pill` | `62.4375rem` | Pills, toggles |
| `--brawo-border-width` | `1px` | Hairline borders (sole px token) |
| `--brawo-border-width-thick` | `0.125rem` | Dashed upload zones |

## Shadows

| Token | Use |
|-------|-----|
| `--brawo-shadow-sm` | Subtle elevation (edit buttons) |
| `--brawo-shadow-md` | Dropdowns, Coloris picker |
| `--brawo-shadow-focus` | Focus ring (`0 0 0 1px accent`) |
| `--brawo-shadow-focus-offset` | Form control focus offset |
| `--brawo-shadow-preview` | Preview panel slide-in |
| `--brawo-shadow-toggle` | Toggle slider knob |

Inline shadows should use `color-mix(in oklch, var(--brawo-dark) N%, transparent)` — never raw rgba/hex.

## Unit policy

- **Sizing and spacing:** `rem` or `var(--brawo-*)`
- **Borders:** `var(--brawo-border-width)` or `var(--brawo-border-width-thick)`
- **Radii:** `var(--brawo-radius-*)`
- **Breakpoints:** `62rem` (not `992px`)
- **Allowed px exceptions:** `--brawo-border-width`, `--brawo-sr-only-size` in `variables.css` only; 3D `translateZ` values use rem tokens

## Bootstrap bridge

[`bootstrap_overrides.css`](../../app/assets/stylesheets/brawo_cms/admin/bootstrap_overrides.css) maps Bootstrap variables to `--brawo-*` under `.brawo-admin`. Prefer Bootstrap utility classes for simple forms; add custom CSS only when Bootstrap defaults are insufficient.

## Scoping

- All admin UI lives under `.brawo-admin` (set on `<body>`).
- Do not override Bootstrap globally outside that wrapper.
- Page builder selectors use `.page-builder*` and are loaded after field styles.

## File map

Entry manifest: [`admin.css`](../../app/assets/stylesheets/brawo_cms/admin.css).

| Path | Contents |
|------|----------|
| `admin/variables.css` | Design tokens |
| `admin/shell/layout.css` | Body, shell grid |
| `admin/shell/sidebar.css` | Sidebar nav |
| `admin/shell/stage.css` | Main stage, preview panel |
| `admin/shell/navbar.css` | Navbar + toggle chrome overrides |
| `admin/bootstrap_overrides.css` | Bootstrap → `--brawo-*` mapping |
| `admin/icons.css` | Icon sizing |
| `admin/components/primitives.css` | Status, cards, tables, page titles |
| `admin/components/content_meta.css` | Inline title/slug edit |
| `admin/components/content_header_fields.css` | Header fields card |
| `admin/components/field_tabs.css` | Content form field tabs |
| `admin/fields/shared.css` | Field wrappers, validation |
| `admin/fields/toggle.css` | Boolean toggle widget |
| `admin/fields/color.css` | Color picker + Coloris |
| `admin/fields/icon.css` | Icon picker |
| `admin/fields/url.css` | URL field |
| `admin/fields/media.css` | Media grid, picker, upload |
| `admin/fields/repeater.css` | Repeater rows |
| `admin/page_builder/canvas.css` | Block canvas, toolbar |
| `admin/page_builder/outline.css` | Outline panel |
| `admin/page_builder/responsive.css` | Mobile breakpoints |

Load order: shell layout → bootstrap → components → fields → navbar overrides → page builder.

## Field CSS convention

Field-specific styles live in `admin/fields/<type>.css`, mirroring `app/models/brawo_cms/fields/`. One file per field type that needs custom CSS. Shell/context overrides (e.g. navbar consuming a toggle) go in `admin/shell/`, not in the field file.

| CSS file | Field class |
|----------|-------------|
| `fields/toggle.css` | `BooleanField` |
| `fields/color.css` | `ColorField` |
| `fields/icon.css` | `IconField` |
| `fields/url.css` | `UrlField` |
| `fields/media.css` | `MediaField` |
| `fields/repeater.css` | `RepeaterField` |

Fields without custom markup (string, text, number, etc.) have no CSS file — they use Bootstrap defaults.

## Adding new styles

1. Add a token to `variables.css` if the value will be reused.
2. Pick the file: `components/`, `fields/<type>.css`, `shell/`, or `page_builder/`.
3. Scope under `.brawo-admin` (or the relevant component root).
4. Use `var(--brawo-*)` for all colors, radii, borders, and layout dimensions.
5. No raw hex/oklch outside `variables.css`.
