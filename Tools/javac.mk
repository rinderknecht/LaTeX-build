#-*-makefile-*-

define javac
${PRINTF} "Compiling ${1}.java..."; \
${JAVAC} -Xlint:unchecked -Werror ${1}.java 2>|.${1}.javac_error; \
if test $$? -eq 0; \
then ${ECHO} " done."; ${RM} -f .${1}.javac_error; \
else ${ECHO} " FAILED: Check .${1}.javac_error."; \
fi
endef

clean::
	@\rm -f .*.javac_error *.class
