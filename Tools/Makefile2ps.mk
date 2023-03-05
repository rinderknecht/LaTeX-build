#-*-makefile-*-

.INTERMEDIATE: Makefile.ps

Makefile.ps: Makefile
	${call a2ps,$@,$^,gmake}
