EXPERIENCEUI=/public/exui/Contrib/ExperienceUI
ENANOHG=/var/www/html/enano-1.1/repo
# ONLY use n.n.n here! Leave prefixes like -hg for ENANO_VERSION_APPEND.
ENANO_VERSION=1.1.7
ENANO_VERSION_APPEND=

all:
	makensis "-DXPUI_SYSDIR=$(EXPERIENCEUI)" "-DENANO_ROOT=$(ENANOHG)" "-DPRODUCT_VERSION=$(ENANO_VERSION)" \
                 "-DPRODUCT_VERSION_APPEND=$(ENANO_VERSION_APPEND)" enano-bundle.nsi
