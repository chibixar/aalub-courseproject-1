#import "mathtype-mimic.typ": mathtype-mimic

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

// Безопасное форматирование чисел (заменяет точку на запятую)
#let _fmt(v) = if type(v) in (float, int) { str(v).replace(".", ",") } else { v }

#calc-shoulder($I''_1$, $I''_2$, $R_5$, $R_1 + R_5$, [4,31], [1,5], [1,2 + 1,5], [1,20], receive: true)