#import "@preview/basho:0.1.0": hblock, ruby, tate, tate-inline
#set text(font: "Harano Aji Mincho")

#set page(
  width: 450pt,
  height: 350pt,
)

#tate(config: (layout: (columns: 2)))[
  = ポラーノの広場

  そのころわたくしは、モリーオ市の博物局に勤めて居りました。
  　十八等官でしたから役所のなかでも、ずうっと下の方でしたし#ruby("俸給", "ほうきゅう")もほんのわずかでしたが、受持ちが標本の採集や整理で生れ付き好きなことでしたから、わたくしは毎日ずいぶん愉快にはたらきました。殊にそのころ、モリーオ市では競馬場を植物園に#ruby("拵", "こしら")え直すというのでその景色のいいまわりにアカシヤを植え込んだ広い地面が、切符売場や信号所の建物のついたまま、わたくしどもの役所の方へまわって来たものですから、わたくしはすぐ宿直という名前で月賦で買った小さな蓄音器と二十枚ばかりのレコードをもって、その番小屋にひとり住むことになりました。わたくしはそこの馬を置く場所に板で小さなしきいをつけて一疋の山羊を飼いました。毎
]


#tate[
  == Fourier変換
  次によって定義されるFourier変換
  $
    integral_(-oo)^(oo) f(x) e^(-2 pi i k x) d x, quad "where" x, k in R
  $
  は位置空間$x$から波数空間$k$への変換である。

  == 形容詞の活用表
  #hblock([
    #table(
      columns: 2,
      tate-inline[ク活用], [],
      tate-inline[から], tate-inline[未然形],
      tate-inline[かり], tate-inline[連用形],
      tate-inline[◯], tate-inline[終止形],
      tate-inline[かる], tate-inline[連体形],
      tate-inline[かれ], tate-inline[命令形],
    )])

  == 短冊
  #rect(
    fill: rgb(255, 240, 240),
    tate(
      config: (layout: (paragraph-indent: 0pt)),
    )[奥山に 紅葉踏みわけ 鳴く鹿の

      声きく時ぞ 秋は悲しき],
  )
]

