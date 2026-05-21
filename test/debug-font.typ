#set text(font: "Arial", size: 10pt)
#context {
  let m1 = measure(text("Testing")).width
  let m2 = measure(text(font: "Courier", size: 20pt, "Testing")).width
  panic("m1: " + repr(m1) + ", m2: " + repr(m2))
}
