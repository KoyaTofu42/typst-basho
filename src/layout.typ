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

    if token.type == "vblock" or token.type == "hblock" {
      if current-col.len() > 0 {
        columns.push(current-col)
      }
      columns.push((token,))
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

      if decision.action == "hang" or decision.action == "pull-in" {
        let should-forward = false
        if decision.action == "hang" and i + 1 < tokens.len() {
          let next-token = tokens.at(i + 1)
          if next-token.type == "char" {
            for rules in config.kinsoku {
              if rules.forbidden-start.contains(next-token.text) {
                should-forward = true
                break
              }
            }
          }
        }

        if should-forward and current-col.len() > 0 {
          let popped = current-col.pop()
          columns.push(current-col)
          current-col = (popped, token)
          current-height = heights.slice(i - 1, i + 1).sum()
          i += 1
          continue
        }

        let hanging-token = token
        hanging-token.type = "hanging"
        current-col.push(hanging-token)
        i += 1

        // Consume consecutive hang/pull-in tokens at the same overflow boundary.
        while i < tokens.len() {
          let next-token = tokens.at(i)
          let next-height = heights.at(i)

          if next-token.type == "newline" or next-token.type == "vblock" or next-token.type == "hblock" {
            break
          }

          if current-height > 0pt and current-height + next-height > max-height {
            let next-decision = (action: "break")
            for rules in config.kinsoku {
              let d = (rules.decide)(current-col, next-token, rules)
              if d.action != "break" {
                next-decision = d
                break
              }
            }

            if next-decision.action == "hang" or next-decision.action == "pull-in" {
              let extra = next-token
              extra.type = "hanging"
              current-col.push(extra)
              i += 1
              continue
            }
          }

          break
        }

        columns.push(current-col)
        current-col = ()
        current-height = 0pt
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
  align(right + top, stack(
    dir: rtl,
    spacing: gap,
    ..rendered,
  ))
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
          if token.type == "newline" or token.type == "heading-anchor" {
            0pt
          } else {
            measure(render-char-token(token, config.font, config)).height
          }
        })

        let col-gap-abs = measure(v(config.layout.column-gap)).height
        let usable-height = (size.height - (config.layout.columns - 1) * col-gap-abs) / config.layout.columns

        let gap-abs = measure(h(config.layout.gap)).width

        let cfg = config
        cfg.insert("usable-height", usable-height)

        let cols = paginate(tokens, heights, usable-height, cfg)
        let col-widths = cols.map(col => measure(render-column(col, cfg.font, cfg)).width)

        _pagination-state.update((
          cols: cols,
          col-widths: col-widths,
          gap: gap-abs,
          page-width: size.width,
          config: cfg,
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
      let col-widths = info.col-widths
      let result = []
      let i = 0

      let num-segments = info.config.layout.columns

      while i < cols.len() {
        if i > 0 {
          result += colbreak()
        }

        let rows = ()
        let segment = 0
        while segment < num-segments {
          if i >= cols.len() { break }

          let segment-cols = ()
          let current-w = 0pt

          while i < cols.len() {
            let w = col-widths.at(i)
            let add-w = if segment-cols.len() == 0 { w } else { w + info.gap }

            if current-w > 0pt and current-w + add-w > info.page-width {
              break
            }

            segment-cols.push(cols.at(i))
            current-w += add-w
            i += 1
          }

          if segment-cols.len() > 0 {
            rows.push(render-page(segment-cols, info.config.font, info.config.layout.gap, info.config))
          }
          segment += 1
        }

        if rows.len() > 0 {
          result += stack(
            dir: ttb,
            spacing: info.config.layout.column-gap,
            ..rows,
          )
        }
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
