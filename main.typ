#import "@local/uc-slides:0.1.0": *
#import "@preview/mannot:0.3.0": *

// AMN12, Tāmaki Makaurau Auckland, 8–12 February 2027. 15-minute talk.
//
// The body area of a content slide is about 4.6in tall; figures below are
// sized by height so that each slide (plus its footnote citations) fits
// without spilling onto an extra page.

#show: uc-theme.with(
  heading-size: 40pt,
  text-size: 20pt,
  config-info(
    title: [Koopmans functionals],
    subtitle: [Predicting spectra accurately and efficiently],
    author: [Edward Linscott],
    institution: [School of Physical and Chemical Sciences, University of Canterbury],
    date: [AMN12, Tāmaki Makaurau Auckland, February 2027],
  ),
  config-common(
    show-bibliography-as-footnote: true,
    footnote-style: it => none, // no citation marker in the text ...
    breakable: false, // never spill a slide onto an extra page
    detect-overflow: false, // its measurement pass does not converge with mannot's annotations
  ),
)

// ... and the footnotes themselves unnumbered and run together on one line,
// separated by semicolons: the first footnote on a page renders every
// footnote of that page, the rest render nothing.
#set footnote.entry(clearance: 0em, gap: 0em)
#show footnote.entry: it => context {
  let page = it.note.location().page()
  let notes = query(footnote).filter(f => f.location().page() == page and type(f.body) != label)
  if notes.first().location() == it.note.location() {
    notes.map(f => f.body).join([; ])
  }
}

// Footnote citations use the short style (first author et al., no title).
// A citation binds to the next `bibliography` after it, so a hidden short-style
// bibliography sits at the top of the References slide and the visible one
// there uses the full style; see that slide.
#set bibliography(title: none)

#let red = uc-colors.red

// Small grey caption, optionally with citations, centred under a figure
#let caption(body) = align(center, text(size: 0.8em, fill: uc-colors.grey, body))

#title-slide()

// ---------------------------------------------------------------------------
// Motivation
// ---------------------------------------------------------------------------

== Predicting electronic excitations

#align(center, grid(
  columns: 3,
  column-gutter: 1em,
  align: horizon,
  image("figures/arpes.png", height: 1.4in),
  image("figures/nguyen_2015_buckyball_pes.png", height: 1.4in),
  image("figures/arpes_puppin.png", height: 1.4in),
))
#caption[photoemission spectroscopy@Nguyen2015@Puppin2020]

#pause

Spectra are how we see electrons in materials. Predicting them is a computational challenge:

#pause

- quantum chemistry: the gold standard, but scales prohibitively (for now...)
- GW: accurate but expensive, often ill-behaved, diagrammatic
- DFT: cheap and ubiquitous, but plagued by intrinsic errors

== A key failure of DFT

#align(center, image("figures/ip_2.svg", height: 3.4in))
#caption[ionisation potentials of the elements@Dabo2010]

== What's going wrong?

#slide(composer: (1.1fr, 1fr), align: horizon)[
  The exact quasiparticle energies are total energy differences
  $
    ε_i = cases(E(N) - E_i (N-1) & "if" i in "occ", E_i (N+1) - E(N) & "if" i in "emp")
  $

  _cf._ Janak's theorem:
  $
    ε_i^"DFT" = frac(dif E^"DFT", dif f_i)
  $

  DFT's total energy is #emph[not] piecewise-linear in $f_i$, so its eigenvalues are poor excitation energies
][
  #align(center, image("figures/fig_en_curve_gradients_zoom.svg", width: 100%))
]

#focus-slide[Core idea: enforce piecewise linearity]

// ---------------------------------------------------------------------------
// Theory
// ---------------------------------------------------------------------------

== Imposing piecewise linearity

// The KI functional, with the two corrective terms highlighted in turn
#let ki-eq(step) = {
  let hl(n, body, tag) = if step >= n { markhl(body, tag: tag, color: red) } else { body }
  let note(body) = text(size: 0.75em, body)
  $
    E^"KI" &[rho, {rho_i}] = E^"DFT" [rho] \
    & + sum_i (
      - #hl(2, $integral_0^f_i lr(chevron.l phi_i mid(|) hat(h)^"DFT" (f) mid(|) phi_i chevron.r) dif f$, <remove-nonlin>)
    \ & #v(0.6em) \
    & #h(2.2em) + #hl(3, $f_i integral_0^1 lr(chevron.l phi_i mid(|) hat(h)^"DFT" (f) mid(|) phi_i chevron.r) dif f$, <restore-linear>)
    )
  $
  if step >= 2 { annot(<remove-nonlin>, pos: bottom)[#note[removes dependence on $f_i$]] }
  if step >= 3 { annot(<restore-linear>, pos: bottom)[#note[restores linear dependence on $f_i$]] }
}

#slide(composer: (1.2fr, 1fr), align: horizon)[
  #alternatives(repeat-last: true, ..range(1, 4).map(ki-eq))
  #v(2em)
][
  #align(center, image("figures/fig_en_curve_gradients_zoom.svg", width: 100%))
]

== Making it tractable: electronic screening

#align(center, alternatives(repeat-last: true)[
  #image("figures/fig_pwl_DFT.svg", height: 2.8in)
][
  #image("figures/fig_pwl_uKI.svg", height: 2.8in)
][
  #image("figures/fig_pwl_alphaKI.svg", height: 2.8in)
])

#uncover("3")[
  #text(size: 0.8em)[
    $
      E^"KI"_bold(alpha) [rho, {rho_i}] = E^"DFT" [rho] + sum_i alpha_i {
        - (E^"DFT" [rho] - E^"DFT" [rho - rho_i])
        + f_i (E^"DFT" [rho - rho_i + n_i] - E^"DFT" [rho - rho_i])
      }
    $
  ]
  Frozen-orbital energy differences, corrected by screening parameters $alpha_i$ computed #emph[ab initio], not fitted
]

== Overcoming a key failure of DFT

#align(center, alternatives[
  #image("figures/ip_2.svg", height: 3.4in)
][
  #image("figures/ip_3.svg", height: 3.4in)
])
#caption[ionisation potentials of the elements@Dabo2010]

// ---------------------------------------------------------------------------
// Results
// ---------------------------------------------------------------------------

== Accurate across molecules and solids

#slide(composer: (1.1fr, 1fr), align: horizon)[
  #align(center)[
    #image("figures/colonna_2019_gw100_ip.jpeg", height: 1.25in)
    #caption[molecular ionisation potentials@Colonna2019]
    #v(0.3em)
    #image("figures/fig_nguyen_prl_spectra_pink.png", height: 1.15in)
    #caption[UV photoemission spectra@Nguyen2015]
  ]
][
  #align(center)[
    #image("figures/scatter_plot.png", height: 3.0in)
    #caption[semiconductor & insulator gaps@Nguyen2018]
  ]
]

== ... and beyond band structures

#align(center, grid(
  columns: 3,
  align: horizon + center,
  column-gutter: 1.5em,
  row-gutter: 0.4em,
  image("figures/marrazzo_cspbbr3_soc_bands.png", height: 2.4in),
  image("figures/poliukhin_gaas_mobility_temperature.png", height: 2.4in),
  image("figures/cistaro_si_rt_hsex.png", height: 2.4in),
  caption[spin-orbit coupling & magnetism@Marrazzo2024],
  caption[electron-phonon transport@Poliukhin2025],
  caption[real-time electron dynamics@Cistaro2026],
))

== Fast: machine-learned screening

#slide(composer: (1fr, 1fr), align: horizon)[
  #align(center)[
    #image("figures/convergence_key.png", height: 0.25in)
    #v(-0.6em)
    #image("figures/convergence_fig.png", height: 2.4in)
  ]
  *accurate* to within $cal(O)$(10 meV), _cf._ typical band gap accuracy of $cal(O)$(100 meV)
][
  #align(center, image("figures/speedup.png", height: 2.6in))
  *speed-up* of $cal(O)$(10) to $cal(O)$(100)@Schubert2024
]

// ---------------------------------------------------------------------------
// The code
// ---------------------------------------------------------------------------

#focus-slide[
  #align(center, image("media/logos/koopmans_white_on_transparent.svg", width: 60%))
]

== `koopmans`: a black box for spectra

#slide(composer: (1.2fr, 2fr), align: horizon)[
  #image("figures/black_box_filled_square.png", height: 3.3in)
][
  Our goal:
  - accurate
  - robust
  - fast
  - minimal input and technical expertise required

  Automated workflows on top of `Quantum ESPRESSO`, with a Python API

  See `koopmans-functionals.org`@Linscott2023
]

// ---------------------------------------------------------------------------
// Close
// ---------------------------------------------------------------------------

== Summary

Koopmans functionals enforce piecewise linearity, turning DFT into a predictive tool for spectra...

#v(0.5em)
#align(center, grid(
  columns: 4,
  column-gutter: 1.5em,
  align: horizon,
  image("figures/fig_en_curve_gradients_zoom.svg", height: 1.9in),
  image("figures/scatter_plot.png", height: 1.9in),
  image("figures/poliukhin_gaas_mobility_temperature.png", height: 1.9in),
  image("figures/cistaro_si_rt_hsex.png", height: 1.9in),
))
#v(0.5em)

... and development continues: ARPES, pump-probe spectroscopy, and more.

== Acknowledgements

#slide(align: horizon)[
  #set text(size: 0.6em)
  #align(center, grid(
    columns: 8,
    column-gutter: 0.6em,
    row-gutter: 0.4em,
    align: center,
    image("media/mugshots/nicola_colonna.png", height: 1.4in),
    image("media/mugshots/miki_bonacci.jpg", height: 1.4in),
    image("media/mugshots/aleksandr_poliukhin.jpg", height: 1.4in),
    image("media/mugshots/marija_stojkovic.jpg", height: 1.4in),
    image("media/mugshots/junfeng_qiao.jpeg", height: 1.4in),
    image("media/mugshots/yannick_schubert.jpg", height: 1.4in),
    image("media/mugshots/giovanni_cistaro.jpeg", height: 1.4in),
    image("media/mugshots/nicola_marzari.jpeg", height: 1.4in),
    [Nicola Colonna], [Miki Bonacci], [Aleksandr Poliukhin], [Marija Stojkovic],
    [Junfeng Qiao], [Yannick Schubert], [Giovanni Cistaro], [Nicola Marzari],
  ))

  #v(1.5em)
  #align(center, grid(
    columns: 3,
    align: horizon + center,
    gutter: 2.5em,
    image("media/logos/SNF_logo_standard_web_color_pos_e.svg", height: 0.6in),
    image("media/logos/marvel_color_on_transparent.png", height: 0.6in),
    image("media/logos/psi_black.svg", height: 0.6in),
  ))
]

#end-slide[
  edward.linscott\@canterbury.ac.nz #h(2em) `koopmans-functionals.org`
]

== References

// the only slide allowed to run over several pages
#slide(config: config-common(breakable: true))[
  #set text(size: 0.6em)
  // short-style bibliography that the footnotes bind to (takes no space)
  #place(hide(bibliography("references.bib", style: "nature-footnote.csl")))
  // re-cite everything cited so far (invisibly) so it binds to the full-style list below
  #context for key in magic.bibliography-visited.final() { cite(key, form: none) }
  #bibliography("references.bib", style: "nature.csl")
]
