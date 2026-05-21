#let check(s) = {
  s.match(regex("^[^\s\p{P}]$")) != none
}

#let res1 = check("あ")
#let res2 = check("漢")
#let res3 = check("。")
#let res4 = check(" ")

#assert(res1 == true)
#assert(res2 == true)
#assert(res3 == false)
#assert(res4 == false)

OK!
