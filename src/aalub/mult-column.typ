#let mult-column(start, steps) = {
  let rows = ()
  rows.push(([], box(inset: (bottom: 2pt, top: 2pt))[#start]))
  for step in steps {
    rows.push((
      box(inset: (bottom: 2pt, top: 2pt, right: 4pt))[#align(right)[$*$]],
      // Здесь width: 100% нужен специально, чтобы линия умножения закрывала всю колонку
      box(stroke: (bottom: 0.5pt), inset: (bottom: 2pt, top: 2pt), width: 100%, align(right)[#step.at(0)])
    ))
    rows.push(([], box(inset: (bottom: 2pt, top: 2pt))[#step.at(1)]))
  }
  grid(
    columns: 2,
    align: (right, right),
    ..rows.flatten()
  )
}

// EXAMPLE
#block(width: 10%, [
  #mult-column([0,17], (
    ([4], [0,68]),
    ([4],[2,72]),
    ([4], [2,88]),
    ([4],[3,52])
  ))
])