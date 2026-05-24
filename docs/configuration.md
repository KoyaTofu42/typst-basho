# Configuration

The `config` parameter on `#tate()` accepts a nested dictionary. `merge-config` deep-merges it with `default-opts`, so you only need to specify overrides:

```typst
#tate(config: (
  sizing: (char-box: 1.2em),
  layout: (columns: 3, gap: 0.8em),
))[...]
```

Arrays (like `kinsoku`, `tcy`, `rendering`) are replaced wholesale — intentionally, so you can swap out entire module arrays.

## Default config

```typst
#(
  font: none,
  features: ("vert", "vrt2"),

  sizing: (
    char-box: 1em,
    ruby-size: 0.5em,
    ruby-offset: 1em,
    heading-scales: (1.5, 1.3, 1.15),
  ),

  categories: (
    classify: (text, config) => {
      if text.match(regex("^[0-9]{1,2}$")) != none { return "horizontal" }
      return "rotated"
    },
  ),

  layout: (
    columns: 1,
    gap: 1em,
    column-gap: 2em,
    hooks: (),
  ),

  kinsoku: default-resolver(),

  tcy: (default-tcy(),),

  rendering: (
    default-rendering-params(),
    default-spacing(),
    default-turn,
    default-vblock,
    default-hblock,
  ),

  list: (
    bullet: default-bullet-list-params(),
    numbered: default-numbered-list-params(),
  ),
)
```

## Factory functions

### `default-sizing-params(char-box, ruby-size, ruby-offset, heading-scales)`

| Parameter | Default | Description |
|---|---|---|
| `char-box` | `1em` | Width/height of each character box |
| `ruby-size` | `0.5em` | Font size for ruby (furigana) text |
| `ruby-offset` | `1em` | Horizontal offset of ruby text from the left edge |
| `heading-scales` | `(1.5, 1.3, 1.15)` | Font scale factors for h1, h2, h3 |

### `default-layout-params(columns, gap, column-gap, hooks)`

| Parameter | Default | Description |
|---|---|---|
| `columns` | `1` | Number of horizontal rows (段組み) |
| `gap` | `1em` | Gap between columns within a row |
| `column-gap` | `2em` | Gap between rows (vertical) |
| `hooks` | `()` | Array of custom page layout functions |

### `default-categories(classify)`

| Parameter | Default | Description |
|---|---|---|
| `classify` | sees `^[0-9]{1,2}$` | `(text, config) => "horizontal" \| "rotated" \| "char"` |

### `default-rendering-params(dash-scale, node-renderers)`

| Parameter | Default | Description |
|---|---|---|
| `dash-scale` | `1.25em` | Font size for the horizontal-bar character (―) |
| `node-renderers` | `(:)` | Custom token-type renderers |

### `default-spacing()`

Inserts gaps between CJK and European text. No parameters.

## Override examples

### Custom TCY classification

```typst
#tate(config: (
  categories: (
    classify: (text, config) => {
      if text.len() <= 3 { return "horizontal" }
      return "rotated"
    },
  ),
))[...]
```

### Replace TCY module

```typst
#tate(config: (
  tcy: (my-custom-tcy()),
))[...]
```

### Replace a rendering transform

```typst
#tate(config: (
  rendering: (
    default-rendering-params(),
    default-spacing(),
    (transform: tokens => tokens.map(t => {
      if t.type == "char" and t.text == "。" { t.text = "．" }
      t
    })),
    default-turn,
    default-vblock,
    default-hblock,
  ),
))[...]
```
