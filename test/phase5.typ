// test/phase5.typ
// Phase 5 verification: Kinsoku Shori (Japanese line-breaking rules)

#import "../lib.typ": tate

// Small page: 130pt usable height at 12pt = 10 chars per column
#set page(width: 200pt, height: 150pt, margin: 10pt)
#set text(size: 12pt)

// Test 1: Opening bracket at column end should move to next column.
// "あいうえおかきくけ「こ" = 11 chars. Without kinsoku, column would be:
//   col1: あいうえおかきくけ「 (10 chars, 「 at bottom — BAD)
//   col2: こ
// With kinsoku, 「 should move to next column:
//   col1: あいうえおかきくけ (9 chars)
//   col2: 「こ
#tate("あいうえおかきくけ「こ")

#pagebreak()

// Test 2: Closing bracket at column start should hang on previous column.
// "あいうえおかきくけこ」さ" = 12 chars (incl bracket).
// Without kinsoku, column would be:
//   col1: あいうえおかきくけこ (10 chars)
//   col2: 」さ  (」 at top — BAD)
// With kinsoku, 」 should hang on col1:
//   col1: あいうえおかきくけこ + 」(hanging)
//   col2: さ
#tate("あいうえおかきくけこ」さ")

#pagebreak()

// Test 3: Period at column start should hang on previous column.
// "あいうえおかきくけこ。さしす" = 14 chars (incl period).
//   col1: あいうえおかきくけこ + 。(hanging)
//   col2: さしす
#tate("あいうえおかきくけこ。さしす")

#pagebreak()

// Test 4: Both rules combined — opening then closing across break.
// "あいうえおかきくけ「こ」さ" = 13 chars (incl brackets).
// 「 should not end col1, 」 should not start col2.
#tate("あいうえおかきくけ「こ」さ")

#pagebreak()

// Test 5: No kinsoku needed — normal text should be unaffected.
#tate("あいうえおかきくけこさしすせそたちつてと")
