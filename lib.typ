// lib.typ
// Public API for Basho — Vertical Japanese Typesetting

#import "src/layout.typ": layout-tate
#import "src/flatten.typ": flatten
#import "src/renderer.typ": render-char-token
#import "src/config.typ": default-opts, default-rendering, default-tcy, merge-config
#import "src/kinsoku.typ": burasagari, oikomi

/// Forces a sequence of characters to be rendered as Tate-chu-yoko (inline horizontal).
///
/// - body (str): The text to render horizontally.
/// -> content: Metadata tag instructing the engine to render as TCY.
#let tcy(body) = metadata((type: "tcy", text: body, forced: true))

/// Forces a sequence of characters to be rendered upright (vertical), one per box.
/// Useful for short Latin abbreviations (e.g. "JIS") that should appear upright
/// in vertical text rather than rotated.
///
/// - body (str): The text to render upright.
/// -> content: Metadata tag instructing the engine to render as upright chars.
#let vert(body) = metadata((type: "tcy", text: body, forced: "char"))

/// Renders arbitrary content rotated 90 degrees clockwise.
/// Useful for vertical equations, figures, or nested blocks where you want
/// to preserve native font settings.
///
/// - body (content): The content to rotate.
/// -> content: Metadata tag instructing the engine to render as rotated content.
#let turn(body) = metadata((type: "turn", text: body))

/// Renders arbitrary content rotated 90 degrees clockwise without restricting width.
/// Ideal for multiline equations or block elements that stretch horizontally forever.
#let vblock(body) = metadata((type: "vblock", text: body))

/// Renders arbitrary content upright (not rotated) in the middle of a paragraph.
/// Ideal for figures, images, or elements that should maintain their original orientation.
#let hblock(body) = metadata((type: "hblock", text: body))

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

  // Register list module renderers into the rendering array
  cfg.rendering.push(cfg.list.bullet)
  cfg.rendering.push(cfg.list.numbered)

  let tokens = flatten(body, cfg)

  // Run rendering module hooks (normalization etc.)
  for module in cfg.rendering {
    if "transform" in module {
      tokens = (module.transform)(tokens, module, cfg)
    }
  }
  // Run TCY module hooks (filtering etc.)
  for module in cfg.tcy {
    tokens = (module.filter)(tokens, module, cfg)
  }

  layout-tate(tokens, cfg)
}

/// Renders native Typst content vertically inline (no pagination).
/// Use when you need vertical text inside shapes or inline blocks.
///
/// - body (content | str): The content to render vertically.
/// - font (str): Font family to use. Overrides config if provided.
/// - config (dictionary): Custom Dependency Injection configuration.
/// -> content: Inline vertical stack of rendered glyphs.
#let tate-inline(body, font: none, config: (:)) = {
  let cfg = merge-config(default-opts, config)
  if font != none { cfg.font = font }

  // Keep render hooks consistent with the main pipeline.
  let tokens = flatten(body, cfg)
  for module in cfg.rendering {
    if "transform" in module {
      tokens = (module.transform)(tokens, module, cfg)
    }
  }
  for module in cfg.tcy {
    tokens = (module.filter)(tokens, module, cfg)
  }

  let rendered = tokens
    .filter(token => token.type != "newline" and token.type != "heading-anchor")
    .map(token => render-char-token(token, cfg.font, cfg))

  stack(
    dir: ttb,
    spacing: 0pt,
    ..rendered,
  )
}
