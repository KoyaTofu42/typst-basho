// src/layout.typ
// Vertical layout with auto-pagination and RTL multi-column support (Phase 4)

#import "renderer.typ": render-char-token

/// Estimates the vertical height of a token in em units.
/// "char" tokens are 1em; "tcy" tokens scale by character count.
///
/// - token (dictionary): A token dictionary.
/// -> float: Estimated height in em units.
#let token-height-em(token) = {
  if token.type == "tcy" {
    // Rotated Latin text: approximate width-per-char ~0.6em becomes height
    calc.max(1, token.text.clusters().len() * 0.6)
  } else {
    1
  }
}

/// Renders a single column of tokens as a top-to-bottom vertical stack.
///
/// - tokens (array): Array of token dictionaries for this column.
/// - font (str): Font family name.
/// -> content: A vertical stack of rendered character boxes.
#let render-column(tokens, font) = {
  if tokens.len() == 0 {
    // Empty column gets a minimum-height placeholder to preserve spacing
    return box(width: 1em, height: 1em)
  }

  let rendered = tokens.map(token => render-char-token(token, font))

  stack(
    dir: ttb,
    spacing: 0pt,
    ..rendered,
  )
}

/// Splits a flat token array into column groups based on a maximum height
/// (in em units). Newline tokens force a column break.
///
/// - tokens (array): Array of token dictionaries.
/// - max-height-em (float): Maximum column height in em units.
/// -> array: Array of arrays, each sub-array is one column's tokens.
#let paginate(tokens, max-height-em) = {
  let columns = ((),)
  let current-height = 0

  for token in tokens {
    if token.type == "newline" {
      // Newline forces a column break
      columns.push(())
      current-height = 0
    } else {
      let h = token-height-em(token)
      if current-height > 0 and current-height + h > max-height-em {
        // Doesn't fit — start a new column
        columns.push(())
        current-height = 0
      }
      columns.last().push(token)
      current-height += h
    }
  }
  columns
}

/// Renders a single page worth of columns arranged RTL.
///
/// - cols (array): Array of column token arrays for this page.
/// - font (str): Font family name.
/// - gap (length): Horizontal gap between columns.
/// -> content: RTL-arranged vertical columns.
#let render-page(cols, font, gap) = {
  let rendered = cols.map(col => render-column(col, font))
  align(right + top,
    stack(
      dir: rtl,
      spacing: gap,
      ..rendered,
    )
  )
}

/// Main layout entry point. Uses a two-pass approach:
/// Pass 1: measure page dimensions via layout() inside place() (zero flow space).
/// Pass 2: read state, paginate, and render with real pagebreaks.
///
/// - tokens (array): Array of token dictionaries.
/// - font (str): Font family name.
/// - gap (length): Horizontal gap between columns.
/// -> content: Fully paginated vertical text.
#let layout-tate(tokens, font, gap: 1em) = {
  if tokens.len() == 0 {
    return []
  }

  let _pagination-state = state("basho-pagination", none)

  // Pass 1: measure page dimensions.
  // Wrapped in block(spacing/below: 0pt) to suppress paragraph spacing
  // that would otherwise create a blank gap before the rendered content.
  // place() inside takes zero flow space.
  block(spacing: 0pt, below: 0pt, context {
    place(layout(size => {
      let em-abs = measure(box(width: 1em, height: 1em)).width
      let gap-abs = measure(h(gap)).width
      let max-height-em = calc.max(1, calc.floor(size.height / em-abs))
      let col-slot = em-abs + gap-abs
      let max-cols = calc.max(1, calc.floor(size.width / col-slot))

      _pagination-state.update((
        max-height-em: max-height-em,
        max-cols: max-cols,
      ))
    }))
  })

  // Pass 2: read state and render with real pagebreaks.
  // Must be bare context (not inside block) so pagebreak() works.
  context {
    let info = _pagination-state.get()
    if info == none {
      return []
    }

    let cols = paginate(tokens, info.max-height-em)

    // Group columns into pages
    let result = []
    let i = 0
    while i < cols.len() {
      if i > 0 {
        result += pagebreak()
      }
      let end = calc.min(i + info.max-cols, cols.len())
      let page-cols = cols.slice(i, end)
      result += render-page(page-cols, font, gap)
      i += info.max-cols
    }
    result
  }
}

/// Convenience wrapper (backward compat).
#let render-tokens(tokens, font, gap: 1em) = {
  layout-tate(tokens, font, gap: gap)
}

