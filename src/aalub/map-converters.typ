// КОНВЕРТЕР ДЛЯ КАРТ КАРНО/ВЕЙЧА
// Превращает плоскую таблицу в 2D матрицу
#let tt-to-karnaugh(
  encoded-rows,
  in-cols,         // Массив индексов колонок-входов (например: (0, 1, 2, 3))
  out-col,         // Индекс колонки-выхода (например: 5)
  gray-rows: ("00", "01", "11", "10"), // Коды для строк карты
  gray-cols: ("00", "01", "11", "10"), // Коды для столбцов карты
  default-val: "x" // Если набор не найден
) = {
  let grid-data = ()
  for r-code in gray-rows {
    let grid-row = ()
    for c-code in gray-cols {
      let target-combo = r-code.clusters() + c-code.clusters()
      let found-val = default-val

      for row in encoded-rows {
        let current-combo = in-cols.map(idx => str(row.at(idx)))
        if current-combo == target-combo {
          found-val = row.at(out-col)
          break
        }
      }
      grid-row.push(found-val)
    }
    grid-data.push(grid-row)
  }
  return grid-data
}

// КОНВЕРТЕР ДЛЯ КАРТ ВЕЙЧА
// Позволяет произвольно задавать, в каких строках (r) или столбцах (c) переменная равна 1
#let tt-to-veitch(
  encoded-rows,
  in-cols,         // Массив индексов колонок-входов (например: (0, 1, 2))
  out-col,         // Индекс колонки-выхода (например: 5)
  rows: 4,         // Количество строк в карте
  cols: 4,         // Количество столбцов в карте
  vars-map: (),    // Массив правил для каждой переменной из in-cols.
                   // Пример: ( (r: (0, 1)), (c: (1, 2)), (c: (2, 3)) )
  default-val: "x" // Если набор не найден (например, вырезан маской)
) = {
  let grid-data = ()
  for r in range(rows) {
    let grid-row = ()
    for c in range(cols) {

      // 1. Собираем искомую комбинацию (например "1010") для текущей ячейки (r, c)
      let target-combo = ()
      for vmap in vars-map {
        let is-one = false

        // Если переменная привязана к строкам
        if "r" in vmap {
          let r-ones = if type(vmap.r) == array { vmap.r } else { (vmap.r,) }
          if r in r-ones { is-one = true }
        }

        // Если переменная привязана к столбцам
        if "c" in vmap {
          let c-ones = if type(vmap.c) == array { vmap.c } else { (vmap.c,) }
          if c in c-ones { is-one = true }
        }

        target-combo.push(if is-one { "1" } else { "0" })
      }

      // 2. Ищем эту комбинацию в таблице истинности
      let found-val = default-val
      for row in encoded-rows {
        let current-combo = in-cols.map(idx => str(row.at(idx)))
        if current-combo == target-combo {
          found-val = row.at(out-col)
          break
        }
      }
      grid-row.push(found-val)
    }
    grid-data.push(grid-row)
  }
  return grid-data
}