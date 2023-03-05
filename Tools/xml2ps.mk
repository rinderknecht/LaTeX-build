%.xsl.ps: %.xsl
	${call a2ps,$@,$^,plain}

%.xml.ps: %.xml
	${call a2ps,$@,$^,plain}

%.dtd.ps: %.dtd
	${call a2ps,$@,$^,plain}

