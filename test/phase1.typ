// test/phase1.typ
// Phase 1 verification: basic vertical rendering

#import "../lib.typ": tate

#set page(width: 200pt, height: 300pt, margin: 20pt)
#set text(size: 12pt)

= Phase 1 Test: Single-Column Vertical Rendering

== Test 1: Basic Japanese text
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
