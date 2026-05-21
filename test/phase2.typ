// test/phase2.typ
// Phase 2 verification: multi-line RTL column layout

#import "../lib.typ": tate

#set page(width: 300pt, height: 300pt, margin: 20pt)
#set text(size: 12pt)

= Phase 2 Test: Multi-line RTL Columns

== Test 1: Two columns (ABC / DEF)
Expected: "DEF" on the right, "ABC" on the left
#tate("ABC\nDEF")

#v(1em)
== Test 2: Three columns of Japanese
Expected: right-to-left reading order (col1 rightmost)
#tate("春の\n海の\n声が")

#v(1em)
== Test 3: Consecutive newlines (empty column)
#tate("あ\n\nい")

#v(1em)
== Test 4: Single line (no newlines, backward compat)
#tate("日本語")
