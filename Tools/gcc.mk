# Use .RECIPEPREFIX = > in main Makefile

define gcc
printf "Making ${1} from ${2}..."; \
${GCC} -std=c99 -Werror -pedantic-errors -o ${1} ${2} 2>|.${1}.gcc_error; \
if test $$? -eq 0; \
then echo " done."; \rm -f .${1}.gcc_error; \
else echo " FAILED: Check .${1}.gcc_error."; fi
endef

clean::
> @\rm -f .*.gcc_error
