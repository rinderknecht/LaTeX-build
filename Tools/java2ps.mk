#-*-makefile-*-

%.java.ps: %.java
	${call a2ps,$@,$^,java}
