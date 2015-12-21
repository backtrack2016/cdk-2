#
# diff helper
#
enigma2-nightly-patch \
neutrino-mp-cst-next-patch \
neutrino-alpha-patch \
neutrino-old-patch \
neutrino-test-patch \
libstb-hal-cst-next-patch :
	cd $(sourcedir) && diff -Nur --exclude-from=$(buildprefix)/scripts/diff-exclude $(subst -patch,,$@).org $(subst -patch,,$@) > $(cvsdir)/$@ ; [ $$? -eq 1 ]

# keeping all patches together in one file
# uncomment if needed
#
# libst-hal-cst-next
LIBSTB_HAL_CST_NEXT_PATCHES +=

# fs-basis neutrino-mp-cst-next
NEUTRINO_MP_CST_NEXT_PATCHES +=

# fs-basis neutrino-alpha
FS_NEUTRINO_ALPHA_PATCHES +=

# fs-basis neutrino-old
FS_NEUTRINO_OLD_PATCHES +=

# fs-basis neutrino-test
FS_NEUTRINO_TEST_PATCHES +=
