#import "../lib.typ": tate, vblock

// A small page width to force pagination!
#set page(width: 160pt, height: 400pt, margin: 10pt)
#set text(font: "Harano Aji Mincho", size: 12pt)

#tate(columns: 2)[
  以下の連立方程式を解いてください。


  $
      2x + y & = 5 \
      x - 3y & = -8 \
     3x + 5y & = 12 \
    -4x - 2y & = -10
  $


  これが答えです。

    $
      x = 1 \
      y = 3
    $

  figure(rect(stroke: 1pt), caption: [rectangle])

]
