# Use .RECIPEPREFIX = > in main Makefile

define xmllint
printf "Validating ${1}..."; \
${XMLLINT} --valid --noout --nonet ${1} 2>|.${1}.xmllint_error; \
if test $$? -eq 0; \
then echo " done."; \rm -f .${1}.xmllint_error; \
     touch $@; \
else echo " FAILED: Check .${1}.xmllint_error."; \
fi
endef

clean::
> \rm -f .*.xmllint_error
