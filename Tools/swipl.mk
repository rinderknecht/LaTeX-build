# Use .RECIPEPREFIX = > in main Makefile

define swipl
printf "Making ${1} from ${2}..."; \
${SWIPL} --quiet -o ${1} -c ${2} 2>| .${1}.swipl_error; \
if test "$$?" -eq "0"; \
then echo " done."; rm -f .${1}.swipl_error; \
else echo " FAILED: Check .${1}.swipl_error."; \
fi
endef

clean::
> @\rm -f .*.swipl_error
