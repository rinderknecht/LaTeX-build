# Use .RECIPEPREFIX = > in main Makefile

define saxon
printf "Making ${1} from ${2} and ${3}..."; \
${JAVA} -jar ${SAXON} -o:${1} ${2} ${3} 2>|.${1}.saxon_error; \
if test $$? -eq 0; \
then echo " done."; \rm -f .${1}.saxon_error; \
else echo " FAILED: Check .${1}.saxon_error."; fi
endef

clean::
> @\rm -f .*.saxon_error
