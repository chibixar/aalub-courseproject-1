#import "@local/typst-bsuir-core:0.9.0": *

// --- 1. ОПРЕДЕЛЯЕМ КОДИРОВКИ ---
// Стандартная весомозначная кодировка (вариант 1)
#let code-standart = (
  "0": "00",
  "1": "01",
  "2": "10",
  "3": "11"
)

// Какая-нибудь хитрая кодировка по вашему варианту (вариант 2)
#let code-custom = (
  "0": "11",
  "1": "00",
  "2": "10",
  "3": "01"
)

// --- 2. ЗАДАЕМ CSV ---
// Это абстрактная логика: Мн (Множимое), Мт (Множитель), Упр (h), Результат умножения, Коммент
#let csv-ochu = ```csv
Мн, Мт, Упр, Рез, Коммент
0, 0, 0, 0, 0*0=00
0, 0, 1, 0, Выход Мн
0, 1, 0, 0, 0*1=00
0, 1, 1, 0, Выход Мн
2, 3, 0, x, 2*3 (не бывает)
x, 3, 1, x, Безразл.
1, 2, 0, 2, 1*2=02
```

// --- 3. СОЗДАЕМ СХЕМУ ДЕКОДИРОВАНИЯ ---
// Мы говорим скрипту:
// 1 колонка -> разбей по code-standart
// 2 колонка -> разбей по code-custom (допустим, множитель закодирован иначе)
// 3 колонка -> не трогай (управляющий сигнал h - это 1 бит)
// 4 колонка -> разбей по code-standart
// 5 колонка -> не трогай (текст)
#let schema = (code-standart, code-custom, none, code-standart, none)

// Загружаем и кодируем данные!
#let encoded-data = load-csv-tt(csv-ochu.text, schema)


// --- 4. ОТРИСОВКА ---
= Таблица истинности ОЧУ
(Мн: станд., Мт: кастом.)

#draw-truth-table(
    bold-vlines: (2, 4, 5, 7),
    bold-hlines: (2,), // Жирная линия после второй строки шапки
    headers: (
        table.cell(colspan: 2)[Мн],
        table.cell(colspan: 2)[Мт],
        table.cell[Упр],
        table.cell(colspan: 2)[Выход],
        table.cell(rowspan: 2)[Комментарий],

        // Подзаголовок для битов
        $x_1$, $x_2$, $y_1$, $y_2$, $h$, $P_3$, $P_4$
    ),
    rows: encoded-data
)

// --- 5. ПОДГОТОВКА К КАРТЕ ВЕЙЧА ---
// Допустим, мы хотим получить матрицу для минимизации функции P_3.
// В encoded-data:
// Индексы входов: x1(0), x2(1), y1(2), y2(3), h(4)
#let kmap-grid-p3 = tt-to-map-grid(
    gray-cols: gray-code(3),
    gray-rows: gray-code(2),
  encoded-data,
  (0, 1, 2, 3, 4), // Берем биты x1, x2, y1, y2, h
  5                // P_3 находится в колонке с индексом 5 (6-я по счету)
)

#align(center)[
  #karnaugh-map(
    x-labels: gray-code(3),
    y-labels: gray-code(2),
    hide: 0,
    vars-label: ($x_1 x_2$, $y_1 y_2 h$),

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