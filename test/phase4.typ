// test/phase4.typ
// Phase 4 verification: auto-pagination by page height

#import "../lib.typ": tate

// Small page to force column breaks and page breaks
#set page(width: 200pt, height: 150pt, margin: 20pt)
#set text(size: 12pt)

// Test 1: Long text that should auto-wrap into multiple columns
// With ~110pt usable height at 12pt, about 9 chars per column
// 20 chars should produce 3 columns, fitting on one page
#tate("あいうえおかきくけこさしすせそたちつてと")

#pagebreak()

// Test 2: Very long text that should overflow to next page
// 60 chars: ~7 columns needed. With ~160pt usable width, about 5-6 cols per page.
// Should produce a page break.
#tate(
  "一二三四五六七八九十壱弐参四伍六七八九廿一二三四五六七八九十壱弐参四伍六七八九廿一二三四五六七八九十壱弐参四伍六七八九廿一二三四五六七八九十壱弐参四伍六七八九廿一二三四五六七八九十壱弐参四伍六七八九廿一二三四五六七八九十壱弐参四伍六七八九廿",
)

#pagebreak()

// Test 3: Explicit newlines still force column breaks
#tate("春夏\n秋冬")

#pagebreak()

// Test 4: Mixed TCY and CJK with auto-pagination
#tate("令和7年5月21日は晴天なり朝から夕方まで")

#pagebreak()

// Test 5: Single column (backward compat)
#tate("猫")
