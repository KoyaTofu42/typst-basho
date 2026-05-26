#import "../lib.typ": tate

#let ink = rgb("#1c1c1c")
#let vague-ink = rgb("#999999")
#let cream = rgb("#f5f0e8")
#let accent = rgb("#3ac431")
#let typst-color = oklch(65.81%, 10.26%, 208.48deg)

#set page(
  width: 1800pt,
  height: 800pt,
  margin: 0pt,
  fill: rgb(100%, 100%, 100%, 0%),
)
#set text(font: ("Georgia", "Hiragino Mincho ProN"))

#rect(stroke: none, fill: cream, height: 100%, radius: 100pt, inset: 0pt)[
  #align(center, rect(width: 90%, height: 24pt, radius: (bottom: 10pt), fill: typst-color))

  #grid(
    columns: (1200pt, auto, 1fr),
    rows: 90%,
    [
      #set text(size: 200pt, fill: vague-ink)
      #align(bottom)[#box(inset: 100pt)[Basho]]
    ],
    [
      // Haiku — rendered with basho, left side
      #set text(size: 70pt, fill: ink)
      #box(inset: 1em)[#tate(config:(layout:(paragraph-indent: 0pt)))[
        閑さや

        　岩にしみ入る

        　　　　　蝉の声
      ]]
    ],
    [],
  )
]
