#set document(title: "CS 225: Data Structures and Algorithms", author: "Anirudh Konidala")
#set page(paper: "us-letter", margin: 1in, numbering: "1")
#set text(font: "New Computer Modern", size: 11pt)
#set par(justify: true)
#set heading(numbering: "1.1")
#set table(inset: 6pt, stroke: 0.5pt + luma(170))

#show heading: set block(above: 2em, below: 1em)
#show figure: set block(above: 2.5em, below: 2.5em)
#show outline.entry: set block(above: 1em)
#set figure(kind: image, gap: 1em, numbering: n => numbering("1.1", counter(heading).get().first(), n))

#show heading.where(level: 1): it => {
  counter(figure.where(kind: image)).update(0)
  pagebreak(weak: true)
  v(2em)
  text(size: 1.6em, it)
  v(1em)
}
#show raw.where(block: true): block.with(
  width: 100%,
  inset: 10pt,
  radius: 4pt,
  fill: luma(245),
)
#show quote.where(block: true): block.with(
  width: 100%,
  inset: (left: 12pt, y: 6pt),
  stroke: (left: 2pt + blue.lighten(40%)),
)
#show raw.where(block: true): set align(left)
#show raw: set text(font: "DejaVu Sans Mono")
#show raw.where(block: true): set text(size: 9pt)
#show link: set text(fill: blue.darken(20%))
#show figure.caption: it => context [
  *#it.supplement #it.counter.display(it.numbering)#it.separator*#it.body
]
#show ref: it => if it.element != none and it.element.func() == figure { strong(it) } else { it }

#align(center + horizon)[
  #text(size: 2.4em, weight: "bold")[CS 225]
  #v(0.5em)
  #text(size: 1.4em)[Data Structures and Algorithms]
  #v(0.5em)
  #text(size: 1.2em)[Spring 2025]
  #v(2em)
  Anirudh Konidala
]
#pagebreak()
#outline(
  title: [Table of Contents],
  indent: 1.5em,
  target: heading.where(level: 1).or(selector(heading.where(level: 2)).after(<appendix>)),
)

#for n in range(1, 35) {
  include "modules/module-" + if n < 10 { "0" } else { "" } + str(n) + ".typ"
}

#counter(heading).update(0)
#set heading(numbering: (..n) => if n.pos().len() == 1 {
  "Appendix " + numbering("A:", ..n.pos())
} else {
  numbering("A.1", ..n.pos())
})

#set figure(numbering: n => numbering("A.1.1", ..counter(heading).get().slice(0, 2), n))
#show heading.where(level: 2): it => {
  counter(figure.where(kind: image)).update(0)
  it
}

= Midterm Reviews <appendix>

#set heading(offset: 1)

#include "midterm-reviews/midterm-0.typ"
#pagebreak()
#include "midterm-reviews/midterm-1.typ"
