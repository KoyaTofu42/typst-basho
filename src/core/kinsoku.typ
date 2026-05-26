// src/kinsoku.typ
// Japanese line-breaking rules (禁則処理)
//
// Exports:
//   - default-resolver(..)  — factory that returns a resolver dict with
//     all character sets + built-in resolve function
//   - Standalone helpers for custom resolvers

// ---------------------------------------------------------------------------
// Character-check helpers (reusable by custom resolvers)
// ---------------------------------------------------------------------------

/// Checks whether a token is a forbidden-start character (Gyoto / 行頭禁則).
/// Such characters must NOT appear at the start of a column.
#let is-forbidden-start(token, chars) = {
  if token == none { return false }
  if token.type != "char" { return false }
  chars.contains(token.text)
}

/// Checks whether a token is a forbidden-end character (Gyomatsu / 行末禁則).
/// Such characters must NOT appear at the end of a column.
#let is-forbidden-end(token, chars) = {
  if token == none { return false }
  if token.type != "char" { return false }
  chars.contains(token.text)
}

/// Checks whether a token is hanging-punctuation (burasagari / ぶら下がり).
/// Such characters can visually overflow into the gutter.
#let is-hanging(token, chars) = {
  if token == none { return false }
  if token.type != "char" { return false }
  chars.contains(token.text)
}

/// Checks whether two adjacent tokens form an unsplittable sequence
/// (Buntetsu Kinsoku / 分割禁則), e.g. consecutive dashes or ellipses: —— ……
#let is-unbreakable-pair(prev, current, chars) = {
  if prev == none or current == none { return false }
  if prev.type != "char" or current.type != "char" { return false }
  chars.contains(prev.text) and prev.text == current.text
}

/// Checks whether a token is eligible for spacing compression (Oikomi / 追い込み).
/// Yakumono (約物 / punctuation) typically has 0.5em of compressible space.
#let is-compressible-punctuation(token, chars) = {
  if token == none { return false }
  if token.type != "char" { return false }
  chars.contains(token.text)
}

// ---------------------------------------------------------------------------
// Computation helpers (reusable by custom resolvers)
// ---------------------------------------------------------------------------

/// Calculates the total amount of shrinkable space in a column.
/// Two-stage compression: first counts available internal-aki, then space-after.
#let calculate-shrinkable-space(col, config) = {
  let cb = config.char-box-abs
  let total = 0pt
  for token in col {
    let internal = token.at("internal-aki", default: 0.0) * cb
    let applied = token.at("compression-applied", default: 0pt)
    let available-internal = calc.max(0pt, internal - applied)
    total += available-internal + token.at("space-after", default: 0pt)
  }
  total
}

/// Distributes compression across tokens in the column in two stages:
/// 1. Compress internal-aki.
/// 2. If space is still needed, compress space-after.
#let apply-spacing-compression(col, amount, config) = {
  let cb = config.char-box-abs
  let remaining = amount
  let result = ()

  // Stage 1: Compress internal-aki
  let stage1 = ()
  for token in col {
    if remaining > 0pt {
      let internal = token.at("internal-aki", default: 0.0) * cb
      let applied = token.at("compression-applied", default: 0pt)
      let available = calc.max(0pt, internal - applied)
      if available > 0pt {
        let reduction = calc.min(available, remaining)
        token.insert("compression-applied", applied + reduction)
        remaining -= reduction
      }
    }
    stage1.push(token)
  }

  // Stage 2: Compress space-after
  for token in stage1 {
    if remaining > 0pt {
      let space = token.at("space-after", default: 0pt)
      if space > 0pt {
        let reduction = calc.min(space, remaining)
        token.insert("space-after", space - reduction)
        remaining -= reduction
      }
    }
    result.push(token)
  }

  result
}

/// Returns the compressible amount for a single token.
#let get-compressible-amount(token, config) = {
  if token == none { return 0pt }
  let cb = config.char-box-abs
  let internal = token.at("internal-aki", default: 0.0) * cb
  let applied = token.at("compression-applied", default: 0pt)
  let available = calc.max(0pt, internal - applied)
  available + token.at("space-after", default: 0pt)
}

/// Returns the number of justification points in the column.
#let count-justification-points(col) = {
  let count = 0
  for token in col {
    if token.at("justification-point", default: false) {
      count += 1
    }
  }
  count
}

/// Distributes available space across justification points.
#let justify-line(col, available-space, config) = {
  let count = count-justification-points(col)
  if count > 0 and available-space > 0pt {
    let add = available-space / count
    let max-stretch = config.kinsoku.at("max-stretch", default: none)
    if max-stretch != none {
      add = calc.min(add, max-stretch * config.at("char-box-abs", default: 1em))
    }
    let result = ()
    for token in col {
      if token.at("justification-point", default: false) {
        token.insert("space-after", token.at("space-after", default: 0pt) + add)
      }
      result.push(token)
    }
    return result
  }
  col
}

/// Checks whether a token is valid at the end of a column.
/// Returns false for null tokens and forbidden-end characters.
#let is-valid-line-end(token, forbidden-end-chars) = {
  if token == none { return false }
  if token.type != "char" { return true }
  not forbidden-end-chars.contains(token.text)
}

// ---------------------------------------------------------------------------
// Built-in resolve function
// Implements the priority-based resolution from the kinsoku spec:
//   1. Unbreakable sequences     → push-previous
//   2. Forbidden-start (Gyoto):
//      a. Hanging (burasagari)   → burasagari
//      b. Compressible (oikomi)  → oikomi(amount)
//      c. Otherwise              → push-previous
//   3. Forbidden-end (Gyomatsu)  → push-previous
//   4. Default                   → oidashi
// ---------------------------------------------------------------------------

#let _builtin-resolve(col, token, h, config, cur-h, max-h) = {
  let k = config.kinsoku
  let last = if col.len() > 0 { col.last() } else { none }

  // Priority 0: Unbreakable pairs (Buntetsu Kinsoku)
  if k.at("buntetsu-kinsoku", default: true) and is-unbreakable-pair(last, token, k.unbreakable-chars) {
    return (action: "push-previous")
  }

  // Priority 1–3: Forbidden-start (Gyoto Kinsoku)
  if is-forbidden-start(token, k.forbidden-start) {
    let next-token = k.at("next-token", default: none)

    // Priority 1: Burasagari — hanging punctuation
    if is-hanging(token, k.hanging) and k.mode == "burasagari" {
      if is-forbidden-start(next-token, k.forbidden-start) {
        return (action: "push-previous")
      }
      return (action: "burasagari")
    }

    // Priority 2: Oikomi — spacing compression
    let shrinkable = calculate-shrinkable-space(col, config)
    let overflow = (cur-h + h) - max-h

    if k.mode == "oikomi" and shrinkable >= overflow {
      if is-forbidden-start(next-token, k.forbidden-start) {
        return (action: "push-previous")
      }
      return (action: "oikomi", compression-amount: overflow)
    }

    // Priority 3: Oidashi cascading into push-previous
    return (action: "push-previous")
  }

  // Check Gyomatsu Kinsoku (Forbidden End)
  if is-forbidden-end(last, k.forbidden-end) {
    return (action: "push-previous")
  }

  // Default: break normally
  (action: "oidashi")
}

// ---------------------------------------------------------------------------
// Default resolver factory
// Returns a complete kinsoku configuration dictionary.
// Users override any field by passing named arguments.
// The `resolve` function is the built-in algorithm; set `resolve` to replace
// it entirely while keeping helper access via imports.
// ---------------------------------------------------------------------------

#let default-resolver(
  forbidden-start: "）〕］｝〉》」』】)]}〞\u{201d}\u{2019}。、，．・：；ー～ぁぃぅぇぉっゃゅょゎァィゥェォッャュョヮヵヶ！？",
  forbidden-end: "（〔［｛〈《「『【([{〝\u{201c}\u{2018}",
  hanging: "、。，．",
  unbreakable-chars: "—―…‥",
  buntetsu-kinsoku: true,
  compressible-punctuation: "、。，．",
  mode: "burasagari",
  compression-per-punct: 0.5,
  consecutive-compression: 0.25,
  max-stretch: 0.5,
  resolve-fn: none,
) = {
  let rfn = if resolve-fn != none { resolve-fn } else { _builtin-resolve }
  (
    forbidden-start: forbidden-start,
    forbidden-end: forbidden-end,
    hanging: hanging,
    unbreakable-chars: unbreakable-chars,
    buntetsu-kinsoku: buntetsu-kinsoku,
    compressible-punctuation: compressible-punctuation,
    mode: mode,
    compression-per-punct: compression-per-punct,
    consecutive-compression: consecutive-compression,
    max-stretch: max-stretch,
    resolve: rfn,
  )
}
