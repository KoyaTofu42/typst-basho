# Layout hooks

Override page-level layout by injecting a hook into `config.layout.hooks`:

```typst
config: (
  layout: (hooks: (
    (cols, font, gap, config) => {
      // Custom page layout
      // cols: array of column token arrays for this page
      // font: the configured font
      // gap: horizontal gap between columns
      // config: the full Basho configuration
      // Returns: content (the page layout)
    },
  )),
)
```

The last hook wins. When no hook is set, the default layout stacks columns RTL with `align(right + top)`.

## Example: custom column styles

```typst
config: (
  layout: (hooks: (
    (cols, font, gap, config) => {
      let rendered = cols.map(col => {
        stack(dir: ttb, spacing: 0pt,
          ..col.map(token => render-char-token(token, config))
        )
      })
      align(right + top, stack(dir: rtl, spacing: gap, ..rendered))
    },
  )),
)
```

# List modules

Built-in list modules are self-contained dictionaries with a `flatten` function and `node-renderers`. Users can replace them entirely:

```typst
config: (
  list: (
    bullet: (marker: "•", flatten: ..., node-renderers: ...),
    numbered: (format: n => "(" + str(n) + ")", ...),
  ),
)
```

## Bullet list

| Field | Type | Description |
|---|---|---|
| `marker` | `str` | Bullet character (default: `"•"`) |
| `gap` | `length` | Space between marker and text (default: `0.5em`) |
| `flatten` | function | Custom flatten logic |
| `node-renderers` | dictionary | Custom renderers for list tokens |

## Numbered list

| Field | Type | Description |
|---|---|---|
| `format` | function | `(n) => str` — formats the number (default: `n => str(n) + "."`) |
| `gap` | `length` | Space between number and text (default: `0.5em`) |
| `flatten` | function | Custom flatten logic |
| `node-renderers` | dictionary | Custom renderers for list tokens (optional, default `(:)`) |

## See also

- [modules.md](modules.md) — full module contract specifications
- [extending.md](extending.md) — custom module examples and patterns
