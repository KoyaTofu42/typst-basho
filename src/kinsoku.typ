// src/kinsoku.typ
// Japanese line-breaking rules (禁則処理)
//
// Each kinsoku module is a self-contained dictionary bundling:
//   - Character sets (forbidden-start, forbidden-end, hanging, unbreakable-chars)
//   - A `decide` callback: (col, token, rules) => (action: str, ...)
//
// The engine iterates over config.kinsoku (an array of modules).
// For each overflow, it calls decide() on each module in order;
// the first non-"break" result wins.

// ---------------------------------------------------------------------------
// Helper functions — operate on a `rules` dictionary, NOT on config
// ---------------------------------------------------------------------------

/// Checks whether a token is in the opening set (must NOT end a column).
#let is-opening(token, rules) = {
  if token.type != "char" { return false }
  rules.forbidden-end.contains(token.text)
}

/// Checks whether a token is allowed to hang out of the column bottom.
#let is-hanging(token, rules) = {
  if token.type != "char" { return false }
  rules.hanging.contains(token.text)
}

/// Checks whether a token is in the closing set (must NOT start a column).
#let is-closing(token, rules) = {
  if token.type != "char" { return false }
  rules.forbidden-start.contains(token.text)
}

/// Checks whether two adjacent tokens form an unbreakable pair (e.g. …… or ——).
#let is-unbreakable-pair(prev, current, rules) = {
  if prev.type != "char" or current.type != "char" { return false }
  rules.unbreakable-chars.contains(prev.text) and prev.text == current.text
}

// ---------------------------------------------------------------------------
// Default character sets shared by burasagari and oikomi
// ---------------------------------------------------------------------------

#let _default-chars = (
  forbidden-start: "）〕］｝〉》」』】)]}〞\u{201d}\u{2019}。、，．・：；ー～ぁぃぅぇぉっゃゅょゎァィゥェォッャュョヮヵヶ！？",
  forbidden-end: "（〔［｛〈《「『【([{〝\u{201c}\u{2018}",
  hanging: "、。，．",
  unbreakable-chars: "—―…‥",
)

// ---------------------------------------------------------------------------
// Built-in decide functions
// ---------------------------------------------------------------------------

/// Calculates the number of characters to push to the next line to avoid
/// any kinsoku violations (cascading push-out).
#let _calculate-push-out(col, token, rules) = {
  let count = 0
  let closing-run = 0
  let current-first = token
  let i = col.len() - 1

  if is-closing(token, rules) {
    count = 1
    closing-run = 1
  } else if col.len() > 0 and is-opening(col.last(), rules) {
    count = 1
  } else if col.len() > 0 and is-unbreakable-pair(col.last(), token, rules) {
    count = 1
  }

  if count == 1 and i >= 0 {
    current-first = col.at(i)
    i -= 1
  }

  while count > 0 and i >= 0 {
    let prev = col.at(i)
    let needs-more = false

    if is-closing(current-first, rules) {
      needs-more = true
      closing-run += 1
    } else if is-unbreakable-pair(prev, current-first, rules) {
      needs-more = true
    } else if is-opening(prev, rules) {
      needs-more = true
    }

    if needs-more {
      count += 1
      current-first = prev
      i -= 1
    } else {
      break
    }
  }

  if closing-run >= 2 and i >= 0 {
    // Push one more char before consecutive forbidden-start characters.
    count += 1
  }

  count
}

/// Burasagari decision logic: hang punctuation, push out everything else.
#let _burasagari-decide(col, token, rules) = {
  if is-hanging(token, rules) {
    return (action: "hang")
  }
  let push-count = _calculate-push-out(col, token, rules)
  if push-count > 0 {
    return (action: "push-out", count: push-count)
  }
  return (action: "break")
}

/// Oikomi decision logic: pull closing chars in instead of pushing out.
#let _oikomi-decide(col, token, rules) = {
  if is-hanging(token, rules) {
    return (action: "hang")
  }
  if is-closing(token, rules) {
    return (action: "pull-in")
  }

  // For Oikomi, we still calculate push-out for opening brackets or unbreakable pairs.
  // We temporarily disable is-closing check for the INITIAL token since it would have
  // been handled by pull-in above, but we still need the cascading logic.
  let push-count = 0
  let current-first = token
  let i = col.len() - 1

  if col.len() > 0 and is-opening(col.last(), rules) {
    push-count = 1
  } else if col.len() > 0 and is-unbreakable-pair(col.last(), token, rules) {
    push-count = 1
  }

  if push-count == 1 and i >= 0 {
    current-first = col.at(i)
    i -= 1
  }

  while push-count > 0 and i >= 0 {
    let prev = col.at(i)
    let needs-more = false
    if is-closing(current-first, rules) { needs-more = true } else if is-unbreakable-pair(prev, current-first, rules) {
      needs-more = true
    } else if is-opening(prev, rules) { needs-more = true }

    if needs-more {
      push-count += 1
      current-first = prev
      i -= 1
    } else {
      break
    }
  }

  if push-count > 0 {
    return (action: "push-out", count: push-count)
  }
  return (action: "break")
}

// ---------------------------------------------------------------------------
// Self-contained kinsoku modules
// ---------------------------------------------------------------------------

/// Standard Japanese line-breaking (ぶら下がり / Burasagari).
/// Hangs punctuation; pushes out closing brackets and unbreakable pairs.
///
/// This is a complete, self-contained dictionary:
///   - Character sets: forbidden-start, forbidden-end, hanging, unbreakable-chars
///   - decide: (col, token, rules) => (action: str, ...)
#let burasagari = _default-chars + (decide: _burasagari-decide)

/// Oikomi (追い込み) line-breaking.
/// Squeezes closing characters into the current column instead of pushing out.
#let oikomi = _default-chars + (decide: _oikomi-decide)
