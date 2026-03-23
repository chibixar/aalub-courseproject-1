#let mathtype-mimic(receive: false, body) = {
  // Set the MathType-equivalent font
  show math.equation: set text(font: "STIX Two Math", size: 14pt)

  // FIX 1: Decimal comma (removes space after comma in numbers like 1,5)
  show math.equation: it => {
    show ",": math.class("normal", ",")
    it
  }

  // FIX 2: GLOBAL LOWERED SUBSCRIPTS
  // Intercepts all subscripts (like R_5) automatically!
  show math.attach: it => {
    let b = it.at("b", default: none)

    let fixed-base = math.italic(it.base)

    // Check if there is a subscript AND it hasn't been padded yet (prevents infinite loop!)
    if b != none and b.func() != pad {
      // Rebuild the attachment with our modifications
      math.attach(
        fixed-base,
        t: it.at("t", default: none), // preserve superscripts if they exist
        // Adjust 'dy' to push further down, and 'bottom' pad to push the fraction line away
        b: pad(bottom: 1em, move(dx: 0.1em, dy: 0.5em, b)),
        tl: it.at("tl", default: none),
        bl: it.at("bl", default: none),
        tr: it.at("tr", default: none),
        br: it.at("br", default: none),
      )
    } else {
      it
    }
  }

  // FIX 3: GLOBAL FRACTION PADDING (mimics looser MathType division gaps)
  show math.frac: it => {
    // Check if we already padded it (prevents infinite loop crash!)
    if it.num.func() != pad {
      math.frac(
        pad(bottom: 0.3em, it.num), // Push numerator up away from the line
        pad(top: 0.3em, it.denom) // Push denominator down away from the line
      )
    } else {
      it
    }
  }

  block(breakable: false, width: 100%, [
    #if (receive) [Получаем]
    #align(center, block(above: 2em, below: 2em)[
      // 2. Make the equations INSIDE this group tightly packed
      #show math.equation.where(block: true): set block(spacing: 0.6em)

      #body
    ])
  ])
}

// EXAMPLE
// for the whole file you can use #show: mathtype-mimic
#mathtype-mimic[
  $
  R_23456 = (R_5 thin R_2346) / (R_5 + R_2346)
          = (1.5 dot 3.52) / (1.5 + 3,52)
          = 1.05 "кОм."
  $
]