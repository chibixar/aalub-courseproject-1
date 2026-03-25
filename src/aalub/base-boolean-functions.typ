// ГЕНЕРАТОР БАЗОВОЙ ОЧС (Математика)
// Генерирует массив: (a, b, p, Pi, S, "комментарий")
#let generate-base-ochs(mask-fn: none) = {
  let rows = ()

  for a in (0, 1, 2, 3) {
    for b in (0, 1, 2, 3) {
      for p in (0, 1) {
        let sum = a + b + p
        let Pi = calc.quo(sum, 4) // Перенос
        let S = calc.rem(sum, 4)  // Сумма

        let comment = str(a) + "+" + str(b) + "+" + str(p) + "=" + str(Pi) + str(S)

        let Pi-str = str(Pi)
        let S-str = str(S)

        // МАГИЯ ЗДЕСЬ: Если передана функция маски, вызываем её.
        // Передаем ей текущие a, b, p. Если она возвращает true — ставим крестики!
        if mask-fn != none and mask-fn(a, b, p) {
          Pi-str = "x"
          S-str = "x"
        }

        rows.push((str(a), str(b), str(p), Pi-str, S-str, comment))
      }
    }
  }
  return rows
}

// ГЕНЕРАТОР БАЗОВЫХ СТРОК ДЛЯ ОЧУ
// Генерирует массив: (mh, mt, h, P_high, P_low, "комментарий")
#let generate-base-ochu(mask-fn: none) = {
  let rows = ()
  for mh in (0, 1, 2, 3) {
    for mt in (0, 1, 2, 3) {
      for h in (0, 1) {

        // Логика ОЧУ: умножение, либо пропуск множимого
        let result = if h == 0 { mh * mt } else { mh }

        let p_high = calc.quo(result, 4) // Старшая цифра (P1, P2)
        let p_low = calc.rem(result, 4)  // Младшая цифра (P3, P4)

        let p_high_str = str(p_high)
        let p_low_str = str(p_low)

        // Комментарий (повторяет таблицу 2.3 из методички)
        let comment = if h == 0 {
          str(mh) + "·" + str(mt) + "=" + str(p_high) + str(p_low)
        } else {
          "Выход – код «" + str(p_high) + str(p_low) + "»"
        }

        // Применяем маску (заменяем на 'x', если набор запрещенный)
        if mask-fn != none and mask-fn(mh, mt, h) {
          p_high_str = "x"
          p_low_str = "x"
        }

        rows.push((str(mh), str(mt), str(h), p_high_str, p_low_str, comment))
      }
    }
  }
  return rows
}