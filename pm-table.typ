#import "dependencies.typ": *

#let pm-table(body) = [
    = Таблица истинности ПМ

    // 1. ОПРЕДЕЛЯЕМ ВАШУ КАСТОМНУЮ КОДИРОВКУ
    #let code-pm-custom = (
        "0": "10",
        "1": "00",
        "2": "01",
        "3": "11",
    )

    Входные разряды множителя закодированы: #encoding-as-text(code-pm-custom)

    Выходные разряды закодированы: #encoding-as-text(code-standart)

    // Генератор сырых данных для ПМ
    #let raw-pm = {
        let res = ()
        for input in (0, 1, 2, 3) {
            for p_in in (0, 1) {
                let transformed = if input >= 2 { input - 4 } else { input }
                let p_out = if input >= 2 { 1 } else { 0 }

                let out = transformed + p_in
                let sign = if out < 0 { 1 } else { 0 }
                let out = calc.abs(out)

                res.push((
                    str(input), str(p_in), str(p_out), str(sign), str(out),
                    str(input) + " + " + str(p_in)
                        + " -> " + if sign == 1 {"-"} else {""} + str(out) + " | " + str(p_out)
                ))
            }
        }
        res
    }

    // 2. МЕНЯЕМ СХЕМУ (первый столбец теперь code-pm-custom)
    #let schema-pm = (code-pm-custom, none, none, none, code-standart, none)
    #let encoded-pm = encode-tt(raw-pm, schema-pm)

    #draw-truth-table(
        bold-vlines: (0, 3, 7, -1),
        bold-hlines: (0, 2, -1),
        header_rows: 2,
        headers: (
            table.cell(colspan: 2)[*Мт*],
            table.cell[*Перенос\ пред.*],
            table.cell[*Перенос\ след.*],
            table.cell[*Знак*],
            table.cell(colspan: 2)[*$"[Мт]"_п$*],
            table.cell(rowspan: 2)[*Комментарий*],
            strong($v_1$), strong($v_2$),
            table.cell[*$П_(i-1)$*],
            table.cell[*$П_i$*],
            table.cell[*$S$*],
            strong($P_1$), strong($P_2$),
        ),
        rows: encoded-pm
    )

    // ОПРЕДЕЛЯЕМ ПРАВИЛА (для конвертера mdnf/mcnf)
    // Карта 2x4. Переменные: v1 v2 (cols), c_in (rows)
    // Правила остаются прежними, так как структура карты неизменна (оси Карно те же)
    #let pm-vars-map = (
        (c: (2, 3)),       // v1 (колонки 11 и 10)
        (c: (1, 2)),       // v2 (колонки 01 и 11)
        (r: (1,)),         // c_in (нижняя строка)
    )

    #let vars-labels = ($v_1$, $v_2 П_(i-1)$)

    // C_out ==========================================
    #draw-map-block(
        encoded-pm, (0, 1, 2), 3,
        gray-code(2), gray-code(1), vars-labels,
        pm-vars-map, ($v_1$, $v_2$, $П_(i-1)$),
        (
            // Новая группа охватывает ровно столбцы "01" (2) и "11" (3)
            (r: 0, c: 1, w: 2, h: 2, pad: 4pt, color: black),
        ),
        $П_i$
    )

    // Знак ==================================
    #draw-map-block(
        encoded-pm, (0, 1, 2), 4,
        gray-code(2), gray-code(1), vars-labels,
        pm-vars-map, ($v_1$, $v_2$, $П_(i-1)$),
        (
            (r: 0, c: 1, w: 1, h: 2, pad: 4pt, color: black),
            (r: 0, c: 1, w: 2, h: 1, pad: 6pt, color: black, dash: "dashed"),
        ),
        $S$
    )

    // P1 =============================================
    #draw-map-block(
        encoded-pm, (0, 1, 2), 5,
        gray-code(2), gray-code(1), vars-labels,
        pm-vars-map, ($v_1$, $v_2$, $П_(i-1)$),
        (
            // Изолированные единицы для P1 при новой кодировке
            (r: 1, c: 0, w: 1, h: 1, pad: 4pt, color: black),
            (r: 0, c: 1, w: 1, h: 1, pad: 4pt, color: black),
        ),
        $P_1$
    )

    // P2 =============================================
    #draw-map-block(
        encoded-pm, (0, 1, 2), 6,
        gray-code(2), gray-code(1), vars-labels,
        pm-vars-map, ($v_1$, $v_2$, $П_(i-1)$),
        (
            // Идеальная "шахматка" единиц
            (r: 0, c: 0, w: 1, h: 1, pad: 4pt, color: black),
            (r: 0, c: 2, w: 1, h: 1, pad: 4pt, color: black),
            (r: 1, c: 1, w: 1, h: 1, pad: 4pt, color: black),
            (r: 1, c: 3, w: 1, h: 1, pad: 4pt, color: black),
        ),
        $P_2$
    )

    #body
]

#show: pm-table