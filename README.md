# Koopmans functionals: predicting spectra accurately and efficiently

15-minute talk for AMN12, the 12th International
Conference on Advanced Materials and Nanotechnology, Tāmaki Makaurau
Auckland, 8–12 February 2027.

Edward Linscott, School of Physical and Chemical Sciences, University of
Canterbury.

## Building

The deck is written in [Typst](https://typst.app) using the
[uc-slides](https://github.com/elinscott/uc-slides) theme (University of
Canterbury template, shared privately; see
[uc-slides-template](https://github.com/elinscott/uc-slides-template) for how
to get access and install it as `@local/uc-slides:0.1.0`). Then:

```sh
typst compile main.typ   # writes main.pdf
typst watch main.typ     # rebuild on every save
```

Arial is used if installed and Liberation Sans otherwise.

## Layout

- `main.typ`: the slides. Figures are sized by height so that each slide,
  with its footnote citations, fits on one page; slides are non-breakable
  except the References slide.
- `figures/`, `media/`: images, mostly carried over from the Psi-k 2025 and
  LMS Showcase 2026 talks.
- `references.bib`: bibliography.

Citations appear as unnumbered footnotes, joined on one line per slide, in a
short style (first author et al., journal, volume, page, year); the References
slide at the end lists them in full. Both styles come with the theme.
