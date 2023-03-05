#-*-makefile-*-

%.erl.ps: %.sh
	${call a2ps,$@,$^,plain}
