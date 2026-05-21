#set page(width: 10cm, height: 10cm)
#set text(font: "Harano Aji Mincho", size: 24pt)

#let v-dash(s) = box(width: 1em, height: 1em, align(center+horizon)[#scale(y: s, text(features: ("vert", "vrt2"))[―])])

1. Default (100%):
#v-dash(100%)#v-dash(100%)

2. Scale Y 125%:
#v-dash(125%)#v-dash(125%)

3. Scale Y 150%:
#v-dash(150%)#v-dash(150%)

4. Scale Y 200%:
#v-dash(200%)#v-dash(200%)

5. Scale X 150% (just in case):
#let h-dash(s) = box(width: 1em, height: 1em, align(center+horizon)[#scale(x: s, text(features: ("vert", "vrt2"))[―])])
#h-dash(150%)#h-dash(150%)
