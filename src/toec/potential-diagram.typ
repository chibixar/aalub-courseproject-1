#import "@preview/cetz:0.4.2"
#import "math-helpers.typ": _fmt

// points - массив словарей вида:
// (r: 0, phi: 0, label: $R_1$, anchor: "south-east", x-tick: $R_1$, y-tick: [10]), ...
#let potential-diagram(
  points,
  width: 14,
  height: 8,
  x-label: $R", Ом"$,
  y-label: $phi", В"$
) = {
  align(center, cetz.canvas({
    import cetz.draw: *

    // 1. Поиск границ для масштабирования
    let xs = points.map(p => p.r)
    let ys = points.map(p => p.phi)

    // Гарантируем, что начало координат (0,0) всегда в кадре
    let min-x = calc.min(0, ..xs)
    let max-x = calc.max(1, ..xs)
    let min-y = calc.min(0, ..ys)
    let max-y = calc.max(1, ..ys)

    // Добавляем по 15% отступов по краям, чтобы стрелки осей и метки не обрезались
    let dx = (max-x - min-x) * 0.15
    let dy = (max-y - min-y) * 0.15
    let start-x = min-x - dx
    let end-x = max-x + dx
    let start-y = min-y - dy
    let end-y = max-y + dy

    // Вычисляем масштаб
    let scale-x = width / (end-x - start-x)
    let scale-y = height / (end-y - start-y)

    // Функции трансляции реальных координат в координаты холста
    let tx(x) = (x - start-x) * scale-x
    let ty(y) = (y - start-y) * scale-y

    let origin-x = tx(0)
    let origin-y = ty(0)

    // 2. Рисуем оси
    line((origin-x, ty(start-y)), (origin-x, ty(end-y)), mark: (end: ">"), stroke: 1pt)
    content((origin-x, ty(end-y)), anchor: "south-east", padding: 0.1)[#y-label]

    line((tx(start-x), origin-y), (tx(end-x), origin-y), mark: (end: ">"), stroke: 1pt)
    content((tx(end-x), origin-y), anchor: "north-west", padding: 0.1)[#x-label]

    content((origin-x, origin-y), anchor: "north-east", padding: 0.1)[0]

    // 3. Рисуем саму линию диаграммы
    let path-pts = points.map(p => (tx(p.r), ty(p.phi)))
    line(..path-pts, stroke: 1.5pt + black)

    // 4. Рисуем узлы, их названия и проецируем на оси
    for p in points {
      let px = tx(p.r)
      let py = ty(p.phi)

      circle((px, py), radius: 0.08, fill: black)

      // Имя узла (с возможностью принудительно задать ориентацию через anchor)
      // Доступны: "top", "bottom", "left", "right", "north-west", "south-east" и т.д.
      let anchor-pos = p.at("anchor", default: if p.phi >= 0 { "south-west" } else { "north-west" })
      content((px, py), anchor: anchor-pos, padding: 0.15)[#p.label]

      // Проекция на ось X (сопротивления)
      if calc.abs(p.phi) > 0.01 {
        line((px, py), (px, origin-y), stroke: (dash: "dashed", thickness: 0.5pt))
        if calc.abs(p.r) > 0.01 {
           let x-val = p.at("x-tick", default: _fmt(p.r))
           content((px, origin-y), anchor: if p.phi > 0 {"north"} else {"south"}, padding: 0.2)[#x-val]
        }
      }

      // Проекция на ось Y (потенциалы)
      if calc.abs(p.r) > 0.01 {
        line((px, py), (origin-x, py), stroke: (dash: "dashed", thickness: 0.5pt))
        if calc.abs(p.phi) > 0.01 {
           let y-val = p.at("y-tick", default: _fmt(p.phi))
           content((origin-x, py), anchor: "east", padding: 0.1)[#y-val]
        }
      }
    }
  }))
}

// EXAMPLE
#potential-diagram((
  (r: 0,   phi: 0,    label: $R_1$, anchor: "south-east"),

  (r: 2,   phi: -1.6, label: $R_2$, anchor: "north"),
  (r: 4,   phi: -3.2, label: $R_3$, anchor: "north"),

  (r: 6.4, phi: 2.8,  label: $R_4$, x-tick: $R_4$),

  (r: 8.4, phi: 0, label: $R_5$, anchor: "north-west")
))