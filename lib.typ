// lib.typ
// Public API for Basho — Vertical Japanese Typesetting

#import "src/layout.typ": layout-tate
#import "src/flatten.typ": flatten

/// Forces a sequence of characters to be rendered as Tate-chu-yoko (inline horizontal).
///
/// - body (str): The text to rotate.
/// -> content: Metadata tag instructing the engine to render as TCY.
#let tcy(body) = metadata((type: "tcy", text: body))

/// Attaches phonetic ruby (furigana) to base characters.
///
/// - base (str): The base text (e.g. "漢字").
/// - rt (str): The ruby text (e.g. "かんじ").
/// -> content: Metadata tag instructing the engine to render with ruby.
#let ruby(base, rt) = metadata((type: "ruby", text: base, ruby: rt))

/// Renders native Typst content vertically (tategaki / 縦書き).
///
/// - body (content | str): The content to render vertically.
/// - font (str): Font family to use. Defaults to "Harano Aji Mincho".
/// - columns (int): Number of horizontal rows (段組み) to split the page into.
/// - column-gap (length): Gap between horizontal rows.
/// -> content: Vertically rendered paginated content.
#let tate(body, font: "Harano Aji Mincho", columns: 1, column-gap: 2em) = {
  layout-tate(flatten(body), font, columns: columns, column-gap: column-gap)
}
