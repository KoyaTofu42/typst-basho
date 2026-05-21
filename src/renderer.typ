// src/renderer.typ
// Character box rendering with OpenType vertical glyph features

#import "kinsoku.typ": is-opening, is-closing

/// Wraps a single character in a 1em × 1em box with vertical OpenType features.
/// Alignment within the box depends on bracket type:
/// - Opening brackets (「 etc.) → left-aligned
/// - Closing brackets (」 etc.) → right-aligned
/// - All other characters → center-aligned
///
/// - body (content): The character content to render.
/// - font (str): Font family name.
/// - h-align (alignment): Horizontal alignment override.
/// -> content: A box containing the vertically-oriented character.
#let char-box(body, font, h-align: center) = {
  box(
    width: 1em,
    height: 1em,
    align(h-align + horizon,
      text(
        font: font,
        features: ("vert", "vrt2"),
        body,
      )
    )
  )
}

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

/// Renders a single token based on its type.
/// Dispatches "char" → char-box, "tcy" → render-tcy, "hanging" → render-hanging.
///
/// - token (dictionary): A token dictionary with at least a `type` and `text` field.
/// - font (str): Font family name.
/// -> content: Rendered content for the token.
#let render-char-token(token, font) = {
  if token.type == "char" {
    // Determine horizontal alignment based on bracket type
    let h-align = if is-opening(token) { right }
      else if is-closing(token) { left }
      else { center }
    char-box(token.text, font, h-align: h-align)
  } else if token.type == "tcy" {
    render-tcy(token, font)
  } else if token.type == "hanging" {
    render-hanging(token, font)
  }
}
