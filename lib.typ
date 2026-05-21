// lib.typ
// Public API for Basho — Vertical Japanese Typesetting

#import "src/parser.typ": tokenize
#import "src/layout.typ": render-tokens

/// Renders text vertically (tategaki / 縦書き).
///
/// - body (str): The text to render vertically.
/// - font (str): Font family to use. Defaults to "Harano Aji Mincho".
/// -> content: Vertically rendered text.
#let tate(body, font: "Harano Aji Mincho") = context {
  render-tokens(tokenize(body), font)
}
