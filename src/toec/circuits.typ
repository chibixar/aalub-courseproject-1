#import "@preview/zap:0.5.0"

// Helper: Maps physical direction ("top", "left"...) to Zap's local anchors ("north"...)
#let phys-to-anchor(angle, physical) = {
    if physical not in ("top", "bottom", "left", "right", "north", "south", "east", "west", "up", "down") {
        return physical
    }
    let sin-a = calc.sin(angle)
    let cos-a = calc.cos(angle)
    let (dx, dy) = if physical in ("top", "north", "up") { (0, 1) }
              else if physical in ("bottom", "south", "down") { (0, -1) }
              else if physical in ("right", "east") { (1, 0) }
              else { (-1, 0) }

    // Rotate physical vector backward to find local coordinate match
    let lx = dx * cos-a + dy * sin-a
    let ly = -dx * sin-a + dy * cos-a

    if calc.abs(ly) >= calc.abs(lx) {
        if ly >= 0 { "north" } else { "south" }
    } else {
        if lx >= 0 { "east" } else { "west" }
    }
}

// Helper: Determines if physical direction corresponds to local +Y (1) or -Y (-1)
#let phys-to-y(angle, physical) = {
    if physical == "wire-left" { return 1 }
    if physical == "wire-right" { return -1 }
    if physical not in ("top", "bottom", "left", "right", "north", "south", "east", "west", "up", "down") { return 1 }
    let sin-a = calc.sin(angle)
    let cos-a = calc.cos(angle)
    let (dx, dy) = if physical in ("top", "north", "up") { (0, 1) }
              else if physical in ("bottom", "south", "down") { (0, -1) }
              else if physical in ("right", "east") { (1, 0) }
              else { (-1, 0) }

    let ly = -dx * sin-a + dy * cos-a
    if ly >= 0 { 1 } else { -1 }
}

// Helper: Determines if physical direction corresponds to local +X (forward) or -X (backward)
#let phys-to-x(angle, physical) = {
    if physical == "forward" { return 1 }
    if physical == "backward" { return -1 }
    if physical not in ("top", "bottom", "left", "right", "north", "south", "east", "west", "up", "down") { return 1 }
    let sin-a = calc.sin(angle)
    let cos-a = calc.cos(angle)
    let (dx, dy) = if physical in ("top", "north", "up") { (0, 1) }
              else if physical in ("bottom", "south", "down") { (0, -1) }
              else if physical in ("right", "east") { (1, 0) }
              else { (-1, 0) }

    let lx = dx * cos-a + dy * sin-a
    if lx >= 0 { 1 } else { -1 }
}

#let source-better(name, ..params) = {
    import zap: cetz, component
    let pos = params.pos()

    cetz.draw.get-ctx(ctx => {
        let angle = 0deg
        if pos.len() == 2 {
            let (ctx, rp1) = cetz.coordinate.resolve(ctx, pos.at(0))
            let (ctx, rp2) = cetz.coordinate.resolve(ctx, pos.at(1))
            angle = cetz.vector.angle2(rp1, rp2)
        }

        let named = params.named()

        let lbl = named.at("label", default: none)
        if type(lbl) == dictionary and "anchor" in lbl {
            lbl.anchor = phys-to-anchor(angle, lbl.anchor)
            named.label = lbl
        }

        let arrow-dir = phys-to-x(angle, named.at("arrow-dir", default: "forward"))
        let _ = named.remove("arrow-dir", default: none)

        let draw(ctx, position, style) = {
            import zap: interface, cetz
            let r = style.at("radius", default: 0.53)
            interface((-r, -r), (r, r), io: position.len() < 2)
            cetz.draw.circle((0, 0), radius: r, fill: style.fill, stroke: style.stroke)

            let arrow-len = r * 0.65
            let start-x = -arrow-dir * arrow-len
            let end-x = arrow-dir * arrow-len
            cetz.draw.line((start-x, 0), (end-x, 0), stroke: style.stroke, mark: (end: ">", fill: style.stroke.paint, scale: 1.2))
        }

        component("isource", name, ..pos, draw: draw, ..named)
    })
}

#let resistor-better(name, ..params) = {
    import zap: cetz, component
    let pos = params.pos()

    cetz.draw.get-ctx(ctx => {
        let angle = 0deg
        if pos.len() == 2 {
            let (ctx, rp1) = cetz.coordinate.resolve(ctx, pos.at(0))
            let (ctx, rp2) = cetz.coordinate.resolve(ctx, pos.at(1))
            angle = cetz.vector.angle2(rp1, rp2)
        }

        let named = params.named()

        let lbl = named.at("label", default: none)
        if type(lbl) == dictionary and "anchor" in lbl {
            lbl.anchor = phys-to-anchor(angle, lbl.anchor)
            named.label = lbl
        }

        let arrow-side = phys-to-y(angle, named.at("arrow-side", default: "top"))
        let arrow-dir = phys-to-x(angle, named.at("arrow-dir", default: "right"))
        let arrow-label = named.at("arrow-label", default: none)
        let arrow-offset = named.at("arrow-offset", default: 0.5)

        let _ = named.remove("arrow-side", default: none)
        let _ = named.remove("arrow-dir", default: none)
        let _ = named.remove("arrow-label", default: none)
        let _ = named.remove("arrow-offset", default: none)

        let draw(ctx, position, style) = {
            import zap: interface, cetz
            let w = style.at("width", default: 1.41)
            let h = style.at("height", default: 0.47)

            interface((-w/2, -h/2), (w/2, h/2), io: position.len() < 2)
            cetz.draw.rect((-w/2, -h/2), (w/2, h/2), fill: style.fill, stroke: style.stroke)

            if arrow-label != none {
                let y = arrow-side * arrow-offset
                let arrow-len = w * 0.8
                let start-x = -arrow-dir * (arrow-len / 2)
                let end-x = arrow-dir * (arrow-len / 2)

                cetz.draw.line(
                    (start-x, y), (end-x, y),
                    stroke: style.stroke,
                    mark: (end: ">", fill: style.stroke.paint)
                )

                let label_offset = arrow-side * 0.5
                cetz.draw.content(
                    (0, y + label_offset),
                    box(fill: white, inset: 1pt)[#arrow-label],
                    anchor: "center",
//                     angle: -angle // Counter-rotates text so it is always upright
                )
            }
        }

        component("resistor", name, ..pos, draw: draw, ..named)
    })
}

// Wrapper function for customized Zap circuits
#let circuit-better(
    scale-factor: 100%,
    alignment: center,
    text-font: "Times New Roman",
    math-font: "STIX Two Math",
    text-size: 14pt,
    stroke-thickness: 1.2pt,
    resistor-width: 1.6,
    resistor-height: 0.5,
    ..zap-args,
    body
) = {
    let reversed-factor = 100% / scale-factor
    align(alignment, block(
        scale(scale-factor)[
            // Apply text and math font settings
            #set text(font: text-font, size: text-size * reversed-factor)
            #show math.equation: set text(font: math-font, size: text-size * reversed-factor)

            // Initialize the Zap circuit
            #zap.circuit(..zap-args, {
                // Apply default styles
                zap.set-style(stroke: (thickness: stroke-thickness * reversed-factor))
                zap.set-style(wire: (stroke: (thickness: stroke-thickness * reversed-factor)))
                zap.set-style(resistor: (width: resistor-width, height: resistor-height))

                // Insert the user's circuit components
                body
            })
        ]
    ))
}

#let node-better(name, pos, visible: false, radius: 0.12, fill: black, ..params) = {
    import zap: cetz, node

    let named = params.named()

    // 1. Обрабатываем якоря (top, bottom, left, right)
    let lbl = named.at("label", default: none)
    if type(lbl) == dictionary and "anchor" in lbl {
        lbl.anchor = phys-to-anchor(0deg, lbl.anchor)
        named.label = lbl
    }

    // 2. Вызываем стандартный узел zap, но ЖЕСТКО делаем его невидимым
    node(name, pos, stroke: none, fill: false, radius: 0.0000001, ..named)

    // 3. Если узел должен быть видимым — рисуем поверх него свой кружок
    // с нужным нам радиусом и цветом
    if visible {
        cetz.draw.circle(name, radius: radius, fill: fill, stroke: none)
    }
}

// EXAMPLE
#circuit-better(scale-factor: 80%, {
    import zap: *

//     set-style(stroke: (thickness: 1.2pt))
//     set-style(wire: (stroke: (thickness: 1.2pt)))
//     set-style(resistor: (width: 1.6, height: 0.5))

    node-better("e", (0, 3.5), label: (content: "e", anchor: "west"), visible: true)
    node-better("a", (5, 7), label: (content: "a", anchor: "north"), visible: true)
    node-better("б", (11, 7), label: (content: "б", anchor: "north"), visible: true)
    node-better("в", (16, 3.5), label: (content: "в", anchor: "east"), visible: true)
    node-better("д", (5, 0), label: (content: "д", anchor: "south"), visible: true)
    node-better("г", (11, 0), label: (content: "г", anchor: "south"), visible: true)

    // Notice how intuitive this becomes: you just ask for the physical "left", "right", "top", "bottom"
    // Left Branch (UP):
    wire("д", (0,0))
    source-better("E1", (0,0), "e", arrow-dir: "up", label: (content: $E_1$, anchor: "left"))
    resistor-better("R1", "e", (0,7), label: (content: $R_1$, anchor: "right"), arrow-label: $I_1$, arrow-side: "left", arrow-dir: "up")
    wire((0,7), "a")

    // Top Branch (RIGHT):
    resistor-better("R2", "a", "б", label: (content: $R_2$, anchor: "top"), arrow-label: $I_2$, arrow-side: "bottom", arrow-dir: "right")

    // Middle Branches (DOWN):
    resistor-better("R5", "a", "д", label: (content: $R_5$, anchor: "left"), arrow-label: $I_5$, arrow-side: "right", arrow-dir: "down")
    resistor-better("R4", "б", "г", label: (content: $R_4$, anchor: "right"), arrow-label: $I_4$, arrow-side: "left", arrow-dir: "down")

    // Right Branch (UP):
    wire("г", (16,0))
    source-better("E3", (16,0), "в", arrow-dir: "up", label: (content: $E_3$, anchor: "right"))
    resistor-better("R3", "в", (16,7), label: (content: $R_3$, anchor: "left"), arrow-label: $I_3$, arrow-side: "right", arrow-dir: "up")
    wire((16,7), "б")

    // Bottom Branch (LEFT, from г to д):
    resistor-better("R6", "г", "д", label: (content: $R_6$, anchor: "bottom"), arrow-label: $I_6$, arrow-side: "top", arrow-dir: "left")
})
