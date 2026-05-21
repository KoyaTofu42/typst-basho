// src/turn.typ
// Turn module for rotating generic content (like math equations) 90 degrees

/// Renders arbitrary content rotated 90 degrees clockwise.
/// The bounding box automatically reflows to reserve the correct vertical space.
/// Unlike 'roman', it does not override the font or text size, making it
/// ideal for equations, figures, or complex nested content.
///
/// - token (dictionary): A token with type "turn" and text field (content).
/// - font (str): Font family name (ignored to preserve inner content styling).
/// - config (dictionary): The layout configuration.
/// -> content: Rotated content inside a container bounded horizontally by the column width.
#let render-turn(token, font, config) = {
  // We use a box with a fixed horizontal width (char-box) to keep it centered
  // in the vertical column, but let the height auto-calculate based on the rotated content.
  box(
    width: config.sizing.char-box,
    align(center + horizon,
      rotate(90deg, reflow: true, token.text)
    )
  )
}

/// Default turn rendering module.
/// Bundles the renderer for "turn" tokens.
#let default-turn = (
  node-renderers: (
    "turn": render-turn
  )
)
