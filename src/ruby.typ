// src/ruby.typ
// Ruby (furigana) rendering

#import "char-box.typ": char-box

/// Renders a character with ruby (furigana) on the right side.
/// The overall box is strictly 1em × 1em, with the ruby text overflowing
/// into the gutter to the right. This ensures column pitch remains consistent.
///
/// - token (dictionary): Token with type "ruby", `text` (base), and `ruby` (reading).
/// - font (str): Font family name.
/// -> content: Rendered ruby box.
#let render-ruby(token, font) = {
  let base-chars = token.text.clusters()
  let base-len = base-chars.len()
  let base-height = base-len * 1em

  let base-stack = stack(
    dir: ttb,
    spacing: 0pt,
    ..base-chars.map(ch => char-box(ch, font))
  )

  if token.ruby == "" or token.ruby == none {
    return base-stack
  }
  
  let ruby-chars = token.ruby.clusters()
  let ruby-len = ruby-chars.len()
  let ruby-height = ruby-len * 0.5em

  // Ruby text stack: characters are 0.5em each, stacked top-to-bottom
  let ruby-stack = stack(
    dir: ttb,
    spacing: 0pt,
    ..ruby-chars.map(ch => {
      box(
        width: 0.5em,
        height: 0.5em,
        align(center + horizon,
          text(
            size: 0.5em,
            font: font,
            features: ("vert", "vrt2"),
            ch
          )
        )
      )
    })
  )

  // Calculate the required height to fit whichever is taller (base or ruby)
  let total-height = calc.max(base-height, ruby-height)

  // Wrap in a 1em wide box. The height expands to prevent overlap with adjacent tokens.
  // Both base and ruby are vertically centered within this height.
  // Ruby flows to the right (dx: 1em).
  box(
    width: 1em,
    height: total-height,
    clip: false,
    {
      place(left + horizon, base-stack)
      place(left + horizon, dx: 1em, ruby-stack)
    }
  )
}
