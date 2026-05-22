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

#import "kinsoku.typ": is-forbidden-start, is-valid-line-end, apply-spacing-compression

/// Splits a flat token array into column groups based on a maximum height
/// (absolute length). Uses pre-measured token heights for accuracy,
/// and consults config.kinsoku.resolve for line-breaking decisions.
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
      config.kinsoku.insert("next-token", if i + 1 < tokens.len() { tokens.at(i + 1) } else { none })
      let decision = (config.kinsoku.resolve)(current-col, token, h, config, current-height, max-height)

      if decision.action == "burasagari" {
        let hanging-token = token
        hanging-token.type = "hanging"
        current-col.push(hanging-token)
        columns.push(current-col)
        current-col = ()
        current-height = 0pt
        i += 1
        continue
      }

      if decision.action == "oikomi" {
        apply-spacing-compression(current-col, decision.compression-amount, config)
        current-col.push(token)
        columns.push(current-col)
        current-col = ()
        current-height = 0pt
        i += 1
        continue
      }

      if decision.action == "push-previous" {
        let popped = ()
        let popped-height = 0pt
        let popped-start = i - current-col.len()
        while current-col.len() > 0 {
          let p = current-col.pop()
          let ph = heights.at(popped-start + current-col.len())
          popped.insert(0, p)
          popped-height += ph

          let new-last = if current-col.len() > 0 { current-col.last() } else { none }
          if is-valid-line-end(new-last, config.kinsoku.forbidden-end) {
            // If the overflow token is forbidden-start and the new column
            // would start with one too, cascade further to prevent a
            // column-start kinsoku violation.
            let tok-start = is-forbidden-start(token, config.kinsoku.forbidden-start)
            let pop-start = popped.len() > 0 and is-forbidden-start(popped.first(), config.kinsoku.forbidden-start)
            let needs-more = tok-start and pop-start
            if needs-more {
              // Continue popping
            } else {
              break
            }
          }
        }

        let exhausted = current-col.len() == 0
        columns.push(current-col)
        if exhausted {
          // All tokens were popped but the violation persists.
          // Force oidashi to prevent infinite loop.
          current-col = (token,)
          current-height = h
          i += 1
        } else {
          current-col = popped
          current-height = popped-height
        }
        continue
      }

      // oidashi — break normally before the current token
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

    // Measure and render within the current flow so height is respected.
    #layout(size => context {
      let heights = tokens.map(token => {
        if token.type == "newline" or token.type == "heading-anchor" {
          0pt
        } else {
          measure(render-char-token(token, config.font, config)).height
        }
      })

      let col-gap-abs = measure(v(config.layout.column-gap)).height
      let y = here().position().y
      let available-height = calc.max(0pt, size.height - y)
      let usable-height = (available-height - (config.layout.columns - 1) * col-gap-abs) / config.layout.columns

      let gap-abs = measure(h(config.layout.gap)).width

      let cfg = config
      cfg.insert("usable-height", usable-height)
      // Resolve char-box to absolute for kinsoku compression calculations
      let char-box-abs = measure(box(width: config.sizing.char-box, height: config.sizing.char-box)).height
      cfg.insert("char-box-abs", char-box-abs)

      let cols = paginate(tokens, heights, usable-height, cfg)
      let col-widths = cols.map(col => measure(render-column(col, cfg.font, cfg)).width)

      let result = []
      let i = 0
      let num-segments = cfg.layout.columns

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
            let add-w = if segment-cols.len() == 0 { w } else { w + gap-abs }

            if current-w > 0pt and current-w + add-w > size.width {
              break
            }

            segment-cols.push(cols.at(i))
            current-w += add-w
            i += 1
          }

          if segment-cols.len() > 0 {
            rows.push(render-page(segment-cols, cfg.font, cfg.layout.gap, cfg))
          }
          segment += 1
        }

        if rows.len() > 0 {
          result += stack(
            dir: ttb,
            spacing: cfg.layout.column-gap,
            ..rows,
          )
        }
      }

      result
    })
  ]
}

/// Convenience wrapper (backward compat).
#import "config.typ": default-opts, merge-config
#let render-tokens(tokens, font, gap: 1em, columns: 1, column-gap: 2em) = {
  let cfg = merge-config(default-opts, (font: font, layout: (gap: gap, columns: columns, column-gap: column-gap)))
  layout-tate(tokens, cfg)
}
