#set page(width: 5cm, height: 5cm)
#set text(font: "Harano Aji Mincho", size: 24pt)

#let char(c) = box(width: 1em, height: 1em, align(center+horizon)[#text(features: ("vert", "vrt2"))[#c]])
#let v-dash-size(s) = box(width: 1em, height: 1em, align(center+horizon)[#text(size: s, features: ("vert", "vrt2"))[―]])

#stack(dir: ttb, char("あ"), v-dash-size(1.25em), v-dash-size(1.25em), char("い"))
