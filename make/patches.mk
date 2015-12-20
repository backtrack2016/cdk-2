#
# diff helper
#
enigma2-nightly-patch \
neutrino-test-patch \
neutrino-old-patch \
libstb-hal-cst-next-patch :
	cd $(sourcedir) && diff -Nur --exclude-from=$(buildprefix)/scripts/diff-exclude $(subst -patch,,$@).org $(subst -patch,,$@) > $(cvsdir)/$@ ; [ $$? -eq 1 ]

# keeping all patches together in one file
# uncomment if needed
#
# libst-hal-cst-next
LIBSTB_HAL_CST_NEXT_PATCHES +=

# fs-basis neutrino-test
FS_NEUTRINO_TEST_PATCHES +=

# fs-basis neutrino-old
FS_NEUTRINO_OLD_PATCHES +=
