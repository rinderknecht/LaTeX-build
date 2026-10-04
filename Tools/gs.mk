# Use .RECIPEPREFIX = > in main Makefile

define gs
printf "Catenating all the PDFs into ${1}..."; \
${GS} -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite \
      -sOutputFile=${1} ${2} 2>.${1}.gs_error; \
if test $$? -eq 0; \
then echo " done."; \rm -f .${1}.gs_error; \
else echo " FAILED: Check .${1}.gs_error."; fi
endef
