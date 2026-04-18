#import "dependencies.typ": *

#let ochus-table(body) = [

    = Таблица истинности ОЧУС

    #let code-ochus-custom = (
        "0": "01",
        "1": "11",
        "2": "10",
        "3": "00",
    )
    
    #let code-standart = (
        "0": "00",
        "1": "01",
        "2": "10",
        "3": "11",
    )

    Разряды множимого и результата закодированы: #encoding-as-text(code-ochus-custom)

    Разряды множителя закодированы: #encoding-as-text(code-standart)

    // МАСКА НА 36 БЕЗРАЗЛИЧНЫХ НАБОРОВ
    #let ochus-mask = (p1_in, mh, mt, h) => {
        if mt == 3 { return true }
        if h == 0 and (mt == 0 or mt == 1) and p1_in == 1 { return true }
        if h == 1 and p1_in == 1 { return true }
        return false
    }

    // 1. Используем генератор из нашей библиотеки
    #let raw-ochus = generate-base-ochus(mask-fn: ochus-mask)

    // 2. Кодируем в биты
    #let schema-ochus = (none, code-ochus-custom, code-standart, none, none, code-ochus-custom, none)
    #let encoded-ochus = encode-tt(raw-ochus, schema-ochus)

    // 3. Сортируем
    #let sorted-ochus = sort-tt(encoded-ochus, sort-cols: (0, 1, 2, 3, 4, 5))

    // 4. Подсвечиваем "x" серым
    #let colored-ochus = sorted-ochus.map(row => {
        if row.at(6) == "x" or row.at(6) == "х" {
            row.map(cell => table.cell(fill: luma(230))[#cell])
        } else { row }
    })

    // 5. Рисуем таблицу
    // 5. Рисуем таблицу
    #draw-truth-table(
        bold-vlines: (0, 1, 3, 5, 6, 7, 9, -1), 
        bold-hlines: (0, 2, 3, -1),

        // ИСПОЛЬЗУЕМ AUTO: 9 колонок подстроятся под текст, а последняя займет остаток места (1fr)
        column-widths: (auto, auto, auto, auto, auto, auto, auto, auto, auto, 1fr),

        header_rows: 2,
        show-numbers: true, 
        headers: (
            table.cell[*Пер.*],
            table.cell(colspan: 2)[*Мн*],
            table.cell(colspan: 2)[*Мт*],
            table.cell[*Упр.*],
            table.cell[*Перенос*],
            table.cell(colspan: 2)[*Результат*],
            table.cell(rowspan: 2, align: center + horizon)[*Результат операции\ в четверичной с/с*],

            strong($P_1$),
            strong($x_1$), strong($x_2$),
            strong($y_1$), strong($y_2$),
            strong($h$),
            strong($P$),
            strong($Q_1$), strong($Q_2$),
        ),
        rows: colored-ochus
    )

    #body
]