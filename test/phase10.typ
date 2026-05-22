// test/phase10.typ
// Phase 10 verification: custom kinsoku resolvers via DI

#import "../lib.typ": tate
#import "../src/config.typ": default-opts, merge-config
#import "../src/kinsoku.typ": default-resolver, is-forbidden-start

// Define a custom resolver that pushes out 2 characters when hitting
// a forbidden-start character.
#let extreme-oidashi-resolve(col, token, h, config, cur-h, max-h) = {
  if is-forbidden-start(token, config.kinsoku.forbidden-start) {
    return (action: "push-previous")
  }
  (action: "oidashi")
}

// Build a complete kinsoku config using default-resolver but with
// a custom resolve function.
#let extreme-oidashi = default-resolver(resolve-fn: extreme-oidashi-resolve)

#let my-config = merge-config(default-opts, (
  kinsoku: extreme-oidashi,
  layout: (columns: 2),
))

#set page(width: 8cm, height: 10cm)

= プラグ可能禁則処理

#tate(config: my-config)[
  これはテストです。ここで長い長い文章を書きます。そして、ここで次の行に——行くはずですが、カスタム禁則関数によって挙動が変わるはずです。（極端な追い出し処理テスト）
]
