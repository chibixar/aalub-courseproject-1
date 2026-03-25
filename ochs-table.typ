#import "dependencies.typ": *

#let ochs-table(body) = [

  = Таблица истинности ОЧC

  #encoding-as-text(code-custom)

  // ОПРЕДЕЛЯЕМ ПРАВИЛО МАСКИ
  // Для ОЧС 1-го типа: b не может быть 2 или 3.
  #let ochs-mask = (a, b, p) => (b == 2 or b == 3)

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

  // #let kmap-grid-p3 = tt-to-map-grid(
  //     gray-cols: gray-code(3),
  //     gray-rows: gray-code(2),
  //     encoded-rows: encoded-ochs,
  //     in-cols: (0, 1, 2, 3, 4),
  //     out-col: 5,
  // )

//   #text(repr(encoded-ochs))
]

#show: ochs-table