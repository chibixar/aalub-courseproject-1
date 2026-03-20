#let apply-toec-styling(body) = {
    set math.equation(numbering: none)
    set heading(numbering: "1.1.")

    // --- SMART NUMBER FORMATTER ---
    let format-value(it) = {
      // 1. Convert comma to dot for Typst math
      let text = it.text.replace(",", ".")
      let val = float(text)

      // 2. Round to exactly 2 decimal places
      let rounded = calc.round(val, digits: 2)

      // 3. Convert back to string and replace dot with GOST comma
      let str-val = str(rounded).replace(".", ",")

      // 4. Add padding zeros if necessary
      let parts = str-val.split(",")
      if parts.len() == 1 {
        str-val + ",00"
      } else if parts.at(1).len() == 1 {
        str-val + "0"
      } else {
        str-val
      }
    }

    // Ищет числа, где есть точка или запятая и хотя бы 1 цифра после нее
    // Это защищает индексы (I_1) от превращения в I_1,00
    let num-regex = regex("[0-9]+[\.,][0-9]+")

    // Применяем авто-форматирование к формулам
    show math.equation: eq => {
      show num-regex: format-value
      eq
    }

    // Применяем авто-форматирование к таблицам
    show table.cell: cell => {
      show num-regex: format-value
      cell
    }

    show figure.caption: cap => context {
      // Уменьшаем размер шрифта подписей до 12pt
      set text(size: 12pt)

      // Берем счетчик и делаем цифру курсивом (через emph)
      let num = none
      if cap.numbering != none {
        num = emph(cap.counter.display(cap.numbering))
      }

      // Собираем текст: "Рисунок *1* — Название"
      let content = [#cap.supplement #num#cap.separator#cap.body]

      // Возвращаем правильное выравнивание
      // По ГОСТу подпись таблицы слева, рисунка - по центру
      if cap.kind == table {
        align(left)[#content]
      } else {
        align(center)[#content]
      }
    }

    body
}