#-*-makefile-*-

define ps2pdf
${PRINTF} "Making ${1} from ${2}..."; \
${PS2PDF} -sPAPERSIZE=a4 ${2} ${1} 2>|.${1}.ps2pdf_error; \
if test $$? -eq 0; \
then ${ECHO} " done."; ${RM} -f .${1}.ps2pdf_error; \
else ${ECHO} " FAILED: Check .${1}.ps2pdf_error."; fi
endef

%.pdf: %.ps
	${call ps2pdf,$@,$^}

clean::
	@\rm -f .*.ps2pdf_error
