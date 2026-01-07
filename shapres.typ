#import "@preview/touying:0.6.1": *
#import "@local/shapemaker:0.1.0" : *
#import "@preview/showybox:2.0.4": showybox

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


#let custom_box(color) = (
  gauss: (
    title-style: (
      color: color.darken(30%),
      sep-thickness: 0pt,
      align: left,
    ),
    frame: (
      title-color: color.lighten(85%),
      border-color: color,
      thickness: (left: 2pt),
      radius: 0pt,
    ),
  )
)

#let exercise_counter = counter("exercise-counter")
#let question_counter = counter("question-counter")
#let definition_counter = counter("definition-counter")
#let dummy_counter = counter("dummy")

#let joliboite(
  raw_title, unnumbered : false,
  color : rgb("#85f062cc"),
  _counter : dummy_counter ,
  resets : dummy_counter,
  ..body) = context {
  let title = []
  let counter = []

  _counter.step()
  resets.update(1)
  title = if raw_title == "" or raw_title == [] { [] } else { raw_title }
  let stylized_title = if counter == [] or title == [] {[#counter#title]} else {[#counter -- #title]} 

  counter = if unnumbered [] 
  else [#_counter.display()]
      
  let stylized_title = if counter == [] or title == [] {[#counter#title]} else {[#counter -- #title]} 
  let colored_box_theme = custom_box(color)

  showybox(
    ..colored_box_theme.at(theme_box.get(), default: colored_box_theme.gauss),
    breakable: true,
    title: text(9pt, v(-0.3em) + heading(stylized_title, depth: 3) + v(-0.3em)),
    ..body,
  )
}

#let define = joliboite.with(
  color : rgb("#f849499a"),
  _counter: definition_counter
)

#let exo = joliboite.with(
  color : rgb("#46f84f9a"),
  _counter: exercise_counter,
  resets: question_counter
)

#let course-shape-theme(
  ..args,
  body,
) = {

  definition_counter.step()
  exercise_counter.step()
  question_counter.step()

  let info = args.named()
  let colour = rgb(info.colour)
  theme_color.update(colour)
  let color_palette = generate-palette(colour)

  let bar = shape_strip.with(
    color_theme: color_palette,
    image_options: (
      height: 100%
    )
  )

  set page(
    header: context {
      if here().page() > 1 {
        [My Header Content]
      }
    },
    footer: context {
      line(length: 100%)
      grid(
        columns: (1fr, 1fr, 1fr),
        align(left)[#info.organisation],
        align(center)[#counter(page).display()],
        align(right)[#info.author]
      )
    }
  )


  box(height: 20%, width: 100%)[
    #box(height: 3em)[#bar(number:14)]
    #align(horizon+center)[
      #text(size : 20pt, font : "Bahnschrift")[#info.title]
    ]
    #box(height: 3em)[#bar(number:14)]
  ]
  
  v(2em)
  
  

  body
}