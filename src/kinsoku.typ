// src/kinsoku.typ
// Japanese line-breaking rules (禁則処理)
//
// In vertical typesetting, "lines" are columns. Kinsoku rules prevent:
// 1. Opening brackets from appearing at the end of a column (gyōmatsu kinsoku)
// 2. Closing brackets / period from appearing at the start of a column (gyōtō kinsoku)
//
// Strategy: applied during pagination. When a column break would violate rules,
// tokens are moved between columns.

/// Regex matching characters that must NOT appear at the END of a column.
/// Opening brackets, opening quotation marks.
#let _opening-re = regex("^[\u{ff08}\u{3014}\u{ff3b}\u{ff5b}\u{3008}\u{300a}\u{300c}\u{300e}\u{3010}\\(\\[\\{\u{301d}\u{201c}\u{2018}]$")

/// Regex matching characters that must NOT appear at the START of a column.
/// Closing brackets, closing quotes, periods, commas, small kana, prolonged sound.
#let _closing-re = regex("^[\u{ff09}\u{3015}\u{ff3d}\u{ff5d}\u{3009}\u{300b}\u{300d}\u{300f}\u{3011}\\)\\]\\}\u{301e}\u{201d}\u{2019}\u{3002}\u{3001}\u{ff0c}\u{ff0e}\u{30fb}\u{ff1a}\u{ff1b}\u{30fc}\u{ff5e}\u{3041}\u{3043}\u{3045}\u{3047}\u{3049}\u{3063}\u{3083}\u{3085}\u{3087}\u{308e}\u{30a1}\u{30a3}\u{30a5}\u{30a7}\u{30a9}\u{30c3}\u{30e3}\u{30e5}\u{30e7}\u{30ee}\u{30f5}\u{30f6}\u{ff01}\u{ff1f}]$")

/// Checks whether a token's text is in the opening set.
///
/// - token (dictionary): A token dictionary.
/// -> bool
#let is-opening(token) = {
  if token.type != "char" { return false }
  token.text.match(_opening-re) != none
}

/// Regex matching characters that are allowed to hang (burasagari).
/// Only commas and periods.
#let _hanging-re = regex("^[\u{3001}\u{3002}\u{ff0c}\u{ff0e}]$")

/// Checks whether a token's text is allowed to hang out of the column bottom.
///
/// - token (dictionary): A token dictionary.
/// -> bool
#let is-hanging(token) = {
  if token.type != "char" { return false }
  token.text.match(_hanging-re) != none
}

/// Checks whether a token's text is in the closing set.
///
/// - token (dictionary): A token dictionary.
/// -> bool
#let is-closing(token) = {
  if token.type != "char" { return false }
  token.text.match(_closing-re) != none
}

/// Applies kinsoku shori adjustments to a pair of adjacent columns.
/// Returns (adjusted-current, adjusted-next).
///
/// Rules:
/// 1. If current column ends with an opening bracket -> move it to next column.
/// 2. If next column starts with a closing/period char -> move it to current column
///    as hanging punctuation (zero-height, overflows into gutter).
///
/// Guard: never leave a column completely empty after adjustment.
///
/// - current (array): Token array of the current column.
/// - next (array): Token array of the next column (may be empty).
/// -> (array, array): Adjusted (current, next) column pair.
#let adjust-pair(current, next) = {
  let cur = current
  let nxt = next

  // Rule 1: opening bracket at end of current column -> move to next
  if cur.len() > 1 {
    let last = cur.last()
    if is-opening(last) {
      cur = cur.slice(0, cur.len() - 1)
      nxt = (last,) + nxt
    }
  }

  // Rule 2: closing/period at start of next column -> hang on current
  if nxt.len() > 1 {
    let first = nxt.first()
    if is-closing(first) {
      cur = cur + ((type: "hanging", text: first.text),)
      nxt = nxt.slice(1)
    }
  }

  (cur, nxt)
}

/// Applies kinsoku rules across all columns produced by pagination.
///
/// - columns (array): Array of column token arrays.
/// -> array: Adjusted array of column token arrays.
#let apply-kinsoku(columns) = {
  if columns.len() <= 1 {
    return columns
  }

  let result = columns
  let i = 0
  while i < result.len() - 1 {
    let (cur, nxt) = adjust-pair(result.at(i), result.at(i + 1))
    result.at(i) = cur
    result.at(i + 1) = nxt
    i += 1
  }
  result
}
