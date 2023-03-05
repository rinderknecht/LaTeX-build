#-*-makefile-*-

.PHONY: parts pdf clean clean-pdf

parts: ${TARGETS}

ifneq (${PDF},)
ARCH_PDF := ${notdir ${CURDIR}}.pdf

${ARCH_PDF}: ${PDF}
	${call gs,$@,$^}

pdf: ${ARCH_PDF}

clean-pdf:
	@\rm -f ${PDF} ${ARCH_PDF}

clean:: clean-pdf
	@\rm -f ${TARGETS}
else
clean::
	@\rm -f ${TARGETS}
endif

include distclean.mk
