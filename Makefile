# GNU Makefile (>= 4.0) for building LaTeX-based documents
# (c) 2012-2018, Christian Rinderknecht (rinderknecht@free.fr)
#
# ====================================================================
# General Settings (GNU Make 4.1 recommended)

# Checking version of GNU Make

AT_LEAST := 4.0
OK := ${filter ${AT_LEAST}, \
               ${firstword ${sort ${MAKE_VERSION} ${AT_LEAST}}}}

ifeq (,${OK})
${error Requires GNU Make ${AT_LEAST} or higher}
endif

# Setting the flags of GNU Make (no built-in rules, silent)

MAKEFLAGS =-Rrs

# Setting some variables of GNU Make

.DELETE_ON_ERROR:
.ONESHELL:        # One call to the shell per recipe
.RECIPEPREFIX = > # Use '>' instead of TAB for recipes
.SUFFIXES:        # Removing (almost) all built-in rules

# GNU Make should not try to update any makefile, not any TeX file.

Makefile GNUmakefile makefile Makefile.cfg: ;

%.tex:: ;

# Setting the flags of GNU Make (no built-in rules, silent)

MAKEFLAGS =-Rrsi

# More special targets
#
.PHONY: beam clean diag distclean doc dvi fig figname index \
        more once pdf ps valid
.PRECIOUS: %.dvi0 %.dvi1 %.dvi

# Checking system configuration (for debugging purposes)

CMD := "bibtex convert dvipdfm dvips erlc fig2dev grep gs latex \
        makeindex pdflatex ps2pdf sed xmllint decrypt.sh"

define chk_cfg
IFS=':'
for cmd in ${1}; do
  found=no
  for dir in $$PATH; do
    if test -z "$$dir"; then dir=.; fi
    if test -x "$$dir/$$cmd"; then found=$$dir; break; fi
  done
  if test "$$found" = "no"
  then echo "Shell command $$cmd not found."
  else echo "Found $$found/$$cmd"
  fi
done
endef

.PHONY: conf
conf:
> ${call chk_cfg,"${CMD}"}

# Default settings
#
IDX     := no
USE_PS  := no
ORIENT  := portrait

ifneq (${TEX},)
TEX :=#
endif

sinclude Makefile.cfg

# The first TeX file in ${TEX} (without .tex) is the main document
# ${DOC}.

ifeq (${TEX},)
  ${error "Please set TEX in Makefile.cfg"}
else
DOC := ${firstword ${TEX}}
  ifeq (${DOC},)
  ${error Please define TEX in Makefile.cfg}
  endif
endif

SRC := ${TEX:%=%.tex} ${ETC} ${BIB:%=%.bib}

# DVI is the default output format

.DEFAULT_GOAL := ${DOC}.dvi

# Tracing

export TRACE

# Preparing the build script (may remain empty if no TRACE=yes)

define sync
printf "#!/bin/sh\nset -x\n" > build.sh
endef

.PHONY: sync
sync:
> ${call sync}

clean::
> rm -f build.sh

# Paper orientation (default is "portrait")

ifeq (${ORIENT},landscape)
ORIENT :=-t landscape
else
PAPER :=-t a4
ORIENT :=#
endif

# Included figures

ifndef FIG
FIG := ${shell sed -n 's|^[^%]*\\includegraphics[*]\{0,1\}\(\[.*\]\)\{0,1\}[{]\([-_\.[:alnum:]]\{1,\}\)[}].*|\2|p' *.tex 2>/dev/null | sort -d | uniq | tr '\n' ' '}
endif

ALL_FIG := ${shell normal=; \
  for graphics in ${FIG}; do \
    case $$graphics in \
      *.pdf|*.jpg|*.png|*.eps|*.ps) normal="$$normal $$graphics";; \
               *) normal="$$normal $$graphics.ps";; \
    esac; \
  done; \
  echo $$normal | tr ' ' '\n' | sort -d | uniq \
                | tr '\n' ' ' | tr -s ' '}

PS_FIG  := ${filter %.ps,${ALL_FIG}}
DVI_FIG := ${PS_FIG:%.ps=%.dvi}

# Making Erlang bytecode (BEAM)

ifneq (${ERL},)
  ifeq (${ERL_DIR},)
    ${error Please set ERL_DIR in Makefile.cfg}
  else
BEAM := ${ERL:%=${ERL_DIR}/%.beam}

beam: ${BEAM}

define mk_beam
err=${dir $<}.${notdir $<}.err
if test -e $< -a $$err -nt $<
then cat $$err
else printf "Compiling $<..."
     erlc -o ${ERL_DIR} $< > $$err
     if test -s $$err
     then echo " FAILED:"; cat $$err
     else echo " done."; rm -f $$err
     fi
fi
endef

${ERL_DIR}/%.beam: ${ERL_DIR}/%.erl
> ${call mk_beam}

clean::
> rm -f ${ERL:%=${ERL_DIR}/.%.err} ${BEAM}
  endif
endif

# Validation of XML and HTML files
#   ${1}: "--valid" if validation requested (DTD present)

define validate
err=${dir $<}.${notdir $<}.err
ok=${dir $<}.${notdir $<}.ok
if test -e $< -a $$err -nt $<
then cat $$err
else if test -z "${1}"
     then printf "Checking well-formedness of $<..."
     else printf "Validating $<..."
     fi
     xmllint --noout ${1} $< 2> $$err
     if test -s $$err
     then echo " FAILED:"; cat $$err
     else echo " done."; mv $$err $$ok
     fi
fi
endef

ALL_XML := ${strip ${XML} ${XML_DTD}}

ifneq (${ALL_XML},)
  ifeq (${XML_DIR},)
    ${error Please set XML_DIR in Makefile.cfg}
  else
XML_OK := ${XML:%=${XML_DIR}/.%.xml.ok}
XML_DTD_OK := ${XML_DTD:%=${XML_DIR}/.%.xml.ok}

valid:: ${XML_OK} ${XML_DTD_OK}

${XML_OK}: ${XML_DIR}/.%.ok: ${XML_DIR}/%
> ${call validate}

${XML_DTD_OK}: ${XML_DIR}/.%.ok: ${XML_DIR}/%
> ${call validate,--valid}

.PHONY: clean_val
clean:: clean_val

clean_val::
> rm -f ${XML:%=${XML_DIR}/.%.xml.err} ${XML_OK}
> rm -f ${XML_DTD:%=${XML_DIR}/.%.xml.err} ${XML_DTD_OK}
  endif
endif

ifneq (${HTML},)
  ifeq (${XML_DIR},)
    ${error Please set XML_DIR in Makefile.cfg}
  else
HTML_OK := ${HTML:%=${XML_DIR}/.%.html.ok}

valid:: ${HTML_OK}

${HTML_OK}: ${XML_DIR}/.%.ok: ${XML_DIR}/%
> ${call validate}

clean_val::
> rm -f ${HTML:%=${XML_DIR}/.%.html.err} ${HTML_OK}
  endif
endif

# Validation of XSLT files

ifneq (${XSLT},)
  ifeq (${XSLT_DIR},)
    ${error Please set XSLT_DIR in Makefile.cfg}
  else
XSLT_OK := ${XSLT:%=${XSLT_DIR}/.%.xsl.ok}

valid:: ${XSLT_OK}

${XSLT_OK}: ${XSLT_DIR}/.%.ok: ${XSLT_DIR}/%
> ${call validate}

clean_val::
> rm -f ${XSLT:%=${XSLT_DIR}/.%.xsl.err} ${XSLT_OK}
  endif
endif

# TeX/LaTeX options and definitions

TEX_OPT :=-shell-escape -interaction=batchmode
override TEX_DEF := "\batchmode${DEF}\listfiles\input"

# DVI is the default output format and A4 is the paper size.

dvi: ${DOC}.dvi

define mk_pdf
${MAKE} ${DOC}.pdf
printf "Extracting pages ${FIRST} to ${LAST}..."
gsdb=$$(gs -sPAPERSIZE=a4 \
           -sDEVICE=pdfwrite -dQUIET -dNOPAUSE -dBATCH -dSAFER \
           -dFirstPage=${FIRST} -dLastPage=${LAST} \
           -sOutputFile=${DOC}--${FIRST}-${LAST}.pdf \
           ${DOC}.pdf 2>&1)
if test "$$?" = "0"
then if test -z "$$gsdb"
     then echo " done."
     else printf " done, but:\n$$gsdb\n"
     fi
else echo " FAILED."
fi
endef

ifneq (${FIRST},)
  ifneq (${LAST},)
pdf:
> ${call mk_pdf}
  else
pdf: ${DOC}.pdf
  endif
else
pdf: ${DOC}.pdf
endif

ps: ${DOC}.ps

# Forcing one run of LaTeX

once:
> ${call mk_dvi}

# Forcing another complete run of LaTeX, assuming a previous run.

more:
ifneq (${BIB},)
> ${call mk_bbl}
> ${call mrg_bib}
endif
> ${call mk_dvi}
> ${call warnings}

# Forcing index construction

index:
> ${call mk_idx}
> ${call mk_dvi}

# Calling diagnostics after an error occurred

diag:
> decrypt.sh ${DOC}.log

# Underfulls/Overfulls (summary)

define under_over
overfull_hbox=$$(grep 'Overfull \\hbox' ${DOC}.log 2>/dev/null \
                 | wc -l | tr -d ' ')
case $$overfull_hbox in
  0|"") ;;
  1) echo "Warning: 1 horizontal overfull.";;
  *) echo "Warning: $$overfull_hbox horizontal overfulls.";;
esac
overfull_vbox=$$(grep 'Overfull \\vbox' ${DOC}.log 2>/dev/null \
                 | wc -l | tr -d ' ')
case $$overfull_vbox in
  0|"") ;;
  1) echo "Warning: 1 vertical overfull.";;
  *) echo "Warning: $$overfull_vbox vertical overfulls.";;
esac
underfull_hbox=$$(grep 'Underfull \\hbox' ${DOC}.log 2> /dev/null \
                  | wc -l | tr -d ' ')
case $$underfull_hbox in
  0|"") ;;
  1) echo "Warning: 1 horizontal underfull.";;
  *) echo "Warning: $$underfull_hbox horizontal underfulls.";;
esac
underfull_vbox=$$(grep 'Underfull \\vbox' ${DOC}.log 2> /dev/null \
                 | wc -l | tr -d ' ')
case $$underfull_vbox in
  0|"") ;;
  1) echo "Warning: 1 vertical underfull.";;
  *) echo "Warning: $$underfull_vbox vertical underfulls.";;
esac
endef

# All warnings

define warnings
${call under_over}
grep "LaTeX Warning" ${DOC}.log 2>/dev/null
printf ""
grep "Package .* Warning" ${DOC}.log 2>/dev/null
printf ""
endef

# Calling dvips
#   ${1}: dvips options
#   ${2}: DVI file (source)
#   ${3}: PostScript file (target)

define dvips
  if test "${TRACE}" = "yes"; then
    echo "dvips ${1} -o ${3} ${2}" \
  | tr -s  ' ' >> build.sh
  fi
  dvips ${1} -o ${3} ${2} > /dev/null 2>&1
  num_of_pages=$$(sed -En 's|%%Pages: ([^ ]+).*|\1|p' ${3} \
                  | head -n 1)
  size=$$(ls -hAl ${3} | tr -s ' ' | cut -d ' ' -f 5)
  if test "$$num_of_pages" = "1" -o -z "$$num_of_pages"
  then printf " done (1 page, $$size bytes)"
  elif test -n "$$num_of_pages"
  then printf " done ($$num_of_pages pages, $$size bytes)"
  fi
  echo "."
endef

# Calling dvipdfm(x)
#   ${1}: DVI file (source)
#   ${2}: PDF file (target)

define dvipdfm
  if test "${TRACE}" = "yes"; then
    echo "dvipdfm -e -p a4 ${if ${PP},-s ${PP}} -o ${2} ${1}" \
  | tr -s  ' ' >> build.sh
  fi
  msg=$$(dvipdfm -e -p a4 ${if ${PP},-s ${PP}} -o ${2} ${1} 2>&1 \
         | sed -n 's|^\(.*\) bytes written|\1|p')
  if test -n "$$msg"
  then echo " done ($$msg bytes)."
  else echo " FAILED."
  fi
endef

# Calling ps2pdf
#   ${1}: PostScript file (source)
#   ${2}: PDF file (target)

define ps2pdf
  if test "${TRACE}" = "yes"; then
    echo "ps2pdf -dSubsetFonts=true -dEmbedAllFonts=true \
         -sPAPERSIZE=a4 ${1} ${2}" \
  | tr -s  ' ' >> build.sh
  fi
  ps2pdf -dSubsetFonts=true -dEmbedAllFonts=true \
         -sPAPERSIZE=a4 ${1} ${2} > /dev/null 2>&1
  size=$$(ls -hAl ${2} | tr -s ' ' | cut -d ' ' -f 5)
  echo " done ($$size bytes)."
endef

# Detecting possible need for a last run of LaTeX

define may_run
  if grep -q "There were undefined references" ${DOC}.log
  then ${call mk_dvi}
  elif grep -q "Rerun to get cross-references right" ${DOC}.log
  then ${call mk_dvi}
  elif grep -q "Citation .* undefined" ${DOC}.log
  then ${call mk_dvi}
  fi
endef

# Calling latex or pdflatex
#   ${1}: Main LaTeX document basename

define common_latex
  if test "${TRACE}" = "yes"; then
    # TO DO: Preserve backslash in the expansion of ${TEX_DEF}
    echo "${1} ${TEX_OPT} ${2}.tex" \
  | tr -s  ' ' >> build.sh
  fi
  ${1} ${TEX_OPT} ${TEX_DEF} ${2}.tex >/dev/null 2>&1
  if test "$$?" = "0"
  then data=$$(sed -n 's|.*\(([0-9].*)\)\.|\1|p' ${2}.log)
       if test -n "$$data"; \
       then echo " done $$data."; \
       else printf " FAILED:\n[W] No pages of output.\n"
       fi
  elif test "${DOC}" = "${2}"
    then printf " FAILED:\nRun [make diag] for diagnostics.\n"
    else printf " FAILED:\nRun [decrypt.sh ${2}.log] for diagnostics.\n"
  fi
endef

# Running LaTeX
#   ${1}: Main LaTeX document basename

define latex
  ${call common_latex,latex,${1},dvi}
endef

# Calling pdflatex
#   ${1}: Main LaTeX document basename

define pdflatex
  ${call common_latex,pdflatex,${1},pdf}
endef

# Sequence mk_dvi is called inside a shell command, so it must be one
# shell command itself.

define mk_dvi
printf "Processing ${DOC}.tex..."
${call latex,${DOC}}
endef

# Merging index and bibliography with the main document

define mrg_idx
printf "Merging the index..."
${call latex,${DOC}}
endef

define mrg_bib
printf "Merging the bibliography..."
${call latex,${DOC}}
endef

# Making figures

# Let an arrow be oriented in the direction of increasing values of
# its label. Then, if we have %%BoundingBox a b c d
#
#              ^
#              |d
#  a   -----------------  c
# --->|                 |--->
#      -----------------
#              ^
#              | b
#

define record_fig
if test -e ${1}
then sed -i.old "/^${1}$$/d" .fig 2> /dev/null
     echo ${1} >> .fig
fi
endef

define mk_fig_dvi
printf "Making figure $@..."
${call latex,$*}
${call record_fig,$@}
echo $*.aux >> .fig
echo $*.log >> .fig
endef

define mk_fig_ps
if test -f $^
then
  printf "Converting $< to EPSF..."
  ${call dvips,-E,$<,$@}
  ${call record_fig,$@}
fi
endef

define eps_of_fig
  printf "Converting $< to EPSF..."
  if test "${TRACE}" = "yes"; then
    echo "fig2dev -L eps $< $@" | tr -s  ' ' >> build.sh
  fi
  fig2dev -L eps $< $@ 2>&1
  if test "$$?" = "0"; then echo " done."
  else echo " FAILED."
  fi
  ${call record_fig,$@}
endef

define convert_to_EPSF
  printf "Converting $< to EPSF..."
  if test "${TRACE}" = "yes"; then
    echo "convert $< $@" | tr -s  ' ' >> build.sh
  fi
  convert $< $@ 2>&1
  if test "$$?" = "0"; then echo " done."
  else echo " FAILED."
  fi
  ${call record_fig,$@}
endef

${DVI_FIG}: %.dvi: %.tex
> ${call mk_fig_dvi}

${PS_FIG}: %.ps: %.dvi
> ${call mk_fig_ps}

%.eps: %.fig
> ${call eps_of_fig}

%.eps: %.jpg
> ${call convert_to_EPSF}

%.eps: %.gif
> ${call convert_to_EPSF}

%.eps: %.png
> ${call convert_to_EPSF}

%.eps: %.pdf
> ${call convert_to_EPSF}

# Basic rules for LaTeX, MakeIndex and BibTeX

${DOC}.dvi0: ${SRC} ${ALL_FIG} \
             ${XML_OK} ${XML_DTD_OK} ${XSLT_OK} \
             ${BEAM} ${OUT_XML} ${OUT_TXT}
> ${call mk_dvi}
> if test -e ${DOC}.dvi; then cp ${DOC}.dvi $@; fi

ifneq (${SRC},)
${SRC}:
endif

define mk_idx
  printf "Collating the index..."
  if test "${TRACE}" = "yes"; then
    echo "makeindex -c -q ${DOC}" | tr -s  ' ' >> build.sh
  fi
  makeindex -c -q ${DOC} 2>&1
  printf " done "
  if test -e ${DOC}.ilg
  then
    stat=$$(sed -n "s|.* \((.* entries accepted, .* rejected\).*|\1|p" \
            ${DOC}.ilg)
    printf "$$stat"
    warn=$$(sed -n 's|.* \(.* warnings).\)|\1|p' ${DOC}.ilg)
    if test -n "$$warn"; then echo ", $$warn"; else echo ")."; fi
  fi
endef

define mk_bbl
printf "Processing bibliography ${BIB:%=%.bib}..."
if test "${TRACE}" = "yes"; then
  echo "bibtex -terse -min-crossrefs=2 ${DOC}" \
| tr -s  ' ' >> build.sh
fi
bibtex -terse -min-crossrefs=2 ${DOC} > /dev/null
printf " done"
entries=$$(sed -nE "s/.*used (.*) (entries|entry).*/\1/p" \
                   ${DOC}.blg 2>/dev/null)
case $$entries in
  "") printf " (0 entry";;
 0|1) printf " ($$entries entry";;
   *) printf " ($$entries entries";;
esac
num_errors=$$(sed -nE "s/.*(was|were) (.*) error.*/\2/p" \
                      ${DOC}.blg 2>/dev/null)
case $$num_errors in
  0|"") ;;
     1) printf ", 1 error";;
     *) printf ", $$num_errors errors";;
esac
num_warnings=$$(grep -c Warning ${DOC}.blg 2>/dev/null)
case $$num_warnings in
  0|"") echo ").";;
     1) echo ", 1 warning).";;
     *) echo ", $$num_warnings warnings).";;
esac
endef

${DOC}.bbl: ${BIB:%=%.bib} ${DOC}.dvi0
> ${call mk_bbl}

# Specific rules, depending on the presence of a bibliography and an
# index

ifeq (${BIB},)
  ifeq (${IDX},yes) # No bib, one index
${DOC}.dvi: sync ${DOC}.dvi0
> ${call mk_idx}
> ${call mrg_idx}
  else # No bib, no index
${DOC}.dvi: ${DOC}.dvi0
  endif
else
  ifeq (${IDX},yes) # One bib, one index
${DOC}.dvi1: ${DOC}.dvi0 ${DOC}.bbl
> ${call mrg_bib}
> if test -e ${DOC}.dvi; then cp ${DOC}.dvi $@; fi
${DOC}.dvi: ${DOC}.dvi1
> ${call mk_idx}
> ${call mrg_idx}
  else # One bib, no index
${DOC}.dvi: ${DOC}.dvi0 ${DOC}.bbl
> ${call mrg_bib}
  endif
endif
ifneq (${FIG},)
> printf "Number of figures: %d.\n" ${words ${FIG}}
endif
> ${call may_run}
> ${call warnings}

# Formats other than DVI
#
# Alternative invocation (with font embedding enabled):
#
# ps2pdf -dPDFSETTINGS=/prepress -dSubsetFonts=true \
#        -dEmbedAllFonts=true \
#        -dMaxSubsetPct=100 -dCompatibilityLevel=1.3 \
#        ${DOC}.ps

${DOC}.ps: ${DOC}.dvi
> printf "Making $@ from $<..."
> ${call dvips,${PAPER} ${ORIENT} ${if ${PP},-pp ${PP}},$<,$@}

ifeq (${USE_PS},yes)
${DOC}.pdf: ${DOC}.ps
> printf "Making $@ from $<..."
> ${call ps2pdf,$<,$@}
else
${DOC}.pdf: ${DOC}.dvi
> printf "Making $@ from $<..."
> ${call dvipdfm,$<,$@}
endif

doc:
> echo ${DOC}

figname:
> echo ${FIG}

fig: ${ALL_FIG}

# Cleaning

clean::
> printf "Cleaning document \"${DOC}\"..."
> rm -f ${DOC}.dvi ${DOC}.dvi0 ${DOC}.dvi1
> rm -f ${DOC}.ps ${DOC}.pdf
> rm -f ${DOC}.log missfont.log texput.log
> rm -f ${DOC}.ind ${DOC}.idx ${DOC}.ilg
> rm -f ${DOC}.bbl ${DOC}.blg ${DOC}.toc
> rm -f ${TEX:%=%.aux} ${DOC}.lof ${DOC}.ent ${DOC}.out
> echo " done."
> if test -e .fig; \
  then \
    cat .fig | while read fig; do rm -f $$fig; done; \
    printf "Cleaning figures..."; \
    rm -f .fig .fig.old; \
    echo " done."; \
  fi

distclean: clean
> printf "Cleaning distribution..."
> rm -fr config.status config.log autom4te.cache configure
> rm -f *~ .*~ \#*\# .\#*
> echo " done."

sinclude Makefile.clean

Makefile.clean:: ;
