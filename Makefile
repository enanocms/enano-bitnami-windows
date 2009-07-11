EXPERIENCEUI=/public/exui/Contrib/ExperienceUI
ENANOHG=/var/www/html/enano-1.1/repo

all:
	makensis "-DXPUI_SYSDIR=$(EXPERIENCEUI)" "-DENANO_ROOT=$(ENANOHG)" enano-bundle.nsi
