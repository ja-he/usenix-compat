// USENIX conference paper template for Typst.
// Modeled after usenix2019_v3.sty for LaTeX.

#let usenix(
  // The paper's title.
  title: [Paper Title],

  // An array of authors. Each author has a `name` and `organization`.
  authors: (),

  // The paper's abstract. Can be omitted if you don't have one.
  abstract: none,

  // The result of a call to the `bibliography` function or `none`.
  bibliography: none,

  mandatory-appendices: (),
  nonmandatory-appendices: (),

  // The paper's content.
  body,
) = {
  // Set document metadata.
  set document(title: title, author: authors.map(a => a.name))

  // Body font: Times Roman, 10pt.
  set text(font: "TeX Gyre Termes", size: 10pt)

  // Monospace font for code. No syntax highlighting (match LaTeX verbatim).
  show raw: set text(size: 10pt, font: "TeX Gyre Cursor", ligatures: false, fill: black)

  // Page setup: US Letter, two-column, USENIX margins.
  // Active text area: 7in x 9in.
  set columns(gutter: 0.33in)
  set page(
    paper: "us-letter",
    columns: 2,
    margin: (x: 0.75in, top: 1in, bottom: 1in),
    numbering: "1",
  )

  // Paragraph settings.
  // LaTeX article 10pt: \parindent=15pt, \baselineskip=12pt, \parskip=0pt.
  set par(
    justify: true,
    first-line-indent: 10.0pt,
    leading: 0.54em,
    spacing: 0.54em,
  )

  // Equation numbering.
  set math.equation(numbering: "(1)")

  // Lists.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  // Heading numbering.
  set heading(numbering: "1.1.1")

  // Level 1 headings: 12pt bold, \large\bf in LaTeX.
  // LaTeX \@startsection: beforeskip=-3.5ex (~16pt), afterskip=2.3ex (~10.5pt).
  // Typst block spacing is edge-to-edge, not baseline-to-baseline, so
  // we add extra to compensate for the heading descent + body ascent gap.
  show heading.where(level: 1): it => {
    set text(size: 12pt, weight: "bold")
    set par(first-line-indent: 0pt)
    block(above: 20pt, below: 16.0pt, sticky: true, {
      if it.numbering != none {
        counter(heading).display()
        h(1em, weak: true)
      }
      it.body
    })
  }

  // Level 2 headings: 10pt bold, \normalsize\bf in LaTeX article.cls.
  // LaTeX article.cls: beforeskip=-3.25ex (~15pt), afterskip=1.5ex (~6.9pt).
  show heading.where(level: 2): it => {
    set text(size: 12pt, weight: "bold")
    set par(first-line-indent: 0pt)
    block(above: 20pt, below: 12pt, sticky: true, {
      if it.numbering != none {
        counter(heading).display()
        h(1em, weak: true)
      }
      it.body
    })
  }

  // Figure captions: left-aligned, 10pt.
  show figure.caption: it => [
    #set text(size: 10pt)
    #set align(start)
    #it.supplement
    #context it.counter.display(it.numbering):
    #h(3pt)
    #it.body
  ]
  set figure(gap: 2.4em)
  show figure: set place(
    clearance: 3em,
  )
  show footnote: set text(fill: rgb("#339926"))
  set terms(spacing: 12.0pt)
  show terms: set par(spacing: 14.4pt)

  // Code blocks: no background, no frame (match LaTeX verbatim).
  show raw.where(block: true): set block(above: 1em, below: 1em)

  // Colored hyperlinks to match USENIX LaTeX style.
  // LaTeX: linkcolor=green!80!black, citecolor=red!70!black, urlcolor=blue!70!black
  show link: set text(fill: rgb("#0000B3"))
  // Bibliography citations: number red, brackets/delimiters black (citecolor).
  // Scoped regex colors only digit runs, leaving brackets and commas in default color.
  show cite: it => {
    show regex("\d+"): m => text(fill: rgb("#B30000"), m)
    it
  }
  // Internal references (sections, figures): supplement in default color, number green.
  // Matches LaTeX hyperref behavior where only the number is a colored link.
  // For bibliography @key refs, element is none; let cite rule handle color.
  show ref: it => {
    if it.element != none {
      let el = it.element
      let sup = it.supplement
      if sup == auto { sup = el.supplement }

      if el.func() == heading and el.numbering != none {
        if sup == auto { sup = [Section] }
        let num = numbering(el.numbering, ..counter(heading).at(el.location()))
        link(el.location(), { text(fill: black, {sup; [ ]}); text(fill: rgb("#339926"), num) })
      } else if el.func() == figure and el.numbering != none {
        if sup == auto { sup = if el.kind == table { [Table] } else { [Figure] } }
        let num = numbering(el.numbering, ..counter(figure.where(kind: el.kind)).at(el.location()))
        link(el.location(), { text(fill: black, {sup; [ ]}); text(fill: rgb("#339926"), num) })
      } else {
        text(fill: rgb("#339926"), it)
      }
    } else {
      it
    }
  }

  // Bibliography styling.
  // TODO: plain.csl comes from 'talb' [1] and is based on the original style
  //       created I believe by Oren Patashnik.
  //       [1]: <https://forum.typst.app/t/a-csl-reproduction-of-bibtexs-plain-bst/6343>
  let plain-csl = read("plain.csl", encoding: none)
  show std.bibliography: set text(size: 10pt)
  set std.bibliography(
    title: text(size: 12pt, weight: "bold")[References],
    style: plain-csl,
  )

  // Title block spanning both columns.
  // LaTeX: \vbox to 2.5in with vertically centered content.
  place(
    top,
    float: true,
    scope: "parent",
    clearance: 0pt,
    box(width: 100%, height: 2.3in + 15pt, {
      set par(first-line-indent: 0pt, leading: 0.65em)
      align(center + horizon, {
        // Title: 14pt bold (\Large\bf in LaTeX).
        block(below: 3.4em, text(size: 14.4pt, weight: "bold", title))

        // Authors: 12pt italic for affiliation, roman for name.
        set text(size: 12pt, style: "italic")
        grid(
          columns: authors.len() * (auto,),
          gutter: 46pt,
          ..authors.map(author => align(center, {
            text(style: "normal", author.name)
            linebreak()
            author.organization
          }))
        )
      })
    })
  )

  // Abstract.
  if abstract != none {
    set par(first-line-indent: 0pt)
    align(center, text(size: 12pt, weight: "bold")[Abstract])
    v(1.0pt)
    abstract
    // section block's 'above' will take care of this spacing after.
  }

  // Display the paper's contents.
  body

  {
    set heading(numbering: none, supplement: none)
    counter(heading).update(0)
    show heading: it => {
      set text(12pt, weight: "bold")
      show: block.with(above: 15pt, below: 13.75pt, sticky: true)
      it.body
    }
    for a in mandatory-appendices {
      a
    }
  }

  // Display bibliography.
  if bibliography != none {
    bibliography
  }

  set heading(numbering: "A")
  counter(heading).update(0)
  for a in nonmandatory-appendices {
    a
  }
}
