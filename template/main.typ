#import "@preview/basho:0.1.0": hblock, ruby, tate, tcy

#set text(font: "Harano Aji Mincho", size: 11pt)
#set page(paper: "jp-business-card", fill: oklch(98.17%, 0.048, 107.25deg))

#tate[
  = Bashoテンプレート

  これはBashoパッケージのテンプレートです。
  縦書き（tategaki）の文章をTypst内で美しく組版します。

  #h(0em)
  閑さや

  　岩にしみ入る

  　　蝉の声

  #hblock(box(height: 90%, align(bottom, text(size: 14pt, [Basho]))))
]
