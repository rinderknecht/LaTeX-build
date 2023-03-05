#-*-makefile-*-

.PHONY: distclean

distclean::
	@make -Rrs clean
	@if test -e config.cache -o -e config.log -o -e config.status; \
  then \
    ${RM} -fr configure config.log config.status autom4te.cache; \
  fi
	@\rm -f *~ .*~ \#*\# .\#*
