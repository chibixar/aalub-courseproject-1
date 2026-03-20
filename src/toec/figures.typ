#let lab-figure(
  caption: none, // По умолчанию caption отсутствует
  above: -2em,   // По умолчанию отрицательный отступ сверху -2em
  gap: -1em,
  body
) = {
  let final-caption = if caption != none {
    caption
  } else {
    // Если caption не задан, используем трюк для пустого caption
    figure.caption(separator: none, [])
  }

  text("")

  align(center, block(
    above: above,
    figure(
      caption: final-caption,
      gap: gap,
      body,
    )
  ))
}