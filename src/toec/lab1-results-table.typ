#import "math-helpers.typ": _fmt

#let lab1-results-table(calc-data, exp-data) = {
  figure(
    table(
      columns: (auto, auto, auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
      align: center + horizon,

      // Шапка таблицы
      table.header(
        table.cell(rowspan: 2)[Данные],
        table.cell(colspan: 2)[ЭДС\ Источников],
        table.cell(colspan: 6, align: bottom)[Токи в ветвях],
        [$E_1$, В], [$E_3$, В],
        [$I_1$, мА], [$I_2$, мА], [$I_3$, мА], [$I_4$, мА], [$I_5$, мА], [$I_6$, мА]
      ),

      // Расчетные данные
      table.cell(rowspan: 3, align: center)[Расчетные],
      ..calc-data.flatten().map(_fmt),

      // Экспериментальные данные
      table.cell(rowspan: 3, align: center)[Эксперимен-\ тальные],
      ..exp-data.flatten().map(_fmt)
    )
  )
}

// EXAMPLE
#lab1-results-table(
  (
    (15, 0,  3.03,  0.90,  0.60, 0.31, 4.91,  0.90),
    (0,  30, 1.20,  3.30,  7.93, 1.22, 3.11,  4.31),
    (15, 30, 1.83, -3.40,  7.33, 3.93, 5.23, -3.40)
  ),
  (
    (15, 0,  3.05,  0.95,  0.62, 0.30, 4.95,  0.95), // Ваши экспериментальные данные
    (0,  30, 1.22,  3.35,  7.90, 1.25, 3.15,  4.35),
    (15, 30, 1.85, -3.45,  7.30, 3.90, 5.20, -3.45)
  )
)
