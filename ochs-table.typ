#import "dependencies.typ": *

#let ochs-table(body) = [

  = Таблица истинности ОЧC

  #encoding-as-text(code-custom)

  // ОПРЕДЕЛЯЕМ ПРАВИЛО МАСКИ
  // Для ОЧС 1-го типа: b не может быть 2 или 3.
  #let ochs-mask = (a, b, p) => (b == 2 or b == 3)
//   #let ochs-mask = (a, b, p) => false // to test

  #let raw-ochs = generate-base-ochs(mask-fn: ochs-mask)

  #let schema-ochs = (code-custom, code-custom, none, none, code-custom, none)
  #let encoded-ochs = encode-tt(raw-ochs, schema-ochs)

  #let encoded-ochs = sort-tt(encoded-ochs, sort-cols: (0, 1, 2, 3, 4))

  #draw-truth-table(
    // Настраиваем жирные линии как на скрине
    bold-vlines: (0, 2, 4, 5, 8, - 1),
    bold-hlines: (0, 1, -1),

    headers: (
      // Первая строка шапки (буквы)
      strong($a_1$), strong($a_2$),
      strong($b_1$), strong($b_2$),
      strong($p$),
      strong($Pi$),
      strong($S_1$), strong($S_2$),
      strong[Пример операции \ в четверичной с/с],
    ),
    rows: encoded-ochs
  )

  #let kmap-grid-p3 = tt-to-map-grid(
      encoded-ochs,
      (0, 1, 2, 3, 4),
      5, // П
      gray-cols: gray-code(3),
      gray-rows: gray-code(2),
      default-val: "Z", // to detect errors
  )

  #align(center)[
  #karnaugh-map(
    x-labels: gray-code(3),
    y-labels: gray-code(2),
    hide: 0,
    vars-label: ($a_1 a_2$, $b_1 b_2 p$),

    grid-data: kmap-grid-p3,

//     groups: (
//       (r: 0, c: 5, w: 1, h: 4, color: rgb("#00b0f0"), pad: 2pt, dash: "dashed"),
//       (r: 1, c: 4, w: 2, h: 2, color: rgb("#ff0000"), pad: 4pt, dash: "dash-dotted"),
//       (r: 0, c: 4, w: 2, h: 1, color: rgb("#7030a0"), pad: 6pt, dash: "dotted"),
//
//       (r: 0, c: 0, w: 2, h: 1, color: rgb("#4a7bbb"), pad: 2pt),
//       (r: 0, c: 1, w: 2, h: 1, color: rgb("#92d050"), pad: 5pt),
//       (r: 0, c: 1, w: 1, h: 2, color: rgb("#ffff00"), pad: 8pt),
//
//       (r: 2, c: 0, w: 4, h: 1, color: rgb("#ffc000"), pad: 2pt),
//       (r: 2, c: 1, w: 2, h: 1, color: rgb("#00b050"), pad: 5pt),
//       (r: 2, c: 5, w: 2, h: 1, color: rgb("#00b050"), pad: 5pt),
//     )
  )
]
]

#show: ochs-table