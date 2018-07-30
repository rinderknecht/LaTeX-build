# A GNU Makefile for building LaTeX documents

The makefile in this directory automates the building of LaTeX
documents, with minimal user input. In particular, it can handle the
making of figures, bibliographic entries with BibTeX, indexes with
MakeIndex, and different output formats, like DVI, PostScript and
PDF. Importantly, it tries really hard to reverse-engineer the TeX log
files in order to produce helpful error messages.

All your LaTeX sources are expected to be located in the same
directory as the makefile.

Warning! This makefile does *not* use `pdflatex`.

## A session sample

The followinng is an excerpt of a session showing that the makefile
can also handle the processing of XML and Erlang programs, if some of
our TeX macros are loaded.

    $ make
    Making figure 2way_bal.dvi... done (1 page, 27580 bytes).
    Converting 2way_bal.dvi to EPSF... done (1 page, 181K bytes).
    [...]
    Making figure zigzag.dvi... done (1 page, 8384 bytes).
    Converting zigzag.dvi to EPSF... done (1 page, 113K bytes).
    Checking well-formedness of XML/entities.xml... done.
    Checking well-formedness of XML/scoping.xml... done.
    [...]
    Checking well-formedness of XML/num.xml... done.
    Validating XML/csv_att.xml... done.
    Validating XML/csv.xml... done.
    [...]
    Validating XML/toc.xml... done.
    Checking well-formedness of XSLT/empty.xsl... done.
    Checking well-formedness of XSLT/chapter.xsl... done.
    [...]
    Checking well-formedness of XSLT/tmerge.xsl... done.
    Compiling Erlang/mean.erl... done.
    Compiling Erlang/max.erl... done.
    Making XML/cookbook1_out.xml using XSLT... done.
    Making XML/cookbook2_out.xml using XSLT... done.
    [...]
    Making num_out.txt using XSLT... done.
    Processing design.tex... done (644 pages, 2023840 bytes).
    Processing bibliography design.bib... done (173 entries).
    Merging the bibliography... FAILED:
    Run [make diag] for diagnostics.
    Collating the index... done (1699 entries accepted, 0 rejected, 0 warnings).
    Merging the index... done (676 pages, 2146992 bytes).
    Number of figures: 266.
    Processing design.tex... done (676 pages, 2147100 bytes).
    Warning: 1 horizontal underfull.
    Warning: 12 vertical underfulls.
    LaTeX Warning: Text page 298 contains only floats.
    LaTeX Warning: Label(s) may have changed. Rerun to get cross-references right.
    
    $ make more
    Processing bibliography design.bib... done (173 entries).
    Merging the bibliography... done (676 pages, 2147100 bytes).
    Processing design.tex... done (676 pages, 2147100 bytes).
    Warning: 1 horizontal underfull.
    Warning: 12 vertical underfulls.
    LaTeX Warning: Text page 298 contains only floats.
    
    $ make diag
      [W] Underfull \vbox (badness 7832) in persistence.tex.
          => Check page 73.
      [W] Underfull \hbox (badness 1117) in factoring.tex at lines 1086--1138.
          => Check page 182 and line 1113 in design.log.
      [...]
      [W] Underfull \vbox (badness 1824) in subset.tex.
          => Check page 616.
    Status of bibliography design.bib:
    nothing to report.

## Parameters

You need a file `Makefile.cfg` containing, at least, the assignment to
the variable `TEX` of the basename of the main LaTeX file, that is,
the one containing the enclosure `\begin{document}
... \end{document}`. Only one main document is allowed per
directory. If that main document includes or inputs other LaTeX
documents, the basename of those also have to be assigned to the
variable `TEX`, but _after_ the main file.

Here is an incomplete list of variable you can set in `Makefile.cfg`
to parameterise the build of your document.

  * `TEX` All the (La)TeX files, the main document listed first.

  * `DEF` Contains TeX `\def` commands.

  * `BIB` Basename of the BibTeX file.

  * `IDX` Set to `"yes"` if there is an index; default is `"no"`.

  * `ETC` Names of files not built by this makefile.

  * `USE_PS` Set to `"yes"` to force the use of `ps2pdf`; `"no"` for
    `dvipdfm(x)`. Default is `"no"`.

  * `ORIENT` Set to `"landscape"` to force landscape mode; else
          `"portrait"` (default)

  * `FIRST` First page to be extracted from a PDF

  * `LAST` Last page to be extracted from a PDF

  * `PP` The page range, e.g., `PP=5-13`, `PP=6-`, `PP='2-4 7-11'`
    Beware the page numbers are taken from TeX with `dvips`, whilst
    with `dvipdfm`, they are absolute.


## Figures

Our convention is to assume that a figure name without extension or
with the extension `.ps` are made from a LaTeX file, otherwise a
file with that name is expected to exist or obtained by conversion
from other formats. For example,

     \includegraphics{foo}

and

     \includegraphics{foo.ps}

both require `foo.ps`, whereas

     \includegraphics{foo.eps}

requires `foo.eps`, which may be obtained by conversion from other
formats (see list below). See the phony targets `fig` and `figname`
below.

## Targets

  * `conf` Checks the availability of a list of tools needed.

  * `diag` Extracts errors and warnings from the TeX, BibTeX and
    MakeIndex log files, and pretty-prints them.

  * `fig` Makes all figures.

  * `figname` Prints the figure names extracted.

  * `dvi` Builds the DVI.

  * `pdf` Builds the PDF.

  * `ps`  Builds the PostScript.

  * `more` Forces another complete run of LaTeX, assuming a previous
    run. This is needed when dealing with cross-references within a
    bibliography, for instance, or to print the warnings again.

  * `once` Forces one run of LaTeX.

  * `index` Forces the index construction.

  * `clean` Removing intermediary files.

  * `distclean` Removes more intermediary files, including temporary
    Emacs files.
