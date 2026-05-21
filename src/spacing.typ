// src/spacing.typ
// Automatic spacing module (Shikiri / Wou-Kan Kakaku)

#let is-european(t) = t.type in ("tcy", "turn")
#let is-cjk(t) = t.type == "char" and t.text.match(regex("^[^\s\p{P}]$")) != none

/// Default spacing rendering module.
/// Automatically inserts a 1/4em space between CJK and European characters.
#let default-spacing = (
  node-renderers: (
    // Render the spacing token as a box with the specified height (vertical advance)
    "spacing": (token, font, config) => box(width: config.sizing.char-box, height: token.width)
  ),
  
  transform: (tokens, module, config) => {
    let result = ()
    let prev = none
    for t in tokens {
      if prev != none {
        if (is-cjk(prev) and is-european(t)) or (is-european(prev) and is-cjk(t)) {
          result.push((type: "spacing", width: 0.25em))
        }
      }
      result.push(t)
      prev = t
    }
    result
  }
)
