#import "@preview/touying:0.6.1": *
#import "@local/shapemaker:0.1.0" : *

/// Utils 
#let theme_color = state("theme-color", luma(0))
#let theme_box = state("theme-box", "old")

#let section_counter = counter("section-counter")
#let subsection_counter = counter("subsection-counter")

#let part(content, angle: 0deg, content_color: black, radius: 1em, stroke: 0.4pt) = {
  box(
    radius: radius,
    fill: white,
    stroke: stroke,
    inset: (x: 0.3em),
    outset: (y: 0.3em),
  )[#text(content_color)[#content]]
}

#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let header(self) = {
    move(dy: 2em)[#(self.colors.bar)(number: self.colors.topamount)]
    move(dx: 2.2em, dy: -2.2em)[
      #part(text(
          font: "Bahnschrift", size: 2em, weight: "regular", " " + 
          utils.call-or-display(self, self.store.header) + " "
        ),
        stroke: 0.2pt,
      )
    ]
  }
  let footer(self) = {
    box(height: 2em)[#move(dy: -0.5em)[
      #align(center)[
        #(self.colors.bar)(number: self.colors.botamount)
      ]
    ]]

    move(dy: -3em)[#pad(x: 2em)[#align(left)[
      #part(self.store.organisation)
      #h(1fr)
      #part(text(
        utils.call-or-display(self, utils.call-or-display(
          self,
          self.store.footer
      ))))
    ]]]
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
      margin : (top: self.colors.topmargin)
    ),
  )
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: setting,
    composer: composer,
    ..bodies,
  )
})


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: pres-shape-theme.with(
///   config-info(
///     title: [Title],
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle], extra: [Extra information])
/// ```
#let title-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(
      margin: (x: 3em, top: 0%, bottom: 0%),
    ),
  )
  
  let info = self.info + args.named()
  let body = {
    stack(
      spacing: 1em,
      box(height : 55%, width : 80%)[
      #align(left + bottom)[#text(font : "Bahnschrift", size: 3em, weight: "bold")[#self.store.title]]
      ],
      box(height: 1em)[#(self.colors.bar)(number: 25)],
      grid(
        columns: int(self.store.authors.len()),
        gutter: 50pt,
        ..self.store.authors.map(
          chunk => block[
            #chunk.first()\
            #move(dy: -10pt)[#text(size: 0.8em)[#chunk.last()]]
          ]
        )
      )
    )
    place(top + right, dx: 1em, dy: 2em)[
      #image(self.store.logo, width: 20%)
    ]
    
    
    
  }
  touying-slide(self: self, body)
})

/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
///
#let focus-slide(config: (:), body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em),
  )
  let body = {
    box[
      #for i in range(10) {
        let k = 1.2 * i
        move(dy: i*-1.2em)[#box(height: 100% / 9)[#(self.colors.bar)(number: 16)]]
        i = i+1
      }
      #place(horizon + center)[
        #text(font: "Bahnschrift", size: 3em, weight: "bold")[#part(" "+body+" ")]
      ]
    ]
  }
  touying-slide(self: self, config: config, body)
})

#let pres-shape-theme(
  aspect-ratio: "16-9",
  header: self => utils.display-current-heading(depth: self.slide-level),
  footer: context utils.slide-counter.display(
    both: true, 
  ),
  ..args,
  body,
) = {
  set text(size: 20pt)

  let info = args.named()
  let colour = rgb(info.colour)
  theme_color.update(colour)
  let color_palette = generate-palette(colour)
  let negative-padding = pad.with(x: -10em, y: 0em)
  let topmargin = 150pt
  let topamount = 9
  let botamount = 22

  let bar = shape_strip.with(
    color_theme: color_palette,
    image_options: (
      height: 100%
    )
  )

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (x: 2em, top: 3.5em, bottom: 2em),
    ),
    config-common(
      slide-fn: slide,
      title-slide-fn: title-slide,
      focus-slide-fn: focus-slide,
    ),
    config-methods(
      init: (self: none, body) => {
        show heading: set text(fill: self.colors.primary)
        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: info.colour,
      bar : bar,
      topamount: topamount,
      botamount: botamount,
      topmargin: topmargin,
    ),
    config-store(
      title : info.title,
      logo : info.logo,
      organisation : info.organisation,
      authors : info.authors,
      header: header,
      footer: footer
    ),
  )

  body
}