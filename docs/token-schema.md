# Token Schema

Every token in Basho is a dictionary with at least a `type` field. Additional fields depend on the token type.

## Common fields

| Field | Type | Description |
|---|---|---|
| `type` | `str` | Token type identifier |
| `text` | `str` or `content` | The text or content payload |
| `bold` | `bool` | Applied by `*strong*` / `#strong[]` |
| `italic` | `bool` | Applied by `_emph_` / `#emph[]` |
| `heading` | `int` or `none` | Heading level (1-3) when inside a heading |
| `dest` | `str` or `none` | Link destination when inside a `#link()` |
| `compression` | `length` | Kinsoku compression amount applied during oikomi |

## Token types

### `char`

A single character rendered in a 1em × 1em box with vertical OpenType features.

```typst
(type: "char", text: "あ")
(type: "char", text: "あ", bold: true, heading: 1)
```

| Field | Required | Description |
|---|---|---|
| `type` | yes | `"char"` |
| `text` | yes | Single character cluster |

### `tcy`

A Tate-chu-yoko run — short horizontal text (numbers, Latin) rendered inline in a vertical column without rotation.

```typst
(type: "tcy", text: "42")
(type: "tcy", text: "1.", forced: true)
```

| Field | Required | Description |
|---|---|---|
| `type` | yes | `"tcy"` |
| `text` | yes | The horizontal text run |
| `forced` | no | `true` or `"char"` — set by `#tcy()` and `#vert()` macros |

### `turn`

Arbitrary content rotated 90° clockwise. Used for inline equations via `$...$`, `#turn[]`, and classified TCY runs.

```typst
(type: "turn", text: content)
```

| Field | Required | Description |
|---|---|---|
| `type` | yes | `"turn"` |
| `text` | yes | The content to rotate |

### `newline`

A line break between columns or items.

```typst
(type: "newline", text: "\n")
```

| Field | Required | Description |
|---|---|---|
| `type` | yes | `"newline"` |
| `text` | yes | `"\n"` |

### `ruby`

A base character with furigana (ruby) annotation on the right side.

```typst
(type: "ruby", text: "漢字", ruby: "かんじ")
```

| Field | Required | Description |
|---|---|---|
| `type` | yes | `"ruby"` |
| `text` | yes | Base text (one or more characters) |
| `ruby` | yes | Ruby annotation text |

### `hanging`

A punctuation character that visually overflows into the gutter (burasagari). Rendered in a zero-height box so column height is unaffected.

```typst
(type: "hanging", text: "。")
```

| Field | Required | Description |
|---|---|---|
| `type` | yes | `"hanging"` |
| `text` | yes | The hanging character |

### `spacing`

An inter-character gap, typically inserted by `default-spacing()` between CJK and European text, or by list modules after item markers.

```typst
(type: "spacing", width: 0.25em)
```

| Field | Required | Description |
|---|---|---|
| `type` | yes | `"spacing"` |
| `width` | yes | Gap width as a length |

### `vblock`

A vertical block — content rotated 90° with unrestricted width. Created by `#vblock[]` and block-level equations.

```typst
(type: "vblock", text: content)
```

| Field | Required | Description |
|---|---|---|
| `type` | yes | `"vblock"` |
| `text` | yes | The block content |

### `hblock`

A horizontal block — content rendered upright (unrotated) in the middle of vertical text, spanning full usable height. Created by `#hblock[]` and unhandled native content.

```typst
(type: "hblock", text: content)
```

| Field | Required | Description |
|---|---|---|
| `type` | yes | `"hblock"` |
| `text` | yes | The block content |

### `heading-anchor`

A zero-size inline bookmark for table-of-contents and PDF outline entries.

```typst
(type: "heading-anchor", level: 1, body: content)
```

| Field | Required | Description |
|---|---|---|
| `type` | yes | `"heading-anchor"` |
| `level` | yes | Heading level (1-3) |
| `body` | yes | The heading text content (for the bookmark) |

### `bullet-list-marker`

A bullet character rendered in a 1em × 1em box. The marker glyph comes from `config.list.bullet.marker`.

```typst
(type: "bullet-list-marker")
```

No extra fields beyond `type`.

## Helper functions

The `src/core/token.typ` module provides helpers for consistent token construction:

### `token(type, fields:)`

Creates a token with the given type and optional fields:

```typst
#token("char", fields: (text: "あ"))
#token("tcy", fields: (text: "42", forced: true))
```

### `merge-token(token, fields)`

Returns a new token with additional fields merged in (non-mutating):

```typst
#merge-token(t, (bold: true))
#merge-token(t, (heading: 1))
```

### `is-token-type(token, type)`

Checks whether a token has a given type:

```typst
#is-token-type(t, "char")
```
