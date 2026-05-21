// Debug: check vertical positioning of place() + context output
#set page(width: 200pt, height: 150pt, margin: 10pt)
#set text(size: 12pt)

// Direct box — should start at top-left, 130pt height available
#place(top + left, rect(width: 5pt, height: 130pt, fill: red))

// Simulate what layout-tate does: place() + context with align
#place(context {
  layout(size => {
    // measurement — invisible
  })
})

#context {
  // This is where the columns go
  align(right + top,
    rect(width: 12pt, height: 120pt, fill: blue.lighten(50%))
  )
}
