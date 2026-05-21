// src/renderer.typ
// Character box rendering with OpenType vertical glyph features

#import "kinsoku.typ": is-opening, is-closing

#import "char-box.typ": char-box

/// Renders a TCY (tate-chu-yoko / 縦中横) run: short horizontal text displayed
/// with normal horizontal glyphs, centered within a 1em × 1em slot in the
/// vertical column flow. No rotation, no vertical OpenType features.
/// Typically used for 2-digit numbers ("42") or short abbreviations ("IT").
/// Font size adapts to string length so text fits within the 1em column width.
///
/// - token (dictionary): A token with type "tcy" and text field.
/// - font (str): Font family name.
/// - config (dictionary): The layout configuration.
/// -> content: Horizontal text in a 1em × 1em box.
#let render-tcy(token, font, config) = {
  let len = token.text.clusters().len()
  let tcy-module = config.tcy.first()
  let sizes = tcy-module.sizes
  let sz = if len <= 2 { sizes.at(0) }
    else if len <= 3 { sizes.at(1) }
    else { calc.min(sizes.at(2) / 1em, 1.0 / len) * config.sizing.char-box }
  box(
    width: config.sizing.char-box,
    height: config.sizing.char-box,
    align(center + horizon,
      text(font: font, size: sz, token.text),
    )
  )
}

/// Renders hanging punctuation (kinsoku shori): the character is drawn
/// in a zero-height box so it visually overflows into the gutter below
/// the column without affecting the column height.
///
/// - token (dictionary): A token with type "hanging" and text field.
/// - font (str): Font family name.
/// - config (dictionary): The layout configuration.
/// -> content: Zero-height box with the character.
#let render-hanging(token, font, config) = {
  box(
    width: config.sizing.char-box,
    height: 0pt,
    clip: false,
    align(center + top,
      text(
        font: font,
        features: config.features,
        token.text,
      )
    )
  )
}

#import "ruby.typ": render-ruby

/// Renders a single token based on its type.
/// Dispatches "char" → char-box, "tcy" → render-tcy, "hanging" → render-hanging, "ruby" → render-ruby.
///
/// - token (dictionary): A token dictionary with at least a `type` and `text` field.
/// - font (str): Font family name.
/// - config (dictionary): The layout configuration.
/// -> content: Rendered content for the token.
#let render-char-token(token, font, config) = {
  // Check injected node-renderers from all rendering modules
  for render-module in config.rendering {
    if "node-renderers" in render-module and token.type in render-module.node-renderers {
      return (render-module.node-renderers.at(token.type))(token, font, config)
    }
  }

  let heading-level = token.at("heading", default: none)
  let scales = config.sizing.heading-scales
  let font-scale = if heading-level == 1 { scales.at(0) }
    else if heading-level == 2 { scales.at(1) }
    else if heading-level == 3 { scales.at(2) }
    else { 1.0 }

  // Determine kinsoku-aware alignment by checking all kinsoku modules
  let check-opening(token) = {
    for rules in config.kinsoku {
      if is-opening(token, rules) { return true }
    }
    false
  }
  let check-closing(token) = {
    for rules in config.kinsoku {
      if is-closing(token, rules) { return true }
    }
    false
  }

  let rendered = if token.type == "char" {
    // Determine horizontal alignment based on bracket type
    let h-align = if check-opening(token) { right }
      else if check-closing(token) { left }
      else { center }
    if heading-level != none {
      // Heading characters: scaled box
      let sz = config.sizing.char-box * font-scale
      box(
        width: sz,
        height: sz,
        align(h-align + horizon,
          text(
            font: font,
            size: config.sizing.char-box * font-scale,
            features: config.features,
            weight: "bold",
            token.text,
          )
        )
      )
    } else {
      char-box(token.text, font, config, h-align: h-align)
    }
  } else if token.type == "tcy" {
    render-tcy(token, font, config)
  } else if token.type == "hanging" {
    render-hanging(token, font, config)
  } else if token.type == "ruby" {
    render-ruby(token, font, config)
  } else {
    none
  }

  if rendered != none {
    if token.at("bold", default: false) { rendered = strong(rendered) }
    if token.at("italic", default: false) { rendered = emph(rendered) }
  }
  
  rendered
}
