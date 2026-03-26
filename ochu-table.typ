#import "dependencies.typ": *

#let ochu-table(body) = [

    = Таблица истинности ОЧУ

    Разряды множимого закодированы: #encoding-as-text(code-custom)

    Разряды множителя закодированы: #encoding-as-text(code-standart)


    // ОПРЕДЕЛЯЕМ ПРАВИЛО МАСКИ
    // Для ОЧУ: максимальная цифра множителя - двойка.
    // Значит логическая тройка на вход Mт не поступит.
    #let ochu-mask = (mh, mt, h) => (mt == 3)
//     #let ochu-mask = (mh, mt, h) => false // for test

    // Генерируем сырые данные (в десятеричном виде)
    #let raw-ochu = generate-base-ochu(mask-fn: ochu-mask)

    // СХЕМА ЭНКОДЕРА:
    // mh -> code-custom (раскладывается на 2 бита: x1, x2)
    // mt -> code-standart (раскладывается на 2 бита: y1, y2)
    // h  -> none        (остается 1 бит: h)
    // p_high -> code-custom (раскладывается на 2 бита: P1, P2)
    // p_low  -> code-custom (раскладывается на 2 бита: P3, P4)
    // comment -> none   (строка)
    #let schema-ochu = (code-custom, code-standart, none, code-custom, code-custom, none)
    #let encoded-ochu = encode-tt(raw-ochu, schema-ochu)

    // Сортируем: x1 (0), x2 (1), y1 (2), y2 (3), h (4)
    #let encoded-ochu = sort-tt(encoded-ochu, sort-cols: (0, 1, 2, 3, 4))

    // Отрисовываем таблицу истинности
    #draw-truth-table(
        // Настраиваем жирные линии (0 - левый край, 2 - после x2, 4 - после y2 и т.д.)
        bold-vlines: (0, 2, 4, 5, 7, 9, -1),
        bold-hlines: (0, 2, -1),

        column-widths: (1.5em, 1.5em, 1.5em, 1.5em, 2.5em, 3em, 3em, 3em, 3em, auto),

        header_rows: 2,
        headers: (
            table.cell(colspan: 2)[*Мн*],
            table.cell(colspan: 2)[*Мт*],
            table.cell[*Упр.*],
            table.cell(colspan: 2)[*Старшие\ разряды*],
            table.cell(colspan: 2)[*Младшие\ разряды*],
            table.cell(rowspan: 2)[*Пример операции в четверичной с/с*],
            strong($x_1$), strong($x_2$),
            strong($y_1$), strong($y_2$),
            strong($h$),
            strong($P_1$), strong($P_2$),
            strong($P_3$), strong($P_4$),
        ),

        rows: encoded-ochu
    )

    // ОПРЕДЕЛЯЕМ ПРАВИЛА ОДИН РАЗ ДЛЯ ВСЕХ ЧЕТЫРЕХ КАРТ
    // 1. Где переменные равны единице (для конвертера)
    #let ochu-vars-map = (
        (r: (2, 3)),             // x1
        (r: (1, 2)),             // x2
        (c: (4, 5, 6, 7)),       // y1
        (c: (2, 3, 4, 5)),       // y2
        (c: (1, 2, 5, 6))        // h
    )

    // 2. Как рисовать линии (для отрисовщика)
    #let ochu-vars-lines = (
        (side: "left",   start: 2, span: 2, label: $x_1$),
        (side: "right",  start: 1, span: 2, label: $x_2$),
        (side: "top",    start: 4, span: 4, label: $y_1$),
        (side: "bottom", start: 2, span: 4, label: $y_2$),
        // h разорван на две части, поэтому рисуем две линии снизу с бОльшим отступом
        (side: "bottom", start: 1, span: 2, label: $h$, offset: 2.8em),
        (side: "bottom", start: 5, span: 2, label: $h$, offset: 2.8em),
    )

    // P1 ==========================================
    #let map-p1 = tt-to-veitch(
        encoded-ochu,
        (0, 1, 2, 3, 4),
        5, // Колонка P1
        rows: 4, cols: 8,
        vars-map: ochu-vars-map,
        default-val: "Z",
    )

    #align(center)[
        #let groups = (
            (r: 1, c: 7, w: 1, h: 1, pad: 2pt, color: black),
            (r: 3, c: 7, w: 1, h: 1, pad: 2pt, color: black),
        )

        #veitch-map(
            cell-size: 2.2em,
            hide: "1",
            grid-data: map-p1,
            vars: ochu-vars-lines,
            groups: groups
        )

        #h(10em)

        $ P_1 = #get-mcnf(
            groups,
            ochu-vars-map,
            ($x_1$, $x_2$, $y_1$, $y_2$, $h$),
            rows: 4, cols: 8
        ) $
    ]

    // P2 ==========================================
    #let map-p2 = tt-to-veitch(
        encoded-ochu,
        (0, 1, 2, 3, 4),
        6, // Колонка P2
        rows: 4, cols: 8,
        vars-map: ochu-vars-map,
        default-val: "Z",
    )

    #align(center)[
        #let groups = (
            (r: 1, c: 7, w: 1, h: 1, pad: 2pt, color: black),
            (r: 3, c: 7, w: 1, h: 1, pad: 2pt, color: black),
        )

        #veitch-map(
            cell-size: 2.2em,
            hide: "1",
            grid-data: map-p2,
            vars: ochu-vars-lines,
            groups: groups
        )

        #h(10em)

        $ P_2 = #get-mcnf(
            groups,
            ochu-vars-map,
            ($x_1$, $x_2$, $y_1$, $y_2$, $h$),
            rows: 4, cols: 8
        ) $
    ]

    // P3 ==========================================
    #let map-p3 = tt-to-veitch(
        encoded-ochu,
        (0, 1, 2, 3, 4),
        7, // Колонка P3
        rows: 4, cols: 8,
        vars-map: ochu-vars-map,
        default-val: "Z",
    )

    #align(center)[
        #let groups = (
            (r: 0, c: 7, w: 2, h: 4, pad: 6pt, color: black),
            (r: 2, c: 0, w: 8, h: 2, pad: 3pt, color: black),
        )

        #veitch-map(
            cell-size: 2.2em,
            hide: "0",
            grid-data: map-p3,
            vars: ochu-vars-lines,
            groups: groups
        )

        #h(10em)

        $ P_3 = #get-mdnf(
            groups,
            ochu-vars-map,
            ($x_1$, $x_2$, $y_1$, $y_2$, $h$),
            rows: 4, cols: 8
        ) $
    ]

    // P4 ==========================================
    #let map-p4 = tt-to-veitch(
        encoded-ochu,
        (0, 1, 2, 3, 4),
        8, // Колонка P4
        rows: 4, cols: 8,
        vars-map: ochu-vars-map,
        default-val: "Z",
    )

    #align(center)[
        #let groups = (
            (r: 0, c: 3, w: 2, h: 4, pad: 4pt, color: black),
            (r: 1, c: 0, w: 4, h: 2, pad: 4pt, color: black),
            (r: 1, c: 5, w: 2, h: 2, pad: 4pt, color: black),
            (r: 2, c: 7, w: 2, h: 2, pad: 4pt, color: black),
            (r: 0, c: 0, w: 1, h: 4, pad: 6pt, color: black, dash: "dashed"),
        )

        #veitch-map(
            cell-size: 2.2em,
            hide: "0",
            grid-data: map-p4,
            vars: ochu-vars-lines,
            groups: groups
        )

        #h(10em)

        $ P_4 = #get-mdnf(
            groups,
            ochu-vars-map,
            ($x_1$, $x_2$, $y_1$, $y_2$, $h$),
            rows: 4, cols: 8
        ) $
    ]

    #body
]

#show: ochu-table