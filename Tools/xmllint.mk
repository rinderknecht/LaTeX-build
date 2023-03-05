#-*-makefile-*-

define xmllint
${PRINTF} "Validating ${1}..."; \
${XMLLINT} --valid --noout --nonet ${1} 2>|.${1}.xmllint_error; \
if test $$? -eq 0; \
then ${ECHO} " done."; ${RM} -f .${1}.xmllint_error; \
     ${TOUCH} $@; \
else ${ECHO} " FAILED: Check .${1}.xmllint_error."; \
fi
endef

clean::
	@${RM} -f .*.xmllint_error
