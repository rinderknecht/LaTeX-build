#-*-makefile-*-

%.P.ps: %.P
	${call a2ps,$@,$^,prolog}
