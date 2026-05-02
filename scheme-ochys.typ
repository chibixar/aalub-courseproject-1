#import "@preview/cetz:0.3.2"

// === НАСТРОЙКИ СТРАНИЦЫ (Формат А3, альбомная) ===
#set page(
  paper: "a3",
  flipped: true,
  margin: (left: 20mm, top: 5mm, right: 5mm, bottom: 5mm),
  background: [
    #place(top + left, dx: 20mm, dy: 5mm)[
      #rect(width: 395mm, height: 287mm, stroke: 1pt)
    ]
  ]
)

#set text(font: "Arial", size: 10pt)

// === ОСНОВНОЙ ХОЛСТ СХЕМЫ ===
#place(top + left, dx: 20mm, dy: 5mm)[
  #cetz.canvas(length: 0.8cm, {
    import cetz.draw
    
    // ==========================================
    // ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
    // ==========================================
    
    let gost-gate(x, y, pins, inv-out: false, text-str: "&") = {
      let w = 2.0
      let h = calc.max(1.5, pins * 0.8)
      
      draw.rect((x, y), (x + w, y - h), fill: white)
      draw.content((x + 0.4, y - 0.4), [*#text-str*])
      
      if inv-out {
        draw.circle((x + w + 0.2, y - h/2.0), radius: 0.2, fill: white)
        draw.line((x + w + 0.4, y - h/2.0), (x + w + 1.5, y - h/2.0))
      } else {
        draw.line((x + w, y - h/2.0), (x + w + 1.5, y - h/2.0))
      }
      
      return range(pins).map(i => y - (i + 0.5) * (h / pins))
    }

    let gost-not(x, y) = {
      draw.rect((x, y), (x + 1.0, y - 1.0), fill: white)
      draw.content((x + 0.5, y - 0.5), "1")
      draw.circle((x + 0.5, y - 1.15), radius: 0.15, fill: white)
    }

    // ==========================================
    // 1. ОТРИСОВКА ВХОДНОЙ ШИНЫ
    // ==========================================
    let inputs = (
      ("P1", $P_1$), ("x1", $x_1$), ("x2", $x_2$), 
      ("y1", $y_1$), ("y2", $y_2$), ("h", $h$)
    )
    let bus = (:)
    
    let bus-start-x = 2.0
    let bus-top-y = -2.0
    let bus-bottom-y = -33.0

    for (i, pair) in inputs.enumerate() {
      let var = pair.at(0)
      let sym = pair.at(1)
      let bx = bus-start-x + i * 2.5
      
      draw.content((bx, bus-top-y + 1.0), sym)
      
      draw.line((bx, bus-top-y), (bx, bus-bottom-y))
      draw.line((bx, bus-top-y - 1.5), (bx + 1.2, bus-top-y - 1.5))
      draw.circle((bx, bus-top-y - 1.5), radius: 0.1, fill: black)
      
      gost-not(bx + 0.7, bus-top-y - 1.5)
      let inv-bx = bx + 1.2
      draw.line((inv-bx, bus-top-y - 2.8), (inv-bx, bus-bottom-y))
      
      bus.insert(var, (bx, inv-bx)) 
    }

    let route-input(var-name, is-inv, gate-x, pin-y) = {
      let bx = if is-inv { bus.at(var-name).at(1) } else { bus.at(var-name).at(0) }
      draw.line((bx, pin-y), (gate-x, pin-y))
      draw.circle((bx, pin-y), radius: 0.08, fill: black)
    }

    // ==========================================
    // 2. ГЕНЕРАЦИЯ ЛОГИКИ
    // ==========================================
    let level1-x = 22.0
    let current-y = -2.0
    
    // --- ФУНКЦИЯ P ---
    let p-pins = gost-gate(level1-x, current-y, 3, inv-out: false)
    route-input("x2", false, level1-x, p-pins.at(0))
    route-input("y1", false, level1-x, p-pins.at(1))
    route-input("h",  false, level1-x, p-pins.at(2))
    draw.content((level1-x + 4.0, current-y - 1.2), $P$)
    
    current-y -= 3.5

    // --- ФУНКЦИЯ Q1 ---
    let q1-terms = (
      (("y1", true),  ("y2", true),  ("h", true)),
      (("x1", false), ("y1", true)),
      (("P1", true),  ("x1", false), ("x2", true)),
      (("P1", false), ("x1", false), ("x2", false)),
      (("P1", false), ("x1", true),  ("x2", true)),
      (("x1", false), ("y1", false), ("h", false)),
      (("P1", true),  ("x1", true),  ("x2", false), ("y2", true), ("h", true))
    )
    
    let q1-out-y = current-y - 7.0
    let q1-term-ys = ()
    
    for (i, term) in q1-terms.enumerate() {
      let pins = gost-gate(level1-x, current-y, term.len(), inv-out: true)
      q1-term-ys.push(current-y - (calc.max(1.5, term.len() * 0.8) / 2.0))
      for (j, signal) in term.enumerate() {
        route-input(signal.at(0), signal.at(1), level1-x, pins.at(j))
      }
      current-y -= calc.max(2.0, term.len() * 0.8) + 0.5
    }
    
    let q1-out-pins = gost-gate(level1-x + 8.0, q1-out-y, 7, inv-out: true)
    draw.content((level1-x + 12.0, q1-out-y - 2.8), $Q_1$)
    
    for i in range(7) {
      draw.line((level1-x + 3.5, q1-term-ys.at(i)), (level1-x + 5.0 + i*0.3, q1-term-ys.at(i)))
      draw.line((level1-x + 5.0 + i*0.3, q1-term-ys.at(i)), (level1-x + 5.0 + i*0.3, q1-out-pins.at(i)))
      draw.line((level1-x + 5.0 + i*0.3, q1-out-pins.at(i)), (level1-x + 8.0, q1-out-pins.at(i)))
    }

    current-y -= 1.0

    // --- ФУНКЦИЯ Q2 ---
    let q2-terms = (
      (("x1", false), ("x2", false), ("y1", false)),
      (("P1", true),  ("x2", false), ("y2", false)),
      (("P1", true),  ("x2", false), ("h", false)),
      (("x1", true),  ("x2", true),  ("y1", false), ("h", true))
    )
    
    let q2-out-y = current-y - 3.0
    let q2-term-ys = ()
    
    for (i, term) in q2-terms.enumerate() {
      let pins = gost-gate(level1-x, current-y, term.len(), inv-out: true)
      q2-term-ys.push(current-y - (calc.max(1.5, term.len() * 0.8) / 2.0))
      for (j, signal) in term.enumerate() {
        route-input(signal.at(0), signal.at(1), level1-x, pins.at(j))
      }
      current-y -= calc.max(2.0, term.len() * 0.8) + 0.5
    }

    let q2-out-pins = gost-gate(level1-x + 8.0, q2-out-y, 4, inv-out: true)
    draw.content((level1-x + 12.0, q2-out-y - 1.6), $Q_2$)
    
    for i in range(4) {
      draw.line((level1-x + 3.5, q2-term-ys.at(i)), (level1-x + 6.0 + i*0.3, q2-term-ys.at(i)))
      draw.line((level1-x + 6.0 + i*0.3, q2-term-ys.at(i)), (level1-x + 6.0 + i*0.3, q2-out-pins.at(i)))
      draw.line((level1-x + 6.0 + i*0.3, q2-out-pins.at(i)), (level1-x + 8.0, q2-out-pins.at(i)))
    }
  })
]

// === УГЛОВОЙ ШТАМП (ЕСКД) ===
#align(bottom + right)[
  #set text(size: 9pt)
  #table(
    // Точно 10 колонок по ширинам ГОСТ
    columns: (10mm, 10mm, 15mm, 15mm, 15mm, 35mm, 20mm, 15mm, 15mm, 20mm),
    rows: (8mm, 8mm, 8mm, 8mm, 8mm, 8mm),
    stroke: 1pt,
    align: center + horizon,
    
    // Строка 1 (10 колонок)
    table.cell(colspan: 5, [Изм. | Лист | № документа | Подпись | Дата]),
    table.cell(colspan: 5, rowspan: 2, text(size: 14pt, weight: "bold")[ГУИР.6-05-0611-05.528 Э2.2]),
    
    // Строка 2 (10 колонок, правые 5 заняты rowspan)
    table.cell(colspan: 2, [Разраб.]), [Иванов И.И.], [], [],
    
    // Строка 3 (10 колонок)
    table.cell(colspan: 2, [Пров.]), [Петров П.П.], [], [],
    table.cell(colspan: 2, rowspan: 2, text(weight: "bold")[ОЧС. Схема\ электрическая\ функциональная]),
    [Лит.], [Масса], [Масштаб],
    
    // Строка 4 (10 колонок)
    table.cell(colspan: 2, [Т.контр.]), [], [], [],
    [У], [-], [-],
    
    // Строка 5 (10 колонок)
    table.cell(colspan: 2, [Н.контр.]), [], [], [],
    table.cell(colspan: 5, align(left)[ Лист 1 \ Листов 1 ]),
    
    // Строка 6 (10 колонок)
    table.cell(colspan: 2, [Утв.]), [], [], [],
    table.cell(colspan: 5, text(size: 11pt)[ЭВМ, гр. 458305])
  )
]