// test/phase10.typ
// Phase 10 verification: Self-Contained Kinsoku Modules

#import "../lib.typ": tate
#import "../src/config.typ": default-opts, merge-config

// Define a completely custom kinsoku module — self-contained dict.
// It carries its own character sets AND its own decide function.
// This one pushes out TWO characters when hitting a closing bracket.
#let extreme-oidashi = (
  forbidden-start: "）〕］｝〉》」』】)]}。、！？",
  forbidden-end: "（〔［｛〈《「『【([{",
  hanging: "、。，．",
  unbreakable-chars: "—―…‥",

  decide: (col, token, rules) => {
    if token.type == "char" and rules.forbidden-start.contains(token.text) {
      return (action: "push-out", count: 2)  // Push out 2 chars!
    }
    return (action: "break")
  },
)

#let my-config = merge-config(default-opts, (
  kinsoku: (extreme-oidashi,),  // Inject our custom module!
  layout: (columns: 2),
))

#set page(width: 8cm, height: 10cm)

= プラグ可能禁則処理

#tate(config: my-config)[
  これはテストです。ここで長い長い文章を書きます。そして、ここで次の行に——行くはずですが、カスタム禁則関数によって挙動が変わるはずです。（極端な追い出し処理テスト）
]
