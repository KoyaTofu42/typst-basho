// test/phase3.typ
// Phase 3 verification: TCY (tate-chu-yoko) for Latin/number runs

#import "../lib.typ": tate

#set page(width: 300pt, height: 400pt, margin: 20pt)
#set text(size: 14pt)

= Phase 3 Test: TCY (Tate-chu-yoko)

== Test 1: Mixed CJK and Latin/numbers
Expected: "abc" and "123" rotated 90°, CJK upright
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
