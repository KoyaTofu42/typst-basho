#let test(c) = {
  panic("fields: " + repr(c.fields()))
}

#test(heading(level: 1, "Heading"))
