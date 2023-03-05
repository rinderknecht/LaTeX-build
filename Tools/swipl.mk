#-*-makefile-*-

define swipl
${PRINTF} "Making ${1} from ${2}..."; \
${SWIPL} --quiet -o ${1} -c ${2} 2>| .${1}.swipl_error; \
if test "$$?" -eq "0"; \
then ${ECHO} " done."; ${RM} -f .${1}.swipl_error; \
else ${ECHO} " FAILED: Check .${1}.swipl_error."; \
fi
endef

clean::
	@\rm -f .*.swipl_error
