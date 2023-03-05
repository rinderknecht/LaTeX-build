#-*-makefile-*-

%.c.ps: %.c
	${call a2ps,$@,$^,gnuc}
