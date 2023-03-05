#-*-makefile-*-

define gcc
${PRINTF} "Making ${1} from ${2}..."; \
${GCC} -std=c99 -Werror -pedantic-errors -o ${1} ${2} 2>|.${1}.gcc_error; \
if test $$? -eq 0; \
then ${ECHO} " done."; ${RM} -f .${1}.gcc_error; \
else ${ECHO} " FAILED: Check .${1}.gcc_error."; fi
endef

clean::
	@\rm -f .*.gcc_error
