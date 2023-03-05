#-*-makefile-*-

define a2ps
${PRINTF} "Making ${1} from ${2}..."; \
${A2PS} --portrait --pretty-print=${3} --tabsize=4 --medium=A4 \
     --borders=no --font-size=10 --columns=1 \
     ${2} --output=${1} 2>|.${1}.a2ps_error; \
if test $$? -eq 0; \
then ${ECHO} " done."; ${RM} -f .${1}.a2ps_error; \
else ${ECHO} " FAILED: Check .${1}.a2ps_error."; fi
endef

%.ps: %
	${call a2ps,$@,$^,plain}

clean::
	@\rm -f .*.a2ps_error
