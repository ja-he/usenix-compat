// USENIX conference paper template for Typst.
// Modeled after usenix2019_v3.sty for LaTeX.

#import "@preview/pergamon:0.7.1": *
#let style = format-citation-numeric()
#let dev = pergamon-dev

#let usenix(
  // The paper's title.
  title: [Paper Title],

  // An array of authors. Each author has a `name` and `organization`.
  authors: (),

  // The paper's abstract. Can be omitted if you don't have one.
  abstract: none,

  bibliography-file-contents: none,

  // The paper's content.
  body,
) = {
  // Set document metadata.
  set document(title: title, author: authors.map(a => a.name))

  // Body font: Times Roman, 10pt.
  set text(font: "TeX Gyre Termes", size: 10pt)

  // Monospace font for code. No syntax highlighting (match LaTeX verbatim).
  show raw: set text(font: "TeX Gyre Cursor", ligatures: false, fill: black)

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
  // Bibliography citations: red (citecolor)
  // show cite: it => text(fill: rgb("#B30000"), it)
  // Internal references (sections, figures): green (linkcolor).
  // For bibliography @key refs, element is none; let cite rule handle color.
  show ref: it => {
    if it.element != none {
      text(fill: rgb("#339926"), it)
    } else {
      it
    }
  }

  if bibliography-file-contents != none {
    add-bib-resource(bibliography-file-contents)
  }

  // // Bibliography styling.
  // // TODO: plain.csl comes from 'talb' [1] and is based on the original style
  // //       created I believe by Oren Patashnik.
  // //       [1]: <https://forum.typst.app/t/a-csl-reproduction-of-bibtexs-plain-bst/6343>
  // let plain-csl = read("plain.csl", encoding: none)
  // show std.bibliography: set text(size: 10pt)
  // set std.bibliography(
  //   title: text(size: 12pt, weight: "bold")[References],
  //   style: plain-csl,
  // )

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

  refsection(format-citation: style.format-citation)[
  
    // Display the paper's contents.
    #body
  
    // Display bibliography.
    #if bibliography-file-contents != none {
      print-bibliography(
        sorting: "n",
        format-reference: format-reference(
          link-titles: false,
          print-url: true,
          reference-label: style.reference-label,
          format-fields: (
            "edition": (dffmt, value, reference, field, options, style) => {
              [#value edition]
            }
          ),
          // TODO: this thing is a whole mess and still doesn't really produce the results I want, besides going into the template internals... remove, probably
          format-functions: (
            "driver-book": (reference, options) => {
              // Helper to get edition with " edition" suffix
              let edition-str = {
                let ed = reference.fields.at("edition", default: none)
                if ed != none { [#ed edition] } else { none }
              }
              (options.periods)(
                (dev.maybe-with-date)(reference, options)(
                  (dev.author-editor-others-translator-others)(reference, options)
                ),
                (dev.title-with-language)(reference, options),
                (dev.byauthor)(reference, options),
                (dev.byeditor-others)(reference, options),
                // Volume/volumes WITHOUT edition
                (options.commas)(
                  (dev.volume-part-if-maintitle-undef)(reference, options),
                  reference.fields.at("volumes", default: none),
                ),
                (dev.series-number)(reference, options),
                reference.fields.at("note", default: none),
                // Publisher, THEN edition
                (options.commas)(
                  (dev.publisher-location-date)(reference, options),
                  edition-str,
                ),
                (options.commas)(
                  (dev.chapter-pages)(reference, options),
                  reference.fields.at("pagetotal", default: none),
                ),
                if options.print-isbn { reference.fields.at("isbn", default: none) } else { none },
                (dev.doi-eprint-url)(reference, options),
                (dev.addendum-pubstate)(reference, options)
              )
            },
          ),
        ), 

        label-generator: style.label-generator
      )
    }
  ]
}
