#-*-makefile-*-

define erlc
${PRINTF} "Making ${1} from ${2}..."; \
${ERLC} -Wall -o ${1} ${2} 2>|.$$(basename ${2} .erl).erlc_error 1>&2; \
if test $$? -eq 0; \
then ${ECHO} " done."; ${RM} -f .$$(basename ${2} .erl).erlc_error; \
else ${ECHO} " FAILED: Check .$$(basename ${2} .erl).erlc_error."; fi
endef

clean::
	@\rm -f .*.erlc_error *.beam
