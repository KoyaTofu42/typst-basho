// src/char-box.typ
// Base character box rendering

/// Wraps a single character in a 1em × 1em box with vertical OpenType features.
/// Alignment within the box depends on bracket type:
/// - Opening brackets (「 etc.) → left-aligned (or right-aligned depending on convention)
/// - Closing brackets (」 etc.) → right-aligned (or left-aligned depending on convention)
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
