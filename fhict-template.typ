#import "assets/codly.typ": *

#let fontys_purple_1 = rgb("663366")
#let fontys_purple_2 = rgb("B59DB5")
#let fontys_pink_1   = rgb("E4047C")
#let fontys_blue_1   = rgb("1F3763")
#let fontys_blue_2   = rgb("2F5496")
#let code_name_color = fontys_blue_2.lighten(35%)

#let fhict_table(
  columns: (),
  content: (),
  top_colored: true,
  left_colored: false,
) = {
  table(
    columns: columns,
    inset: 7pt,
    align: horizon,
    fill: (
      if top_colored and left_colored {
        (column, row) => if column==0 or row==0 { fontys_purple_1 } else { white }
      } else if top_colored {
        (_, row) => if row==0 { fontys_purple_1 } else { white }
      } else if left_colored {
        (column, _) => if column==0 { fontys_purple_1 } else { white }
      }
    ),
    ..for row in content {
      if (row == content.at(0)) and top_colored {
        for item in row {
          (text(fill: white)[#strong(item)],)
        }
      } else {
        for item in row {
          if (item == row.at(0)) and left_colored {
            (text(fill: white)[#strong(item)],)
          } else {
            ([#item],)
          }
        }
      }
    }
  )
}

#let terms = state("terms")

#let term(
  term,
  definition: none,
) = {
  if (term != none) and (definition != none) {
    terms.update(it => (..it, (term, definition)))
  } else if (term != none) and (definition == none) {
    return [#link(label("Glossary"))[#box(term)]]
  }
}

#let fhict_doc(
  title: "Document Title",

  subtitle: "Document Subtitle",

  authors: none,

  version-history: none,

  bibliography-file: none,

  summary: none,
  table-of-figures: none,
  table-of-listings: none,

  watermark: none,

  body
) = {

  // Set metadata
  if authors == none {
    set document(title: title)    
  } else {
    set document(title: title, author: authors.map(author => author.name))
  }

  // Set the document's style
  set text(font: "Roboto", size: 11pt, fill: black)
  set cite(style: "ieee")

  // Set the header style
  set heading(numbering: "1.")
  show heading.where(level: 1): h => {text(strong(upper(h)), size: 18pt, fill: fontys_purple_1)}
  show heading.where(level: 2): h => {text(strong(upper(h)), size: 14pt, fill: fontys_pink_1)}
  show heading.where(level: 3): h => {text(upper(h), size: 12pt, fill: fontys_blue_1)}
  show heading.where(level: 4): h => {text(upper(h), size: 11pt, fill: fontys_blue_2)}
  show heading.where(level: 5): h => {text(emph(upper(h)), size: 11pt, fill: fontys_blue_2, font: "Calibri")}

  // Set the listing style
  show figure.where(kind: raw): it => {
    set align(left)
    it.body
    it.caption
  }

  // Set Cover Page
  set page("a4",
  background: [
    // Main background triangle
    #place(top + left, path(
        fill: fontys_purple_2,
        closed: true,
        (0%, 0%),
        (5%, 0%),
        ((70%, 45%), (-20pt, -20pt)),
        ((75%, 50%), (0%, -15pt)),
        ((70%, 55%), (20pt, -20pt)),
        (5%, 100%),
        (0%, 100%)
    ))
    // For scociety image
    #place(top + left, dx: 70pt, dy: 70pt, image(
        "assets/Picture1.png",
        height: 9%,
    ))
    // Title
    #place(left + horizon, dy: -20pt, dx: 40pt,
        box(
            height: 40pt,
            inset: 10pt,
            fill: fontys_pink_1,
            text(30pt, fill: white, font: "Roboto")[
                *#upper(title)*
            ]
        )
    )
    // Sub title
    #place(left + horizon, dy: 20pt, dx: 40pt,
        box(
            height: 30pt,
            inset: 10pt,
            fill: white,
            text(20pt, fill: fontys_purple_1, font: "Roboto")[
                *#upper(subtitle)*
            ]
        )
    )
    // Authors
    #set text(fill: fontys_purple_1)
    #if authors != none {
      if authors.all(x => "email" in x) {
        place(left + horizon, dy: 60pt + (
          (authors.len() - 1) * 15pt
        ), dx: 40pt,
        box(
          height: 35pt + ((authors.len() - 1) * 30pt),
          inset: 10pt,
          fill: white,
          text(10pt)[
              #authors.map(author => strong(author.name) + linebreak() + "      " + link("mailto:" + author.email)).join(",\n")
          ]))
      } else {
        place(left + horizon, dy: 48pt + (
          if authors.len() == 1 {
            5pt
          } else {
            (authors.len() - 1) * 10pt
          }
        ), dx: 40pt,
        box(
          inset: 10pt,
          fill: white,
          height: 20pt + ((authors.len() - 1) * 15pt),
          text(10pt, fill: fontys_purple_1, font: "Roboto")[
            *#authors.map(author => author.name).join(",\n")*
          ]))
      }
    }

    #set text(fill: black)
    // Date
    #place(right + horizon, dy: 330pt,
        box(
            width: 40%,
            height: 35pt,
            fill: fontys_pink_1,
            place(left + horizon, dx: 10pt,
                text(30pt, fill: white, font: "Roboto")[
                    *#datetime.today().display()*
                ]
            )
        )
    )
  ],
  foreground: [
    #if watermark != none [
    #place(center + horizon, rotate(24deg,
        text(60pt, fill: rgb(0, 0, 0, 70), font: "Roboto")[
            *#upper(watermark)*
        ]
    ))
    ]
  ]
  )

  // Show the cover page
  box()
  pagebreak()

  // Set the page style for non body pages
  set page("a4",
    background: [],
    footer: [
        #place(left + horizon, dy: -25pt,
            image("assets/Picture2.png", height: 200%)
        )
        #place(right + horizon, dy: -25pt,
            text(15pt, fill: fontys_purple_1, font: "Roboto")[
                *#counter(page).display("I")*
            ]
        )
    ]
  )
  counter(page).update(1)

  // Show the version history
  if version-history != none {
    heading("version history", outlined: false, numbering: none)
    fhict_table(
      columns: (auto, auto, auto, 1fr),
      content: (
        ("Version", "Date", "Author", "Changes"),
        ..version-history.map(version => (
          version.version,
          version.date,
          version.author,
          version.changes,
        )),
      ),
    )
    pagebreak()
  }

  show: codly-init.with()
  codly(languages: (
      rust: (name: "Rust", color: code_name_color),
      rs: (name: "Rust", color: code_name_color),
      cmake: (name: "CMake", color: code_name_color),
      cpp: (name: "C++", color: code_name_color),
      c: (name: "C", color: code_name_color),
      py: (name: "Python", color: code_name_color),
      java: (name: "Java", color: code_name_color),
      js: (name: "JavaScript", color: code_name_color),
      sh: (name: "Shell", color: code_name_color),
      bash: (name: "Bash", color: code_name_color),
      json: (name: "JSON", color: code_name_color),
      xml: (name: "XML", color: code_name_color),
      yaml: (name: "YAML", color: code_name_color),
      typst: (name: "Typst", color: code_name_color),
    ),
    width-numbers: none,
    display-icon: false,
  )

  // Show the summary
  if summary != none {
    heading("summary", outlined: false, numbering: none)
    summary
    pagebreak()
  }

  // Show the table of contents
  outline(
    title: "Table of Contents",
    depth: 3,
    indent: n => [#h(1em)] * n,
  )
  pagebreak()

  // Show the table of figures if requested
  if (table-of-figures != none) and (table-of-figures != false) {
    outline(
      title: "Table Of Figures",
      target: figure.where(kind: image),
    )
    pagebreak()
  }

  // Show the table of listings if requested
  if (table-of-listings != none) and (table-of-listings != false) {
    outline(
      title: "Table Of Listings",
      target: figure.where(kind: raw),
    )
    pagebreak()
  }

  // Set the page style for body pages
  set page("a4",
    background: [],
    footer: [
        #place(left + horizon, dy: -25pt,
            image("assets/Picture2.png", height: 200%)
        )
        #place(right + horizon, dy: -25pt,
            text(15pt, fill: fontys_purple_1, font: "Roboto")[
                *#counter(page).display()*
            ]
        )
    ]
  )
  counter(page).update(1)

  // Show the page's contents
  body

  // Show the bibliography
  if bibliography-file != none {
    pagebreak()
    bibliography(bibliography-file, title: "References", style: "ieee")
  }

  // Show the Glossary
  terms.display( (terms) => {
    if terms != none {
      pagebreak()
      heading("Glossary", numbering: none)
      [#figure(
      table(
        inset: 7pt,
        align: horizon + left,
        columns: (auto, 1fr),
        [#text(fill: white)[#strong("Term")]], [#text(fill: white)[#strong("Definition")]],
        ..terms.map( item => (text()[#strong(item.at(0))], item.at(1))).flatten(),
        fill: (column, row) => if row==0 { fontys_purple_1 } else { white },
      ))
      <Glossary>]
    }
  })
}

#let todo(body) = block(
  above: 2em, stroke: 0.5pt + red,
  width: 100%, inset: 14pt,
  breakable: false
)[
  #set text(font: "Roboto", fill: red)
  #place(
    top + left,
    dy: -6pt - 14pt,
    dx: 6pt - 14pt,
    block(fill: white, inset: 2pt)[*DRAFT*]
  )
  #body
]
