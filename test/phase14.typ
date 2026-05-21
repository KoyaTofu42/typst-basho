#import "../lib.typ": tate, vblock

// A small page width to force pagination!
#set page(width: 100pt, height: 400pt, margin: 10pt)
#set text(font: "Harano Aji Mincho", size: 12pt)

#tate[
  以下の連立方程式を解いてください。
  #vblock[
    $
      2x + y &= 5 \
      x - 3y &= -8 \
      3x + 5y &= 12 \
      -4x - 2y &= -10
    $
  ]
  これが答えです。
]
