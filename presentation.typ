#import "shapres.typ": *

// Initialize the theme
#show: pres-shape-theme.with(
  title: "My unexpected title which is a bit long...",
  subtitle: "Touying Theme Test",
  organisation: "My University",
  logo : "logo.png",
  authors: (("John Mail", "jonh.mail.the.mail.guy@mail.mail"), 
            ("Bobby Bob Robert Bobby Mailing", "bob@ma.il"),
            ),
  
  // Visuals
  colour: rgb("#85f062cc"),
  docsize: 20pt,
  univlogo: none, 
)

// Generate the title slide
#title-slide()

// Standard Slides
= Section One

== First Slide

#slide[
  This is a regular slide.
  
  - Item 1
  - Item 2
]

== How it works

You are not going to believe this.\
#pause
Basically you write on the slides.\
#pause

And done ggwp.

#focus-slide("Wake Up !!")

= Outro

this slide is the outro...