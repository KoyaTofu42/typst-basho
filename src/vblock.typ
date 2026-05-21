// src/vblock.typ
#let render-vblock(token, font, config) = {
  align(center + horizon,
    rotate(90deg, reflow: true, token.text)
  )
}

#let default-vblock = (
  node-renderers: (
    "vblock": render-vblock
  )
)
