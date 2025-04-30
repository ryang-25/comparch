#import "@preview/great-theorems:0.1.2": *
#import "@preview/headcount:0.1.0": *

#let notes(
  title: none,
  subject: none,
  author: (),
  date: datetime.today(),
  footer: true,
  doc
) = {
  set document(
    title: title + [: ] + subject,
    author: author
  )
  set page(
    paper: "us-letter",
    header: [
      #set block(spacing: 0.5em)
      #title #h(1fr) #text(style: "italic", subject)
      #line(length: 100%, stroke: gray)
    ],
    footer: context {
      if footer {
        align(center, counter(page).display("1⧸1", both:true))
      }
    },
  )
  set text(size: 12pt)
  // set heading(numbering: "1.")
  set heading(numbering: (..nums) => {
    let nums = nums.pos().map(str)
    if nums.len() == 1 {
      nums.join(".") + "."
    } else  {
      sym.section + nums.join(".")
    }
  })

  // Set common enum numbering and add some spacing.
  set enum(numbering: "a.", indent: 1em)
  set list(indent: 1em)

  // Create our front matter.
  align(right,
    block(
      stroke: (left: 1pt + gray),
      inset: (left: 0.75em, right: 1.5em, top: 1.25em, bottom: 2em),
      {
        set align(left)
        set text(size: 13pt)
        text(size: 28pt, weight: "bold", title)
        v(-0.5em)
        date.display("[day] [month repr:long] [year]")
        linebreak()
        author
      })
  )
  doc
}

#let tcounter = counter("tcounter")
#let problem = mathblock(
  blocktitle: "Problem",
  inset: (x: 0.5em, y: 0.75em),
  stroke: gray,
  counter: tcounter,
  breakable: false
)
#let solution = proofblock(
  blocktitle: "Solution",
  prefix: [_Solution._],
  suffix: []
)

#let blockquote(body) = {
  pad(left: 1em,
    block(
      stroke: (left: 1pt),
      inset: (left: 0.75em, y: 1em),
      body
    )
  )
}

#let ifblock(limit, body) = block(spacing: 0.75em, par(hanging-indent: 2.5em, {
  h(0.5em)
  limit
  h(0.5em)
  body
}))

#let lifblock(body) = ifblock($==>$, body)
#let rifblock(body) = ifblock($<==$, body)
