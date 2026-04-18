#let div-corner-step(dividend, divisor, steps, quotient: none) = {
  let left-grid-items = ()
  left-grid-items.push([])
  left-grid-items.push(box(inset: (bottom: 2pt, top: 2pt))[#dividend])

  for step in steps {
    left-grid-items.push(box(inset: (bottom: 2pt, top: 2pt, right: 4pt))[#move(dy: -0.65em)[$-$]])
    left-grid-items.push(box(stroke: (bottom: 0.5pt), inset: (bottom: 2pt, top: 2pt))[#step.at(0)])
    left-grid-items.push([])
    left-grid-items.push(box(inset: (bottom: 2pt, top: 2pt))[#step.at(1)])
  }

  // Левая колонка текущего уровня
  let left-col = grid(
    columns: 2,
    align: (right, right),
    ..left-grid-items
  )

  if type(quotient) == array {
    // Если частное — это массив (результат вложенного div-corner-step)
    let q-left = quotient.at(0)
    let q-rights = quotient.slice(1)

    let mid-col = box(
      stroke: (left: 0.5pt), // Вертикальная линия
      grid(
        columns: 1,
        align: left,
        box(inset: (left: 4pt, bottom: 2pt, top: 2pt))[#divisor],
        box(width: 100%, inset: (left: 4pt, top: 2pt, bottom: 2pt))[
          // Магия: линия рисуется поверх, удлиняясь ровно на 8pt
          // (4pt левый отступ + 4pt отступ между колонками сетки),
          // чтобы идеально стыковаться со следующей вертикальной линией!
          #place(top + left, dx: -4pt, dy: -2pt, line(length: 100% + 8pt, stroke: 0.5pt))
          #q-left
        ]
      )
    )
    return (left-col, mid-col, ..q-rights)
  } else {
    // Базовый случай (конец каскада, обычное число)
    let right-col = box(
      stroke: (left: 0.5pt),
      grid(
        columns: 1,
        align: left,
        box(inset: (left: 4pt, bottom: 2pt, top: 2pt))[#divisor],
        box(width: 100%, inset: (left: 4pt, top: 2pt, bottom: 2pt))[
          // Для последнего столбца линию никуда продлевать не нужно
          #place(top + left, dx: -4pt, dy: -2pt, line(length: 100% + 4pt, stroke: 0.5pt))
          #quotient
        ]
      )
    )
    return (left-col, right-col)
  }
}

// Главная обертка, которая собирает всё в единый Grid
#let div-corner(dividend, divisor, steps, quotient: none) = {
  let cols = div-corner-step(dividend, divisor, steps, quotient: quotient)
  grid(
    columns: cols.len(),
    column-gutter: 4pt, // Фиксированный зазор между всеми колонками
    align: top,
    ..cols
  )
}

// EXAMPLE
#block(width: 20%, [
  #div-corner(
    [44],[4],
    (
      ([4#hide[0]], [4]),
      ([4], [0])
    ),
    quotient: div-corner(
      [11], [4],
      (
        ([8], [3]),
      ),
      quotient: [2]
    )
  )
])
