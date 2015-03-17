#
# Makefile to build NEUTRINO-PLUGINS
#
#
#
# PLUGINS
#
$(D)/neutrino-mp-plugins.do_prepare:
	rm -rf $(sourcedir)/neutrino-mp-plugins
	rm -rf $(sourcedir)/neutrino-mp-plugins.org
	[ -d "$(archivedir)/neutrino-mp-plugins.git" ] && \
	(cd $(archivedir)/neutrino-mp-plugins.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino-mp-plugins.git" ] || \
	git clone https://github.com/Duckbox-Developers/neutrino-mp-plugins.git $(archivedir)/neutrino-mp-plugins.git; \
	cp -ra $(archivedir)/neutrino-mp-plugins.git $(sourcedir)/neutrino-mp-plugins;\
	cp -ra $(sourcedir)/neutrino-mp-plugins $(sourcedir)/neutrino-mp-plugins.org
	touch $@

$(sourcedir)/neutrino-mp-plugins/config.status: $(D)/bootstrap $(D)/xupnpd
	cd $(sourcedir)/neutrino-mp-plugins && \
		./autogen.sh && \
		$(BUILDENV) \
		./configure \
			--host=$(target) \
			--build=$(build) \
			--prefix= \
			--with-target=cdk \
			--oldinclude=$(targetprefix)/include \
			--enable-maintainer-mode \
			--enable-giflib \
			--with-boxtype=$(BOXTYPE) \
			--with-plugindir=/var/tuxbox/plugins \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CPPFLAGS="$(N_CPPFLAGS) -DMARTII -DNEW_LIBCURL" \
			LDFLAGS="$(TARGET_LDFLAGS) -L$(sourcedir)/neutrino-mp-plugins/fx2/lib/.libs"

$(D)/neutrino-mp-plugins.do_compile: $(sourcedir)/neutrino-mp-plugins/config.status
	cd $(sourcedir)/neutrino-mp-plugins && \
		$(MAKE)
	touch $@

$(D)/neutrino-mp-plugins: neutrino-mp-plugins.do_prepare neutrino-mp-plugins.do_compile
	$(MAKE) -C $(sourcedir)/neutrino-mp-plugins install DESTDIR=$(targetprefix)
	touch $@

neutrino-mp-plugins-clean:
	rm -f $(D)/neutrino-mp-plugins
	cd $(sourcedir)/neutrino-mp-plugins && \
		$(MAKE) clean

neutrino-mp-plugins-distclean:
	rm -f $(D)/neutrino-mp-plugins*

#
# NHD2 plugins
#
yaud-neutrino-hd2-exp-plugins: yaud-none lirc \
		boot-elf neutrino-hd2-exp neutrino-mp-plugins release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

NEUTRINO_HD2_PLUGINS_PATCHES =

$(D)/nhd2-plugins.do_prepare:
	rm -rf $(sourcedir)/nhd2-plugins
	rm -rf $(sourcedir)/nhd2-plugins.org
	(cd $(archivedir)/neutrino-hd2-exp.git; git pull ; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino-hd2-exp.git" ] || \
	git clone https://github.com/mohousch/neutrinohd2.git $(archivedir)/neutrino-hd2-exp.git; \
	cp -ra $(archivedir)/neutrino-hd2-exp.git $(sourcedir)/nhd2-plugins; \
	(cd $(sourcedir)/nhd2-plugins; git checkout plugins; cd "$(buildprefix)";); \
	cp -ra $(sourcedir)/nhd2-plugins $(sourcedir)/nhd2-plugins.org
	for i in $(NEUTRINO_HD2_PLUGINS_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(sourcedir)/nhd2-plugins && patch -p1 -i $$i; \
	done;
	touch $@

$(sourcedir)/nhd2-plugins/config.status: bootstrap
	cd $(sourcedir)/nhd2-plugins && \
		./autogen.sh && \
		$(BUILDENV) \
		./configure \
			--host=$(target) \
			--build=$(build) \
			--prefix= \
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			--with-plugindir=/var/tuxbox/plugins \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CPPFLAGS="$(CPPFLAGS) -I$(driverdir) -I$(buildprefix)/$(KERNEL_DIR)/include -I$(targetprefix)/include" \
			LDFLAGS="$(TARGET_LDFLAGS)"

$(D)/nhd2-plugins.do_compile: $(sourcedir)/nhd2-plugins/config.status
	cd $(sourcedir)/nhd2-plugins && \
	$(MAKE)
	touch $@

$(D)/nhd2-plugins: nhd2-plugins.do_prepare nhd2-plugins.do_compile
	rm -rf $(targetprefix)/var/tuxbox/plugins/*
	$(MAKE) -C $(sourcedir)/nhd2-plugins install DESTDIR=$(targetprefix)
#	touch $@

nhd2-plugins-clean:
	rm -f $(D)/nhd2-plugins
	cd $(sourcedir)/nhd2-plugins && \
	$(MAKE) clean
	rm -f $(sourcedir)/nhd2-plugins/config.status

nhd2-plugins-distclean:
	rm -f $(D)/nhd2-plugins*

