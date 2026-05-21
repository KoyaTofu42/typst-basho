// src/layout.typ
// Vertical layout with auto-pagination, RTL multi-column, and kinsoku shori (Phase 5)

#import "renderer.typ": render-char-token
#import "kinsoku.typ": apply-kinsoku

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
/// (absolute length). Uses pre-measured token heights for accuracy.
///
/// - tokens (array): Array of token dictionaries.
/// - heights (array): Parallel array of absolute heights per token.
/// - max-height (length): Maximum column height as absolute length.
/// -> array: Array of arrays, each sub-array is one column's tokens.
#let paginate(tokens, heights, max-height) = {
  let columns = ((),)
  let current-height = 0pt

  for (i, token) in tokens.enumerate() {
    if token.type == "newline" {
      // Newline forces a column break
      columns.push(())
      current-height = 0pt
    } else {
      let h = heights.at(i)
      if current-height > 0pt and current-height + h > max-height {
        // Doesn't fit — start a new column
        columns.push(())
        current-height = 0pt
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

#let _pagination-state = state("basho-pagination", none)

/// Main layout entry point. Two-pass approach:
/// Pass 1: place() measures page dims + actual token heights, stores columns in state.
/// Pass 2: context block reads pre-computed columns and renders with pagebreaks.
///
/// - tokens (array): Array of token dictionaries.
/// - font (str): Font family name.
/// - gap (length): Horizontal gap between columns.
/// -> content: Fully paginated vertical text.
#let layout-tate(tokens, font, gap: 1em) = {
  if tokens.len() == 0 {
    return []
  }

  // Return as content block with suppressed paragraph/block spacing.
  // Without this, place() adds paragraph spacing before the render context,
  // creating a visible blank gap at the top/bottom of each page.
  [
    #set par(spacing: 0pt)
    #set block(spacing: 0pt)

    // Pass 1: measure page dimensions and actual token heights.
    // place() takes zero flow space.
    #place(context {
      layout(size => {
        // Measure actual rendered height of each token
        let heights = tokens.map(token => {
          if token.type == "newline" {
            0pt
          } else {
            measure(render-char-token(token, font)).height
          }
        })

        let gap-abs = measure(h(gap)).width
        let col-slot = measure(box(width: 1em)).width + gap-abs
        let max-cols = calc.max(1, calc.floor(size.width / col-slot))

        // Paginate using actual measured heights, then apply kinsoku rules
        let cols = apply-kinsoku(paginate(tokens, heights, size.height))

        _pagination-state.update((
          cols: cols,
          max-cols: max-cols,
        ))
      })
    })

    // Pass 2: read pre-computed columns and render with real pagebreaks.
    #context {
      let info = _pagination-state.get()
      if info == none {
        return []
      }

      let cols = info.cols
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
  ]
}

/// Convenience wrapper (backward compat).
#let render-tokens(tokens, font, gap: 1em) = {
  layout-tate(tokens, font, gap: gap)
}

