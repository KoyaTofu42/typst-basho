// src/renderer.typ
// Character box rendering with OpenType vertical glyph features

/// Wraps a single character in a 1em × 1em box with vertical OpenType features.
///
/// - body (content): The character content to render.
/// - font (str): Font family name.
/// -> content: A box containing the vertically-oriented character.
#let char-box(body, font) = {
  box(
    width: 1em,
    height: 1em,
    align(center + horizon,
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

/// Renders a single token based on its type.
/// Dispatches "char" → char-box, "tcy" → render-tcy.
///
/// - token (dictionary): A token dictionary with at least a `type` and `text` field.
/// - font (str): Font family name.
/// -> content: Rendered content for the token.
#let render-char-token(token, font) = {
  if token.type == "char" {
    char-box(token.text, font)
  } else if token.type == "tcy" {
    render-tcy(token, font)
  }
}
