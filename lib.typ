// lib.typ
// Public API for Basho — Vertical Japanese Typesetting

#import "src/main.typ": hblock, ruby, tate, tate-inline, tcy, turn, vblock, vert
#import "src/core/kinsoku.typ": default-resolver


/// Standalone helpers are exported for building custom resolvers
#let kinsoku = {
  import "src/core/kinsoku.typ": *
  (
    "if-forbidden-start": is-forbidden-start,
    "is-forbidden-end": is-forbidden-end,
    "is-hanging": is-hanging,
    "is-unbreakable-pair": is-unbreakable-pair,
    "is-compressible-punctuation": is-compressible-punctuation,
    "calculate-shrinkable-space": calculate-shrinkable-space,
    "apply-spacing-compression": apply-spacing-compression,
    "get-compressible-amount": get-compressible-amount,
    "count-justification-points": count-justification-points,
    "justify-line": justify-line,
    "is-valid-line-end": is-valid-line-end,
    "default-resolver": default-resolver,
  )
}

/// Token utilities are exported for building custom transforms and classifiers
#let token-schema = {
  import "src/core/token.typ": *
  ("token": token, "merge-token": merge-token, "is-token-type": is-token-type)
}
