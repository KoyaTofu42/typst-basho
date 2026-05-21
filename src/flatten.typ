// src/flatten.typ
// Content tree traversal for Typst native markup

#import "parser.typ": tokenize

/// Flattens a native Typst content tree into an array of Basho tokens.
/// This enables support for inline macros (like `#ruby`) and native styling (like `*bold*`).
///
/// - c (content | str | array): The content to flatten.
/// -> array: An array of token dictionaries.
#let flatten(c) = {
  let tokens = ()
  
  if type(c) == array {
    for child in c {
      tokens += flatten(child)
    }
  } else if type(c) == str {
    tokens += tokenize(c)
  } else if type(c) == content {
    let fname = repr(c.func())
    
    if fname == "metadata" {
      if type(c.value) == dictionary and "type" in c.value {
        // Custom macros like ruby() or tcy() injected via metadata
        tokens.push(c.value)
      }
    } else if fname == "space" {
      tokens.push((type: "char", text: " "))
    } else if fname == "parbreak" or fname == "linebreak" {
      tokens.push((type: "newline", text: "\n"))
    } else if c.has("children") {
      for child in c.children {
        tokens += flatten(child)
      }
    } else if c.has("body") {
      // Elements like strong, emph, underline
      let inner = flatten(c.body)
      if fname == "strong" {
        inner = inner.map(t => t + (bold: true))
      } else if fname == "emph" {
        inner = inner.map(t => t + (italic: true))
      }
      tokens += inner
    } else if c.has("text") {
      // Native text elements
      tokens += tokenize(c.text)
    }
  }
  
  tokens
}
