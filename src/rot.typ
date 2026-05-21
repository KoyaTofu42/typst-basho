// src/rot.typ
// Rot (rotated) module for rotated horizontal English words in tategaki

/// Renders horizontal text rotated 90 degrees clockwise (rot yoko).
/// The bounding box automatically reflows to reserve the correct vertical
/// space equivalent to the text's horizontal width.
///
/// - token (dictionary): A token with type "rot" and text field.
/// - font (str): Font family name.
/// - config (dictionary): The layout configuration.
/// -> content: Rotated text inside a container bounded horizontally by the column width.
#let render-rot(token, font, config) = {
  // We use a box with a fixed horizontal width (char-box) to keep it centered
  // in the vertical column, but let the height auto-calculate based on the rotated text.
  box(
    width: config.sizing.char-box,
    align(center + horizon,
      rotate(90deg, reflow: true,
        text(font: font, size: config.sizing.char-box, token.text)
      )
    )
  )
}

/// Default rot rendering module.
/// Bundles the renderer for "rot" tokens.
#let default-rot = (
  node-renderers: (
    "rot": render-rot
  )
)
