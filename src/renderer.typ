// src/renderer.typ
// Character box rendering with OpenType vertical glyph features

#import "kinsoku.typ": is-opening, is-closing

#import "char-box.typ": char-box

/// Renders a TCY (tate-chu-yoko) run: horizontal text rotated 90° to sit inline
/// within the vertical flow. Width is 1em (column width), height adapts to
/// the length of the rotated text.
///
/// - token (dictionary): A token with type "tcy" and text field.
/// - font (str): Font family name.
/// -> content: Rotated horizontal text in a 1em-wide box.
#let render-tcy(token, font) = {
  box(
    width: 1em,
    align(center + horizon,
      rotate(
        90deg,
        reflow: true,
        text(font: font, token.text),
      )
    )
  )
}

/// Renders hanging punctuation (kinsoku shori): the character is drawn
/// in a zero-height box so it visually overflows into the gutter below
/// the column without affecting the column height.
///
/// - token (dictionary): A token with type "hanging" and text field.
/// - font (str): Font family name.
/// -> content: Zero-height box with the character.
#let render-hanging(token, font) = {
  box(
    width: 1em,
    height: 0pt,
    clip: false,
    align(center + top,
      text(
        font: font,
        features: ("vert", "vrt2"),
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
/// -> content: Rendered content for the token.
#let render-char-token(token, font) = {
  let rendered = if token.type == "char" {
    // Determine horizontal alignment based on bracket type
    let h-align = if is-opening(token) { right }
      else if is-closing(token) { left }
      else { center }
    char-box(token.text, font, h-align: h-align)
  } else if token.type == "tcy" {
    render-tcy(token, font)
  } else if token.type == "hanging" {
    render-hanging(token, font)
  } else if token.type == "ruby" {
    render-ruby(token, font)
  } else {
    none
  }

  if rendered != none {
    if token.at("bold", default: false) { rendered = strong(rendered) }
    if token.at("italic", default: false) { rendered = emph(rendered) }
  }
  
  rendered
}
