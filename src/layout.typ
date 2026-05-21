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

#import "kinsoku.typ": is-opening, is-closing, is-hanging

/// Splits a flat token array into column groups based on a maximum height
/// (absolute length). Uses pre-measured token heights for accuracy,
/// and natively integrates kinsoku shori (line breaking rules) sequentially
/// to ensure text reflows correctly without leaving gaps.
///
/// - tokens (array): Array of token dictionaries.
/// - heights (array): Parallel array of absolute heights per token.
/// - max-height (length): Maximum column height as absolute length.
/// -> array: Array of arrays, each sub-array is one column's tokens.
#let paginate(tokens, heights, max-height) = {
  let columns = ()
  let current-col = ()
  let current-height = 0pt
  
  let i = 0
  while i < tokens.len() {
    let token = tokens.at(i)
    let h = heights.at(i)
    
    if token.type == "newline" {
      columns.push(current-col)
      current-col = ()
      current-height = 0pt
      i += 1
      continue
    }
    
    if current-height > 0pt and current-height + h > max-height {
      // Column is full
      
      // 1. Kinsoku check: if current token is hanging punctuation (comma/period), pull it in
      if is-hanging(token) {
        let hanging-token = token
        hanging-token.type = "hanging"
        current-col.push(hanging-token)
        columns.push(current-col)
        current-col = ()
        current-height = 0pt
        i += 1
        continue
      }
      
      // 2. Kinsoku check: if current token is closing (small kana, chōonpu, brackets),
      // we must NOT start the next line with it. We push the LAST token of current-col
      // to the next line (Oidashi / 追い出し).
      if is-closing(token) {
        if current-col.len() > 0 {
          let popped = current-col.pop()
          columns.push(current-col)
          current-col = (popped, token)
          current-height = heights.at(i - 1) + h
        } else {
          columns.push(())
          current-col = (token,)
          current-height = h
        }
        i += 1
        continue
      }
      
      // 3. Kinsoku check: if last token in current column is an opening bracket, push it out
      if current-col.len() > 0 and is-opening(current-col.last()) {
        let popped = current-col.pop()
        columns.push(current-col)
        current-col = (popped, token)
        current-height = heights.at(i - 1) + h
        i += 1
        continue
      }
      
      // Normal break
      columns.push(current-col)
      current-col = (token,)
      current-height = h
    } else {
      current-col.push(token)
      current-height += h
    }
    
    i += 1
  }
  
  if current-col.len() > 0 {
    columns.push(current-col)
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
#let layout-tate(tokens, font, gap: 1em, columns: 1, column-gap: 2em) = {
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

        let usable-height = (size.height - (columns - 1) * column-gap) / columns

        let gap-abs = measure(h(gap)).width
        let col-slot = measure(box(width: 1em)).width + gap-abs
        let max-cols = calc.max(1, calc.floor(size.width / col-slot))

        // Paginate using actual measured heights into the usable height segments.
        // Kinsoku shori is integrated natively inside the pagination algorithm.
        let cols = paginate(tokens, heights, usable-height)

        _pagination-state.update((
          cols: cols,
          max-cols: max-cols,
          columns: columns,
          column-gap: column-gap,
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
      
      let cols-per-page = info.max-cols * info.columns

      while i < cols.len() {
        if i > 0 {
          result += colbreak()
        }
        
        let page-end = calc.min(i + cols-per-page, cols.len())
        let page-slices = cols.slice(i, page-end)
        
        let rows = ()
        let r = 0
        while r < page-slices.len() {
          let row-end = calc.min(r + info.max-cols, page-slices.len())
          let row-cols = page-slices.slice(r, row-end)
          rows.push(render-page(row-cols, font, gap))
          r += info.max-cols
        }
        
        result += stack(
          dir: ttb,
          spacing: info.column-gap,
          ..rows
        )
        
        i += cols-per-page
      }
      result
    }
  ]
}

/// Convenience wrapper (backward compat).
#let render-tokens(tokens, font, gap: 1em, columns: 1, column-gap: 2em) = {
  layout-tate(tokens, font, gap: gap, columns: columns, column-gap: column-gap)
}

