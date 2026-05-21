// src/layout.typ
// Vertical layout with auto-pagination, RTL multi-column, and kinsoku shori

#import "renderer.typ": render-char-token

/// Renders a single column of tokens as a top-to-bottom vertical stack.
///
/// - tokens (array): Array of token dictionaries for this column.
/// - font (str): Font family name.
/// - config (dictionary): Layout configuration.
/// -> content: A vertical stack of rendered character boxes.
#let render-column(tokens, font, config) = {
  if tokens.len() == 0 {
    // Empty column gets a minimum-height placeholder to preserve spacing
    return box(width: config.sizing.char-box, height: config.sizing.char-box)
  }

  let rendered = tokens.map(token => render-char-token(token, font, config))

  stack(
    dir: ttb,
    spacing: 0pt,
    ..rendered,
  )
}

/// Splits a flat token array into column groups based on a maximum height
/// (absolute length). Uses pre-measured token heights for accuracy,
/// and consults config.kinsoku module array for line-breaking decisions.
///
/// - tokens (array): Array of token dictionaries.
/// - heights (array): Parallel array of absolute heights per token.
/// - max-height (length): Maximum column height as absolute length.
/// - config (dictionary): The layout configuration.
/// -> array: Array of arrays, each sub-array is one column's tokens.
#let paginate(tokens, heights, max-height, config) = {
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
      // Column is full — consult kinsoku modules in order.
      // First non-"break" result wins.
      let decision = (action: "break")
      for rules in config.kinsoku {
        let d = (rules.decide)(current-col, token, rules)
        if d.action != "break" {
          decision = d
          break
        }
      }

      if decision.action == "hang" {
        let hanging-token = token
        hanging-token.type = "hanging"
        current-col.push(hanging-token)
        columns.push(current-col)
        current-col = ()
        current-height = 0pt
        i += 1
        continue
      } else if decision.action == "pull-in" {
        let pull-token = token
        pull-token.type = "hanging"
        current-col.push(pull-token)
        columns.push(current-col)
        current-col = ()
        current-height = 0pt
        i += 1
        continue
      } else if decision.action == "push-out" {
        let count = decision.count
        if current-col.len() >= count {
          let popped = ()
          while count > 0 {
            popped.insert(0, current-col.pop())
            count -= 1
          }
          columns.push(current-col)
          current-col = popped + (token,)
          current-height = heights.slice(i - decision.count, i + 1).sum()
        } else {
          columns.push(current-col)
          current-col = (token,)
          current-height = h
        }
        i += 1
        continue
      }
      
      // Normal break (all modules returned "break")
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
/// - config (dictionary): The layout configuration.
/// -> content: RTL-arranged vertical columns.
#let render-page(cols, font, gap, config) = {
  // Check layout hooks — last one wins
  if config.layout.hooks.len() > 0 {
    return config.layout.hooks.last()(cols, font, gap, config)
  }
  let rendered = cols.map(col => render-column(col, font, config))
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
/// - config (dictionary): Configuration dictionary.
/// -> content: Fully paginated vertical text.
#let layout-tate(tokens, config) = {
  if tokens.len() == 0 {
    return []
  }

  [
    #set par(spacing: 0pt)
    #set block(spacing: 0pt)

    // Pass 1: measure page dimensions and actual token heights.
    #place(context {
      layout(size => {
        let heights = tokens.map(token => {
          if token.type == "newline" {
            0pt
          } else {
            measure(render-char-token(token, config.font, config)).height
          }
        })

        let col-gap-abs = measure(v(config.layout.column-gap)).height
        let usable-height = (size.height - (config.layout.columns - 1) * col-gap-abs) / config.layout.columns

        let gap-abs = measure(h(config.layout.gap)).width
        let col-slot = measure(box(width: config.sizing.char-box)).width + gap-abs
        let max-cols = calc.max(1, calc.floor(size.width / col-slot))

        let cols = paginate(tokens, heights, usable-height, config)

        _pagination-state.update((
          cols: cols,
          max-cols: max-cols,
          config: config,
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
      
      let cols-per-page = info.max-cols * info.config.layout.columns

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
          rows.push(render-page(row-cols, info.config.font, info.config.layout.gap, info.config))
          r += info.max-cols
        }
        
        result += stack(
          dir: ttb,
          spacing: info.config.layout.column-gap,
          ..rows
        )
        
        i += cols-per-page
      }
      result
    }
  ]
}

/// Convenience wrapper (backward compat).
#import "config.typ": default-opts, merge-config
#let render-tokens(tokens, font, gap: 1em, columns: 1, column-gap: 2em) = {
  let cfg = merge-config(default-opts, (font: font, layout: (gap: gap, columns: columns, column-gap: column-gap)))
  layout-tate(tokens, cfg)
}
