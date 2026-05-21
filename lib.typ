// lib.typ
// Public API for Basho — Vertical Japanese Typesetting

#import "src/layout.typ": layout-tate
#import "src/flatten.typ": flatten
#import "src/config.typ": default-opts, merge-config, default-tcy, default-rendering
#import "src/kinsoku.typ": burasagari, oikomi

/// Forces a sequence of characters to be rendered as Tate-chu-yoko (inline horizontal).
///
/// - body (str): The text to rotate.
/// -> content: Metadata tag instructing the engine to render as TCY.
#let tcy(body) = metadata((type: "tcy", text: body))

/// Attaches phonetic ruby (furigana) to base characters.
///
/// - base (str): The base text (e.g. "漢字").
/// - rt (str): The ruby text (e.g. "かんじ").
/// -> content: Metadata tag instructing the engine to render with ruby.
#let ruby(base, rt) = metadata((type: "ruby", text: base, ruby: rt))

/// Renders native Typst content vertically (tategaki / 縦書き).
///
/// - body (content | str): The content to render vertically.
/// - font (str): Font family to use. Overrides config if provided.
/// - columns (int): Number of horizontal rows (段組み). Overrides config if provided.
/// - column-gap (length): Gap between horizontal rows. Overrides config if provided.
/// - config (dictionary): Custom Dependency Injection configuration.
/// -> content: Vertically rendered paginated content.
#let tate(body, font: none, columns: none, column-gap: none, config: (:)) = {
  // Merge user config with defaults
  let cfg = merge-config(default-opts, config)
  
  // Legacy params override config for backward compatibility
  if font != none { cfg.font = font }
  if columns != none { cfg.layout.insert("columns", columns) }
  if column-gap != none { cfg.layout.column-gap = column-gap }

  let tokens = flatten(body, cfg)
  
  // Run rendering module hooks (normalization etc.)
  for module in cfg.rendering {
    tokens = (module.transform)(tokens, module, cfg)
  }
  // Run TCY module hooks (filtering etc.)
  for module in cfg.tcy {
    tokens = (module.filter)(tokens, module, cfg)
  }
  
  layout-tate(tokens, cfg)
}
