#-*-makefile-*-

define gs
${PRINTF} "Catenating all the PDFs into ${1}..."; \
${GS} -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite \
      -sOutputFile=${1} ${2} 2>.${1}.gs_error; \
if test $$? -eq 0; \
then ${ECHO} " done."; ${RM} -f .${1}.gs_error; \
else ${ECHO} " FAILED: Check .${1}.gs_error."; fi
endef
