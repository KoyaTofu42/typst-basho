// src/list.typ
// Self-contained list modules: each bundles data and flatten logic.

/// Default bullet list module.
/// Each item produces a bullet-list-marker token rendered as a vertical character.
#let default-bullet-list = (
  marker: "・",
  flatten: (c, _flatten, config) => {
    let tokens = ()
    for i in range(c.children.len()) {
      if i > 0 { tokens.push((type: "newline", text: "\n")) }
      tokens.push((type: "bullet-list-marker"))
      tokens += _flatten(c.children.at(i).body, config)
    }
    tokens
  },
  node-renderers: (
    "bullet-list-marker": (token, font, config) => {
      let f-opt = if font != none { (font: font) } else { (:) }
      let marker = config.list.bullet.marker
      box(
        width: config.sizing.char-box,
        height: config.sizing.char-box,
        align(center + horizon, text(..f-opt, features: config.features, marker)),
      )
    },
  ),
)

/// Default numbered list module.
/// The formatted number (e.g. "1.") is rendered as forced TCY so the
/// digits and dot stay in a single 1em slot.
#let default-numbered-list = (
  format: n => str(n) + ".",
  gap: 0.25em,
  flatten: (c, _flatten, config) => {
    let tokens = ()
    let start = c.at("start", default: 1)
    for i in range(c.children.len()) {
      if i > 0 { tokens.push((type: "newline", text: "\n")) }
      let num = (config.list.numbered.format)(start + i)
      tokens.push((type: "tcy", text: num, forced: true))
      let gap = config.list.numbered.gap
      if gap != 0pt { tokens.push((type: "spacing", width: gap)) }
      tokens += _flatten(c.children.at(i).body, config)
    }
    tokens
  },
)
