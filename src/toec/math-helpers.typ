#import "mathtype-mimic.typ": mathtype-mimic


// Безопасное форматирование чисел (заменяет точку на запятую)
#let _fmt(v) = if type(v) in (float, int) { str(v).replace(".", ",") } else { v }

// Расчет параллельного соединения
#let calc-par(name, r1, r2, v1, v2, res, unit: "кОм", receive: false) = {
  mathtype-mimic(receive: receive, [
    $ R_#name = (R_#r1 R_#r2) / (R_#r1 + R_#r2) = (#v1 dot #v2) / (#v1 + #v2) = #res #unit. $
  ])
}

// Расчет последовательного соединения
#let calc-seq(name, rs, vs, res, unit: "кОм", receive: false) = {
  mathtype-mimic(receive: receive, [
    $ R_#name = #rs.map(r => $R_#r$).join($+$) = #vs.join($+$) = #res #unit. $
  ])
}

// Базовое деление (Закон Ома)
#let calc-div(left, top-sym, bot-sym, top-val, bot-val, res, unit: "мА", receive: false) = {
  mathtype-mimic(receive: receive, [
    $ #left = #top-sym / #bot-sym = #top-val / #bot-val = #res #unit. $
  ])
}

// Правило плеч
#let calc-shoulder(left, i-sym, r-top, r-bot, i-val, top-val, bot-val, res, unit: "мА", receive: false) = {
  mathtype-mimic(receive: receive, [
    $ #left = #i-sym #r-top / (#r-bot) = #i-val (#top-val) / (#bot-val) = #res #unit. $
  ])
}


// Хелпер для расчета проводимости (сумма обратных сопротивлений)
// Принимает имя узла (напр. "11"), массив индексов сопротивлений ("1", "2") и их значения как числа
#let calc-g(name, r-indices, r-vals, receive: false) = {
  // Считаем математический результат
  let res-val = r-vals.map(v => 1 / v).sum()

  // Формируем символьную часть: 1/R1 + 1/R2 ...
  let sym-part = r-indices.map(i => $1 / R_#i$).join($+$)

  // Формируем часть с числами: 1/2.4 + 1/2.0 ...
  let num-part = r-vals.map(v => $1 / #_fmt(v)$).join($+$)

  mathtype-mimic(receive: receive, [
    $ g_#name = #sym-part = #num-part = #_fmt(calc.round(res-val, digits: 3)) " См". $
  ])
}

// Хелпер для Закона Ома ветви (с ЭДС и разностью потенциалов)
// I = (phi_start - phi_end + E) / R
#let calc-branch-i(i-idx, phi-s-idx, phi-e-idx, e-idx, r-idx, phi-s-val, phi-e-val, e-val, r-val, receive: false) = {

  // Вычисляем результат в мА
  let res-val = (phi-s-val - phi-e-val + e-val) / r-val

  // Собираем числитель символьно
  let num-sym = ()
  if phi-s-idx != none { num-sym.push($phi_#phi-s-idx$) }
  if phi-e-idx != none { num-sym.push($- phi_#phi-e-idx$) }
  if e-idx != none {
    if e-val > 0 { num-sym.push($+ E_#e-idx$) } else { num-sym.push($- E_#e-idx$) }
  }
  let sym-top = num-sym.join()

  // Собираем числитель с числами
  let num-vals = ()
  if phi-s-idx != none { num-vals.push($#_fmt(calc.round(phi-s-val, digits: 3))$) }
  if phi-e-idx != none { num-vals.push($- #_fmt(calc.round(phi-e-val, digits: 3))$) }
  if e-idx != none {
    if e-val > 0 { num-vals.push($+ #_fmt(e-val)$) } else { num-vals.push($- #_fmt(calc.abs(e-val))$) }
  }
  let val-top = num-vals.join()

  mathtype-mimic(receive: receive, [
    $ I_#i-idx = (#sym-top) / R_#r-idx = (#val-top) / #_fmt(r-val) = #_fmt(calc.round(res-val, digits: 3)) " мА". $
  ])
}

// EXAMPLE
#calc-shoulder($I''_1$, $I''_2$, $R_5$, $R_1 + R_5$, [4,31], [1,5], [1,2 + 1,5], [1,20], receive: true)