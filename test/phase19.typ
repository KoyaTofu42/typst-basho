#import "../lib.typ": tate, turn, vert
#import "../src/flatten.typ": flatten
#import "../src/config.typ": default-opts

#set page(width: 220pt, height: 220pt, margin: 10pt)
#set text(size: 12pt, font: "YuMincho")


#tate([
  = リストの例
  このように

  - Alpha
  - #turn[β]
  - #vert("Gamma")
  - でるた

  #vert("Gamma")
])

#pagebreak()

== Visual: numbered list in tate
#tate(enum([
  + One
  + Two
]))
