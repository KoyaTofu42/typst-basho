// combined-features.typ — All phase tests + huge example merged
// Generated from: phase1.typ through phase19.typ (excluding phase11),
//   issue-nya.typ, huge-example.typ

// ═══════════════════════════════════════════════════════════════════════════════
// Phase 1: Basic vertical rendering
// ═══════════════════════════════════════════════════════════════════════════════


#set page(width: 200pt, height: 300pt, margin: 20pt)
#set text(size: 12pt, font: ("Times New Roman", "Harano Aji Mincho"))

#show "…": set text(font: "Harano Aji Mincho")
#show "―": set text(font: "Harano Aji Mincho")

= Phase 1 Test: Single-Column Vertical Rendering

== Test 1: Basic Japanese text
#import "../lib.typ": tate
#tate("日本語")

#v(1em)
== Test 2: Longer text
#tate("吾輩は猫である")

#v(1em)
== Test 3: Empty string (should render nothing)
#tate("")

#v(1em)
== Test 4: Single character
#tate("あ")

// ═══════════════════════════════════════════════════════════════════════════════
// Phase 2: Multi-line RTL column layout
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()
#set page(width: 300pt, height: 300pt, margin: 20pt)
#set text(size: 12pt)

= Phase 2 Test: Multi-line RTL Columns

== Test 1: Two columns (ABC / DEF)
#tate("ABC\nDEF")

#v(1em)
== Test 2: Three columns of Japanese
#tate("春の\n海の\n声が")

#v(1em)
== Test 3: Consecutive newlines (empty column)
#tate("あ\n\nい")

#v(1em)
== Test 4: Single line (no newlines, backward compat)
#tate("日本語")

// ═══════════════════════════════════════════════════════════════════════════════
// Phase 3: TCY (tate-chu-yoko) for Latin/number runs
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()
#set page(width: 300pt, height: 400pt, margin: 20pt)
#set text(size: 14pt)

= Phase 3 Test: TCY (Tate-chu-yoko)

== Test 1: Mixed CJK and Latin/numbers
#tate("abc日本語123")

#v(1em)
== Test 2: Only Latin
#tate("Hello")

#v(1em)
== Test 3: Only CJK (no TCY, backward compat)
#tate("東京都")

#v(1em)
== Test 4: Interleaved
#tate("A漢B字C")

#v(1em)
== Test 5: Numbers in Japanese sentence
#tate("令和7年5月21日")

#v(1em)
== Test 6: Multi-line with TCY
#tate("Hello世界\nTest123")

// ═══════════════════════════════════════════════════════════════════════════════
// Phase 4: Auto-pagination by page height
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()
#set page(width: 200pt, height: 150pt, margin: 10pt)
#set text(size: 12pt)

= Phase 4 Test: Auto-Pagination

== Test 1: Long text auto-wrap
#tate("あいうえおかきくけこさしすせそたちつてと")

#pagebreak()

== Test 2: Very long text overflow
#tate(
  "一二三四五六七八九十壱弐参四伍六七八九廿一二三四五六七八九十壱弐参四伍六七八九廿一二三四五六七八九十壱弐参四伍六七八九廿一二三四五六七八九十壱弐参四伍六七八九廿一二三四五六七八九十壱弐参四伍六七八九廿一二三四五六七八九十壱弐参四伍六七八九廿",
)

#pagebreak()

== Test 3: Explicit newlines
#tate("春夏\n秋冬")

#pagebreak()

== Test 4: Mixed TCY and CJK
#tate("令和7年5月21日は晴天なり朝から夕方まで")

#pagebreak()

== Test 5: Single column
#tate("猫")

// ═══════════════════════════════════════════════════════════════════════════════
// Phase 5: Kinsoku Shori (Japanese line-breaking rules)
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()
#set page(width: 200pt, height: 150pt, margin: 10pt)
#set text(size: 12pt, font: "Harano Aji Mincho")

= Phase 5 Test: Kinsoku Shori

== Test 1: Opening bracket at column end
#tate("あいうえおかきくけ「こ")

#pagebreak()
== Test 2: Closing bracket at column start
#tate("あいうえおかきくけこ」さ")

#pagebreak()
== Test 3: Period at column start
#tate("あいうえおかきくけこ。さしす")

#pagebreak()
== Test 4: Both rules combined
#tate("あいうえおかきくけ「こ」さ")

#pagebreak()
== Test 5: No kinsoku needed
#tate("あいうえおかきくけこさしすせそたちつてと")

#pagebreak()
== Test 6: Hanging punctuation with forbidden-start
#tate("あいうえおかきくけこ。）さ")

// ═══════════════════════════════════════════════════════════════════════════════
// Phase 6: Ruby (Furigana) — Complex Examples
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()
#set page(width: 250pt, height: 250pt, margin: 10pt)
#set text(size: 12pt)

= Phase 6 Test: Ruby (Furigana)

#import "../lib.typ": layout-tate
#import "../src/config.typ": default-opts, merge-config

== Test 1: Standard ruby and long ruby
#let test-tokens-1 = (
  (type: "char", text: "東"),
  (type: "ruby", text: "京", ruby: "キョウ"),
  (type: "char", text: "都"),
  (type: "ruby", text: "庁", ruby: "チョウ"),
  (type: "newline", text: "\n"),
  (type: "char", text: "短"),
  (type: "char", text: "い"),
  (type: "char", text: "文"),
  (type: "newline", text: "\n"),
  (type: "ruby", text: "漢", ruby: "かん"),
  (type: "ruby", text: "字", ruby: "じ"),
)
#layout-tate(test-tokens-1, merge-config(default-opts, (font: "Harano Aji Mincho")))

#pagebreak()
== Test 2: Combined features (TCY + Kinsoku + Group Ruby)
#let test-tokens-2 = (
  (type: "char", text: "「"),
  (type: "ruby", text: "昭和", ruby: "ショウワ"),
  (type: "tcy", text: "50"),
  (type: "char", text: "年"),
  (type: "char", text: "」"),
  (type: "char", text: "の"),
  (type: "ruby", text: "記憶", ruby: "キオク"),
  (type: "char", text: "。"),
)
#layout-tate(test-tokens-2, merge-config(default-opts, (font: "Harano Aji Mincho")))

#pagebreak()
== Test 3: Empty ruby handling
#let test-tokens-3 = (
  (type: "char", text: "普"),
  (type: "char", text: "通"),
  (type: "char", text: "の"),
  (type: "ruby", text: "文", ruby: ""),
  (type: "ruby", text: "字", ruby: none),
  (type: "newline", text: "\n"),
  (type: "ruby", text: "今日", ruby: "きょう"),
  (type: "char", text: "は"),
  (type: "char", text: "晴"),
  (type: "char", text: "天"),
)
#layout-tate(test-tokens-3, merge-config(default-opts, (font: "Harano Aji Mincho")))

// ═══════════════════════════════════════════════════════════════════════════════
// Phase 7: Content Flattener & API Finalization
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()
#set page(width: 300pt, height: 250pt, margin: 10pt)
#set text(size: 12pt)

#import "../lib.typ": ruby, tcy

= Phase 7 Test: Content Flattener

#tate[
  「#ruby("昭和", "ショウワ")#tcy("50")年の記憶」

  今日は*とても*良い天気ですね。

  長い#ruby("漢字", "かんじ")も、問題なくレンダリングされます。

  自動的に123も横書きになります。
]

// ═══════════════════════════════════════════════════════════════════════════════
// Phase 8: Dangumi, Kinsoku, Typst special notation
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()
#set page(width: 300pt, height: 250pt, margin: 15pt)
#set text(size: 12pt)

= Phase 8 Test: Dangumi & Kinsoku

== Test 1: Basic 2-column Dangumi
#tate(config: (layout: (columns: 2, column-gap: 10pt)))[
  これは縦書きにおける段組み（水平分割）のテストです。西洋の横書きレイアウトでは、段組みはページを左右に分割しますが、日本の伝統的な縦書きでは、ページを上下に分割します。

  このテキストは、まず上段を右から左に向かって埋めていきます。そして上段がいっぱいになると、自動的に下段の右端へとシームレスに移動して配置されます。これにより、文庫本や新聞のような、美しい二段組み（あるいは三段組み）のレイアウトをTypst上でネイティブに実現することができます。
]

#pagebreak()
== Test 2: Kinsoku — Closing brackets and small kana
#tate(config: (layout: (columns: 2, column-gap: 10pt)))[
  「禁則処理」とは、日本語組版における行末・行頭の処理規則である。例えば、閉じ括弧（」や）など）は行頭に来てはならない。また、拗音（しゃ・しゅ・しょ）や促音（あっ）のような小書き仮名も行頭禁則の対象である。

  長音符号ー（カタカナ語：コンピューター、サーバー、プレーヤー）も同様に、行頭に配置されることを禁じる。句読点「、」「。」はぶら下がり処理の対象であり、行末からはみ出して表示される。
]

#pagebreak()
== Test 3: Opening brackets (gyōmatsu kinsoku)
#tate(config: (layout: (columns: 2, column-gap: 10pt)))[
  開き括弧の禁則処理をテストする。行末に「が来た場合、次の行へ送り出される。括弧の種類：「二重鉤括弧」『二重括弧』【隅付き括弧】（丸括弧）〈山括弧〉《二重山括弧》である。

  入れ子も正しく動く。例えば「彼は『これは（重要な）問題だ』と言った」という文は、すべての括弧が正しく対応する。
]

#pagebreak()
== Test 4: Bold, italic, and ruby with dangumi
#tate(config: (layout: (columns: 2, column-gap: 10pt)))[
  *太字*と_斜体_を含む縦書きの段組みテスト。#ruby("漢字", "かんじ")の#ruby("振仮名", "ふりがな")も正しく表示されなければならない。

  #ruby("吾輩", "わがはい")は猫である。名前はまだ無い。どこで生れたかとんと#ruby("見当", "けんとう")がつかぬ。何でも薄暗いじめじめした所でニャーニャー泣いていた#ruby("事", "こと")だけは記憶している。
]

#pagebreak()
== Test 5: TCY (numbers & latin) with kinsoku
#tate(config: (layout: (columns: 2, column-gap: 10pt)))[
  令和7年5月21日、東京都渋谷区にて第42回「日本語組版」シンポジウムが開催された。参加者は約350名。午前10時30分に開会し、基調講演のテーマは「21世紀のDTPと縦書き」であった。

  なお、会場の最寄り駅はJR渋谷駅（ハチ公口より徒歩5分）である。入場料は1500円。詳しくはURLを参照されたい。
]

#pagebreak()
== Test 6: Mixed stress test — all features combined
#tate(config: (layout: (columns: 2, column-gap: 10pt)))[
  *第一章*　#ruby("邂逅", "かいこう")

  #ruby("春", "はる")の#ruby("嵐", "あらし")が#ruby("街", "まち")を駆け#ruby("抜", "ぬ")けた3月15日------#ruby("彼女", "かのじょ")は「#ruby("不思議", "ふしぎ")の#ruby("国", "くに")のアリス」を#ruby("片手", "かたて")に、カフェ・ド・フローラの#ruby("隅", "すみ")っこに#ruby("座", "すわ")っていた。

  テーブルの上には、コーヒーカップと、ノートパソコン（MacBook Pro 16インチ）。WiFiのパスワードは「sesami!」と書かれた小さなカードが添えられていた。
]

#pagebreak()
== Test 7: Headings (=, ==, ===)
#tate[
  = 第一章

  ある晴れた朝、太郎は旅に出た。長い道のりが待っていたが、彼の心は軽かった。

  == 出発の朝

  駅前の時計台が六時を告げた。まだ人影はまばらで、始発電車の音だけが響いていた。

  === 持ち物

  鞄の中には、地図と水筒と、母の作ったおにぎりが三つ。それだけで十分だった。

  == 旅の途中

  車窓から見える景色は、都会の灰色から次第に緑へと変わっていった。
]

// ═══════════════════════════════════════════════════════════════════════════════
// Phase 9: Kinsoku line breaking (dash + ellipsis)
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()
#set page(width: 8cm, height: 11em, margin: 1em)

= Phase 9 Test: Kinsoku line breaking

#tate(
  config: (layout: (columns: 2)),
  [
    １２３４５６７８——
    あいうえおかきく……
  ],
)

// ═══════════════════════════════════════════════════════════════════════════════
// Phase 10: Custom kinsoku resolvers via DI
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()
#set page(width: 8cm, height: 10cm)

= Phase 10 Test: Custom Kinsoku Resolvers

#import "../src/config.typ": default-opts, merge-config
#import "../src/core/kinsoku.typ": default-resolver, is-forbidden-start
#let extreme-oidashi-resolve(col, token, h, config, cur-h, max-h) = {
  if is-forbidden-start(token, config.kinsoku.forbidden-start) {
    return (action: "push-previous")
  }
  (action: "oidashi")
}
#let extreme-oidashi = default-resolver(resolve-fn: extreme-oidashi-resolve)
#let my-config = merge-config(default-opts, (
  kinsoku: extreme-oidashi,
  layout: (columns: 2),
))
#tate(config: my-config)[
  これはテストです。ここで長い長い文章を書きます。そして、ここで次の行に——行くはずですが、カスタム禁則関数によって挙動が変わるはずです。（極端な追い出し処理テスト）
]

// ═══════════════════════════════════════════════════════════════════════════════
// Phase 12: Rotated horizontal text (turn)
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()
#set page(width: 80pt, height: 230pt, margin: 10pt)
#set text(font: "Harano Aji Mincho", size: 12pt)

= Phase 12 Test: Rotated text

#import "../lib.typ": turn

#tate[
  最近、#turn[WebAssembly]や#turn[Rust]などの新しい技術が注目されています。
]

// ═══════════════════════════════════════════════════════════════════════════════
// Phase 13: Block math equations
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()
#set page(width: 200pt, height: 400pt, margin: 10pt)
#set text(font: "Harano Aji Mincho", size: 12pt)

= Phase 13 Test: Block Math

#tate[
  以下の数式を参照してください。
  $
    a^2 = b^2 + c^2 - 2 b c cos theta
  $
  これがピタゴラスの定理の拡張です。
]

// ═══════════════════════════════════════════════════════════════════════════════
// Phase 14: Multiple equations in dangumi
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()
#set page(width: 200pt, height: 400pt, margin: 10pt)
#set text(font: "Harano Aji Mincho", size: 12pt)

= Phase 14 Test: Multiple Equations in Dangumi

#import "../lib.typ": vblock

#tate(config: (layout: (columns: 2)))[
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
  わあ、すごいですね！
  #figure(rect(stroke: 1pt), caption: [rectangle])
]

// ═══════════════════════════════════════════════════════════════════════════════
// Phase 15: Inline math in tate
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()
#set page(width: 200pt, height: 400pt, margin: 10pt)
#set text(font: "Harano Aji Mincho", size: 12pt)

= Phase 15 Test: Inline Math

#tate[
  質量とエネルギーの等価性を示す公式は$E=m c^2$であり、これはアインシュタインによって提唱されました。
]

// ═══════════════════════════════════════════════════════════════════════════════
// Phase 16: Heading with figure
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()
#set page(width: 200pt, height: 400pt, margin: 10pt)
#set heading(numbering: "1")

= Phase 16 Test: Heading with Figure

#tate[
  = 見出しだよ
  テスト
  #figure(rect(width: 50pt, height: 50pt, stroke: 1pt), caption: [rectangle])
  テスト
]

// ═══════════════════════════════════════════════════════════════════════════════
// Phase 17: Multi-paragraph with headings
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()
#set page(width: 300pt, height: 400pt, margin: 10pt)
#set text(font: "Harano Aji Mincho", size: 12pt)
#set heading(numbering: "1")

= Phase 17 Test: Multi-paragraph

#tate[
  = 吾輩は猫である

  吾輩（わがはい）は猫である。名前はまだ無い。

  == 第一章

  どこで生れたかとんと見当（けんとう）がつかぬ。何でも薄暗いじめじめした所でニャーニャー泣いていた事だけは記憶している。
]

// ═══════════════════════════════════════════════════════════════════════════════
// Phase 18: Font switching between tate blocks
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()
#set page(width: 300pt, height: 400pt, margin: 10pt)
#set text(font: "Harano Aji Mincho", size: 12pt)
#set heading(numbering: "1")

= Phase 18 Test: Font Switching

#tate[
  原ノ味明朝

  = 吾輩は猫である
  == 第一章

  吾輩（わがはい）は猫である。名前はまだ無い。
]

#pagebreak()

#set text(font: "YuGothic", size: 12pt)

#tate[
  游ゴシック

  = ポラーノの広場
  == 第一章

  あのイーハトーヴォのすきとおった風、夏でも底に冷たさをもつ青いそら、うつくしい森で飾られたモリーオ市、郊外のぎらぎらひかる草の波。

  出典： #link("https://www.aozora.gr.jp/cards/000081/files/1935_19925.html", [ポラーノの広場])
]

// ═══════════════════════════════════════════════════════════════════════════════
// Phase 19: Lists in tate
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()
#set page(width: 220pt, height: 220pt, margin: 10pt)
#set text(size: 12pt, font: ("Times New Roman", "Harano Aji Mincho"))

= Phase 19 Test: Lists

#import "../lib.typ": turn, vert
#tate([
  = リストの例
  このように

  - Alpha
  - β
  - #vert("Gamma")
  - でるた

])

#pagebreak()
== Visual: numbered list in tate
#tate(enum([
  + One
  + Two
]))

// ═══════════════════════════════════════════════════════════════════════════════
// Issue: nya — narrow column line break
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()
#set page(width: 100pt, height: 280pt, margin: 0pt)
#set text(font: "Harano Aji Mincho", size: 12pt)

= Issue: Nya

#tate(config: (sizing: (char-box: 12pt)))[あいうえおかきくけこさしすせそたちニャーニャー]

// ═══════════════════════════════════════════════════════════════════════════════
// Huge Example: comprehensive rendering test
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()
#set page(width: 320pt, height: 460pt, margin: 12pt)
#set text(font: ("Times New Roman", "Harano Aji Mincho"), size: 11pt)
#show math.equation: set text(font: "XITS Math")
#show "―": set text(font: "Harano Aji Mincho")
#show "…": set text(font: "Harano Aji Mincho")

#import "../lib.typ": hblock, ruby, tate-inline, tcy, turn, vblock
#import "../src/core/kinsoku.typ": default-resolver

= Huge Example

#tate(config: (layout: (columns: 2)))[
  = The Basho Package Example
  = 見出しテスト

  この文書は、Bashoパッケージの大規模なレンダリングテスト用のサンプルです。Typstの一般的なマークアップと、Bashoの公開APIを組み合わせて、縦組みでの表示を幅広く確認します。

  この段落では、*太字 Bold*、_Italic_、#underline[下線]、#strike[取消線]、#overline[上線]、#highlight[強調] をまとめて確認する。

  また、#tcy("IT")と#tcy("ABC")のような短い英数字列も混在させ、三文字以上の縦中横が分割される経路も見ておく。

  内側の式も確認する。行内は $x + y = z$、独立したブロック式は $sum_(k=1)^n k = n(n+1)/2$。

  さらに、#vblock[$f(x) = 1 / (1 + e^(-x))$] のような縦中の数式、#turn[CLI]のような回転文字、
  #hblock[#rect([Hello#tate-inline[こんにちは世界]World], fill: luma(60%))]
  のような横置きブロックも混ぜる。

  句読点と禁則の確認のために、（かっこ、）や「かぎかっこ」、そして……や、――のような連続記号も入れる。ああ、ここで改行が必要になるくらい長く続けて、ぶら下がりと追い込みの差が出るようにしておく。

  = 第二節
  ここではTypstの通常の段落、改行、スペース、そして複数の文を続けて、縦組みの行送りをたくさん発生させる。日本語の長文は、縦書きでは右から左へ列が進み、禁則処理が効くはずだ。

  2026年の春には、42と#turn[24]と#tcy("999")と999が同じ文章に並ぶ。

  == 図形とブロック

  この節では、ブロック扱いされるTypstコンテンツを縦組みに入れる。パッケージ側では未対応ブロックを #hblock[...] として扱うので、横置きのまま落ちるかを見たい。

  #figure(caption: [四角、丸])[
    #grid(
      columns: 2,
      row-gutter: 1em,
      rect(width: 90pt, height: 24pt, fill: rgb("d8e8ff"), stroke: 0.5pt + rgb("4f6f9f"))[四角形],
      circle(radius: 12pt, fill: rgb("ffd9c7"), stroke: 0.5pt + rgb("b86d43"))[丸],

      rect(tate-inline[そうでもありませんよ]), rect(tate-inline[わあ、ここは広いですね]),
    )
  ]

  #vblock(
    figure(
      caption: [見て、回っているよ],
      stack(
        dir: ttb,
        spacing: 3pt,
        rect(height: 12pt, fill: rgb("c8f0d8"))[テケレ],
        rect(height: 12pt, fill: rgb("c8f0d8"))[テケレッツ],
        rect(height: 12pt, fill: rgb("c8f0d8"))[テケレッツのパー],
      ),
    ),
  )

  #ruby("縦書き", "たてがき")と#ruby("禁則処理", "きんそくしょり")をもう一度確認する。#strong[太字]と#emph[斜体]も同時に並べる。

  === 複合サンプル
  ここには、見出し、本文、英数字、記号、そして複数の Typst関数が一気に入る。

  - 箇条書き一
  - 箇条書き二
  - 箇条書き三

  #enum[
    + 番号付き項目
    + 番号付き項目
    + 番号付き項目
  ]

  #lorem(60)
]

#pagebreak()

= Kinsoku Modes

The next two blocks use the same content with different line-breaking presets so the output can be compared visually.

#v(1em)

#tate(config: (
    kinsoku: default-resolver(mode: "burasagari"),
    layout: (gap: 1.1em, columns: 2, column-gap: 10pt),
  ),
)[
  = 禁則モード
  == Burasagari
  これはぶら下がりの確認用の長文です。行末に来た「かぎかっこ」や（丸括弧）や、句読点、そして......のような連続記号が、列の端でどのように処理されるかを確認するために、あえて長く続けています。さらに、英数字の2026とPDFを混ぜて、縦組みの中での表示差も見ます。

  もう一段長く続けます。日本語の縦書きでは、列の高さが足りなくなったときに、禁則に応じて一文字押し出されたり、ぶら下がったりします。その挙動を観察するために、ここでは括弧、句読点、長音符、そして複数の句を連ねて、あえて折り返し位置を作っています。
]

#pagebreak()

#tate(config: (
    kinsoku: default-resolver(mode: "oikomi"),
    layout: (gap: 1.1em, columns: 2, column-gap: 10pt),
  ),
)[
  == Oikomi
  これは追い込みの確認用の長文です。行末に来た「かぎかっこ」や（丸括弧）や、句読点、そして……のような連続記号が、ぶら下がりではなく追い込み寄りに処理されるかを見ます。#ruby("追い込み", "おいこみ")の見え方も合わせて確認します。

  さらに、#hblock[#box(stroke: 0.5pt + gray, inset: 4pt)[横置きの注釈]] と数式#vblock[$integral_0^1 x^2 dif x$]を混ぜ、ブロック系のトークンが縦組みレイアウトでどう収まるかも確認します。

  ここでも長文を続けます。2024、#tcy("IT")、#tcy("123")、GitHub, VS Codeのような短いラベルを連続させ、縦中横の長さ分岐と回転表示の両方を走らせます。
]

#pagebreak()

= Final Stress

As a final test, the next page has a series of edge cases for kinsoku processing, where the break decision should cascade and push multiple characters to the next line.

#v(1em)

#tate(config: (
    font: "Harano Aji Mincho",
    sizing: (
      char-box: 1em,
      ruby-size: 0.45em,
      ruby-offset: 1.05em,
      heading-scales: (1.6, 1.35, 1.15),
    ),
    layout: (gap: 0.95em, columns: 3, column-gap: 8pt),
  ),
)[
  = 総合確認
  ここでは、#strong[総合テスト]、#emph[見た目]、#ruby("縦横", "たてよこ")、#tcy("OK")、#turn[RT]、$a\/b$や#hblock[#rect(width: 24pt, height: 12pt, fill: rgb("b9d4ff"))]を一度にまとめて確認する。

  行の中には、ひらがな、カタカナ、漢字、アルファベット、数字、記号、句読点、括弧、そして長い文章を詰め込む。これで、文字種ごとのレンダリングと列送りの両方を広く試せる。

  == 終わりに
  Bashoの public APIは少ないが、Typst側の組み合わせは多い。
]
