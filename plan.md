# Basho — Vertical Japanese Typesetting for Typst

## Package Structure

```
basho/
├── typst.toml          # Package manifest (entrypoint = "lib.typ")
├── lib.typ             # Public API: tate(), tcy(), ruby()
├── README.md
└── src/
    ├── renderer.typ    # Char boxes, OpenType vert/vrt2, TCY rotation
    ├── parser.typ      # String → token array conversion
    ├── layout.typ      # Columns, pagination, multi-page breaking
    ├── kinsoku.typ     # Japanese line-breaking rules
    ├── ruby.typ        # Furigana rendering (0.5em beside base char)
    └── flatten.typ     # content.fields() tree traversal → tokens
```

**Token schema** (shared across all modules):
```typ
(
  type: "char" | "tcy" | "ruby" | "newline" | "space",
  text: "あ",
  base: "学",       // ruby only
  bold: false,
  italic: false,
  width: 1em,
  height: 1em,
)
```

---

## Phase 1 — Scaffolding & Single-Column Rendering

**Goal**: Render any string top-to-bottom, one character per 1em×1em box with OpenType vertical glyph features.

**Files**: `typst.toml`, `lib.typ`, `src/renderer.typ`, `src/parser.typ`, `src/layout.typ`

**Implementation**:
- `src/renderer.typ`:
  - `char-box(body, font)` — wrap each char in `box(width: 1em, height: 1em, text(font: font, features: ("vert", "vrt2"), body))`
  - `render-char-token(token, font)` — dispatches per token type (stub for `"char"` only)
- `src/parser.typ`:
  - `tokenize(str)` — splits string into `(type: "char", text: ch)` dicts
- `src/layout.typ`:
  - `render-tokens(tokens, font)` — maps tokens → rendered boxes, `stack(dir: ttb, spacing: 0pt, ..)`
- `lib.typ`:
  - `#let tate(body, font: "Harano Aji Mincho") = context { render-tokens(tokenize(body), font) }`
  - `font` parameter defaults to "Harano Aji Mincho" (bundled with Typst); users can override with any installed CJK font
  - Note: `context` from the start so Phase 4 page.height integration is seamless

**Edge cases**: empty string → empty content. Non-printable code points → pass through.

**Verify**: `#tate["日本語"]` → 3 vertical chars in 1em boxes.

---

## Phase 2 — Multi-line RTL Layout (Manual Columns)

**Goal**: `\n` in input splits into right-to-left columns.

**Implementation**:
- `src/layout.typ`:
  - `columns(children, gap: 1em)` — wraps each in `box(width: auto)`, arranges via `stack(dir: rtl, spacing: gap)`
  - Update `render-tokens`: split array on `type: "newline"` into column groups
- `parser.typ`:
  - Insert `(type: "newline", text: "\n")` sentinel tokens at `\n` positions

**Edge cases**: consecutive `\n` → empty column (`box(height: 1em)`). Leading/trailing → empty edge columns.

**Verify**: `"ABC\nDEF"` → 2 columns, RTL, "DEF" right, "ABC" left.

---

## Phase 3 — Tokenization & TCY (Tate-chu-yoko)

**Goal**: Consecutive Latin chars/numbers rotate 90° inline.

**Implementation**:
- `src/parser.typ`: 
  - Iterates through clusters via `tokenize(input)`. 
  - Accumulates consecutive ASCII Latin/digit characters (`regex("^[A-Za-z0-9]+$")`) into a buffer.
  - Flushes the buffer as a single `(type: "tcy", text: buf)` token.
- `src/renderer.typ`:
  - `render-tcy(token, font)` — renders the TCY block using `rotate(90deg, reflow: true, text(token.text))` centered inside a `box(width: 1em)`.
  - `render-char-token` dispatches `"char"` → `char-box`, `"tcy"` → `render-tcy`.

**Edge cases**: Mixed CJK/TCY boundaries are handled correctly via the buffer flush. Empty TCY group → skip.

**Verify**: `"abc日本語123"` → "abc" and "123" rotated 90°, CJK upright.

---

## Phase 4 — Pagination Engine (Auto Column Breaks)

**Goal**: Auto-break tokens into columns by page height. Multi-page overflow via `pagebreak()`.

**Implementation**:
- `src/layout.typ`:
  - `paginate(tokens, max-lines)` — partition into column slices
  - `layout-tate(tokens)` — uses `place(context { layout(size => ...) })` to perform two-pass layout:
    1. Pass 1: `measure()` the exact absolute height of every token.
    2. Paginate tokens into column slices based on exact measured heights versus `size.height`, storing them in `state`.
    3. Pass 2: reads the columns from `state` and maps them to `render-page`.
    4. Multi-page handled via `pagebreak()`.
  - Suppressed paragraph spacing via `#set par(spacing: 0pt)` and `#set block(spacing: 0pt)` within the markup block to prevent blank gaps at page boundaries.

**Edge cases**: Token taller than page → overflow. Exact fill → no extra break. Long content → page break + continuation.

**Verify**: 80 chars on 20-line page → 4 cols. More → page break.

---

## Phase 5 — Kinsoku Shori

**Goal**: No opening brackets at column bottom; closing chars hang into gutter.

**Implementation** (`src/kinsoku.typ`):
- Character sets: `opening`, `closing`, `hanging` (regex patterns)
- `apply-kinsoku(columns)`:
  1. If column ends with an opening bracket → move to next column.
  2. If next column starts with a closing/period char → append to current as hanging punctuation.
  3. Hanging rendered via `box(height: 0pt)` to visually overflow into the gutter without affecting column length.
- `src/renderer.typ`: Opening brackets are aligned right, closing brackets are aligned left within their 1em bounds.

**Verify**: `（` at col-bottom → moves to next. `。` at col-top → hangs on prev.

---

## Phase 6 — Ruby (Furigana)

**Goal**: Phonetic readings at 0.5em beside base char.

**Implementation** (`src/ruby.typ` & `src/char-box.typ`):
- Extracted `char-box` to `src/char-box.typ` to avoid cyclic import dependencies.
- `render-ruby(token)`:
  - Supports Group Ruby (Jukugo ruby) by accepting multiple base characters.
  - Dynamically calculates the overall block height using `calc.max(base-height, ruby-height)` to prevent long mono ruby from overlapping into adjacent kanji.
  - Vertically centers both the stacked base characters and stacked ruby characters within the expanded bounds.
  - Ruby text flows into the right-side gutter (`dx: 1em`) so the 1em column pitch is preserved flawlessly.

**Edge cases**: Grouped ruby prevents overlap natively. Long mono ruby expands vertically. Empty ruby → renders base only.

**Verify**: `今日` rendered with grouped `きょう`, `漢` rendered with `かんじ` centered without overlapping adjacent text.

---

## Phase 7 — Content Flattener & API Finalization

**Goal**: Accept native Typst content via `content.fields()`. Support `*bold*`, inline macros.

**Implementation** (`src/flatten.typ`):
- `flatten(content)` — recurses via `.func()` for type checks, `.fields()` / named accessors for data:
  - `text` (`.func() == text`) → extract `el.text` → `type: "char"`
  - `strong` (`.func() == strong`) → recurse on `el.body`, `bold: true`
  - `emph` (`.func() == emph`) → recurse on `el.body`, `italic: true`
  - `sequence` → recurse on `el.children`
  - Custom with `tcy: true` → `type: "tcy"`
  - Custom with `ruby: true` → `type: "ruby"`
- `lib.typ` inline macros:
  ```typ
  #let tcy(body) = (tcy: true, body: text(body))
  #let ruby(base, rt) = (ruby: true, base: base, text: rt)
  #let tate(body) = context { layout-tate(flatten(body)) }
  ```

**Edge cases**: Images/tables → skip. Deep nesting → recursion limit. Empty → `[]`.

---

## Dependencies Graph

```
lib.typ
  ├── flatten.typ
  │     └── parser.typ (token types)
  ├── layout.typ
  │     ├── renderer.typ
  │     └── kinsoku.typ
  ├── parser.typ
  └── ruby.typ
```

## Key Design Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Page overflow | Multi-page with `pagebreak()` | Matches `columns(n)` behavior |
| vert/vrt2 fallback | None | Presumes suitable CJK font |
| Column bottom align | Top-stack | Not a priority |
| Content traversal | `.fields()` | Native UX |
| Height default | `auto` → `page.height` | Full-page fill |
