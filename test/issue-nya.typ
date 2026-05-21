// test/issue-nya.typ
#import "../lib.typ": tate

#set page(width: 30pt, height: 230pt, margin: 0pt)
#set text(font: "Harano Aji Mincho", size: 12pt)

// 230pt / 12pt = 19.16 chars. So 19 chars fit exactly.
// 19 chars:
#tate(config: (sizing: (char-box: 12pt)))[あいうえおかきくけこさしすせそたちニャーニャー]
