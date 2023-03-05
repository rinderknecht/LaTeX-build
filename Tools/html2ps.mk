#-*-makefile-*-

define html2ps
${PRINTF} "Making ${1} from ${2}..."; \
${HTML2PS} --hyphenate --grayscale --frame \
           --underline --output ${1} ${2} 2>|.${1}.html2ps_error; \
if test $$? -eq 0; \
then ${ECHO} " done."; ${RM} -f .${1}.html2ps_error; \
else ${ECHO} " FAILED: Check .${1}.html2ps_error."; fi
endef

%.html.ps: %.html
	${call html2ps,$@,$<}

clean::
	@\rm -f .*.html2ps_error
