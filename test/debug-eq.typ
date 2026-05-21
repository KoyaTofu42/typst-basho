#let test(c) = {
  if repr(c.func()) == "figure" {
    panic("Is figure! ")
  }
}

#test(figure(image("test/phase12-1.png")))
