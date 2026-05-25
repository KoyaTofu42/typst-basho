# Module Contracts

Basho uses a Dependency Injection architecture. Each subsystem is a self-contained dictionary that exposes predictable keys and function signatures. This document defines the contract for each module type.

## TCY module

A TCY module classifies auto-detected Latin/digit runs and handles forced TCY, rotated, and upright modes.

### Contract

```typst
(
  pattern: regex,         // regex matching TCY-eligible characters
  sizes: (1em, 0.65em, 0.5em),  // font sizes for len≤2, len==3, len≥4
  filter: (tokens, config) => tokens,  // classification function
)
```

### Built-in

- `default-tcy(pattern:, sizes:)` — the default module

### Custom example

```typst
#let my-tcy() = (
  pattern: regex("^[A-Za-z0-9]+$"),
  sizes: (0.9em, 0.6em, 0.45em),
  filter: (tokens, config) => {
    tokens.map(t => {
      if t.type != "tcy" { return t }
      // custom classification logic
      t
    })
  },
)
```

## Rendering module

A rendering module provides token transforms and/or custom node renderers.

### Contract

```typst
(
  transform: (tokens, config) => tokens,   // optional: token array mutation
  node-renderers: (                 // optional: custom token renderers
    "<token-type>": (token, config) => content,
  ),
)
```

Both keys are optional. A module can provide one, the other, or both.

### Built-in

| Module | transform | node-renderers |
|---|---|---|
| `default-rendering-params()` | Dash normalization (— → ―) | — |
| `default-spacing()` | CJK/European gap insertion | `"spacing"` |
| `default-turn` | — | `"turn"` |
| `default-vblock` | — | `"vblock"` |
| `default-hblock` | — | `"hblock"` |
| `default-bullet-list-params()` | — | `"bullet-list-marker"` |
| `default-numbered-list-params()` | — | — |

### Custom example

```typst
(let custom-transform = (
  transform: (tokens, config) => tokens.map(t => {
    if t.type == "char" and t.text == "。" { t.text = "．" }
    t
  }),
))
```

## Kinsoku module

The kinsoku resolver controls Japanese line-breaking behavior.

### Contract

```typst
(
  forbidden-start: str,            // characters that must not start a column
  forbidden-end: str,              // characters that must not end a column
  hanging: str,                    // characters eligible for burasagari
  unbreakable-chars: str,          // characters that form unsplittable pairs
  compressible-punctuation: str,   // characters eligible for oikomi compression
  mode: "burasagari" | "oikomi",   // line-breaking strategy
  compression-per-punct: float,    // max compression per punct (× char-box)
  consecutive-compression: float,  // extra compression for consecutive pairs
  resolve: (col, token, h, config, cur-h, max-h) => (
    action: "burasagari" | "oikomi" | "push-previous" | "oidashi",
    compression-amount: length,    // only for oikomi
  ),
)
```

### Built-in

- `default-resolver(...)` — see [kinsoku.md](kinsoku.md)

## List module

A list module provides flatten logic and optional node renderers for list items.

### Contract (bullet)

```typst
(
  marker: str,                                    // bullet glyph
  flatten: (node, inner-flatten, config) => tokens,
  node-renderers: (                               // must include "bullet-list-marker"
    "bullet-list-marker": (token, config) => content,
  ),
)
```

### Contract (numbered)

```typst
(
  format: (int) => str,                           // number formatter
  gap: length,                                    // space after number before text
  flatten: (node, inner-flatten, config) => tokens,
  node-renderers: (:),                            // optional (empty by default)
)
```

### Built-in

- `default-bullet-list-params(marker:)`
- `default-numbered-list-params(format:, gap:)`

## Custom module loading

Register custom modules through `config` when calling `#tate()`:

```typst
#tate(config: (
  tcy: (my-custom-tcy(),),
  rendering: (
    default-rendering-params(),
    my-transform,
    default-turn,
    default-vblock,
    default-hblock,
  ),
  kinsoku: my-resolver,
  list: (
    bullet: my-bullet-module,
    numbered: my-numbered-module,
  ),
))[...]
```
