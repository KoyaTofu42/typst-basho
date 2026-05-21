#let check(c) = {
  if type(c) == content {
    panic("Type is: " + repr(c.func()) + ", fields: " + repr(c.fields()))
  }
}

#check($a$)
