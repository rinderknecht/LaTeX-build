#-*-makefile-*-

%.sh.ps: %.sh
	${call a2ps,$@,$^,sh}
