// src/config.typ
// Configuration state and merge engine for Basho DI architecture

#import "kinsoku.typ": burasagari

// ---------------------------------------------------------------------------
// Default TCY module — self-contained
// ---------------------------------------------------------------------------

/// Default TCY (tate-chu-yoko) processing module.
/// Bundles the detection pattern, sizing, and filter logic together.
#let default-tcy = (
  pattern: regex("^[A-Za-z0-9]+$"),
  sizes: (1em, 0.65em, 0.5em),  // for len <=2, ==3, >=4

  /// Filters TCY tokens: only 1-2 char runs stay as TCY.
  /// Runs of 3+ are split into individual vertical characters.
  filter: (tokens, module, config) => {
    let new-tokens = ()
    for t in tokens {
      if t.type == "tcy" {
        if t.text.clusters().len() <= 2 {
          new-tokens.push(t)
        } else {
          for ch in t.text.clusters() {
            new-tokens.push((type: "char", text: ch))
          }
        }
      } else {
        new-tokens.push(t)
      }
    }
    new-tokens
  },
)

// ---------------------------------------------------------------------------
// Default rendering module — self-contained
// ---------------------------------------------------------------------------

/// Default rendering module.
/// Bundles character normalization, dash scaling, and custom node renderers.
#let default-rendering = (
  dash-scale: 1.25em,
  node-renderers: (:),  // type-name -> (token, font, config) => content

  /// Normalizes problematic characters.
  /// U+2014 (EM DASH) and U+2500 (BOX DRAWING) → U+2015 (HORIZONTAL BAR).
  transform: (tokens, module, config) => {
    tokens.map(t => {
      if t.type == "char" and (t.text == "—" or t.text == "─") {
        t.text = "―"
      }
      t
    })
  },
)

#import "spacing.typ": default-spacing
#import "turn.typ": default-turn
#import "vblock.typ": default-vblock
#import "hblock.typ": default-hblock


// ---------------------------------------------------------------------------
// Default options
// ---------------------------------------------------------------------------

/// Default options dictionary for Basho.
#let default-opts = (
  font: none,
  features: ("vert", "vrt2"),

  sizing: (
    char-box: 1em,
    ruby-size: 0.5em,
    ruby-offset: 1em,
    heading-scales: (1.5, 1.3, 1.15),   // h1, h2, h3
  ),

  layout: (
    columns: 1,
    gap: 1em,
    column-gap: 2em,
    hooks: (),  // array of (cols, font, gap, config) => content; last wins
  ),

  kinsoku: (burasagari,),            // array of self-contained rule modules
  tcy: (default-tcy,),               // array of self-contained tcy modules
  rendering: (default-rendering, default-spacing, default-turn, default-vblock, default-hblock),   // array of self-contained rendering modules
)

// ---------------------------------------------------------------------------
// Merge engine
// ---------------------------------------------------------------------------

/// Recursively merges a user configuration dictionary into a base configuration.
/// Ensures nested dictionaries are merged rather than overwritten completely.
/// Arrays (like kinsoku, tcy, rendering) are replaced wholesale — this is
/// intentional so users can swap out entire module arrays.
///
/// - base (dictionary): The base configuration (e.g., default-opts).
/// - user (dictionary): The user's configuration overrides.
/// -> dictionary: The merged configuration.
#let merge-config(base, user) = {
  let result = base
  for (key, val) in user {
    if key in result and type(result.at(key)) == dictionary and type(val) == dictionary {
      result.insert(key, merge-config(result.at(key), val))
    } else {
      result.insert(key, val)
    }
  }
  result
}
