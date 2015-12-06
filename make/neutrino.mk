#
# Makefile to build NEUTRINO
#
$(targetprefix)/var/etc/.version:
	echo "imagename=Neutrino" > $@
	echo "homepage=http://gitorious.org/open-duckbox-project-sh4" >> $@
	echo "creator=`id -un`" >> $@
	echo "docs=http://gitorious.org/open-duckbox-project-sh4/pages/Home" >> $@
	echo "forum=http://gitorious.org/open-duckbox-project-sh4" >> $@
	echo "version=0200`date +%Y%m%d%H%M`" >> $@
	echo "git=`git describe`" >> $@

NEUTRINO_DEPS  = bootstrap libcurl libpng libjpeg libgif libfreetype
NEUTRINO_DEPS += ffmpeg lua luaexpat luacurl libdvbsipp libsigc libopenthreads libusb libalsa
NEUTRINO_DEPS += $(EXTERNALLCD_DEP)

if ENABLE_WLANDRIVER
NEUTRINO_DEPS += wpa_supplicant wireless_tools
endif

NEUTRINO_DEPS2 = libid3tag libmad libvorbisidec

N_CFLAGS  = -Wall -W -Wshadow -g0 -pipe -Os -fno-strict-aliasing -DCPU_FREQ -ffunction-sections -fdata-sections

N_CPPFLAGS = -I$(driverdir)/bpamem
N_CPPFLAGS += -I$(targetprefix)/usr/include/
N_CPPFLAGS += -I$(buildprefix)/$(KERNEL_DIR)/include
N_CPPFLAGS += -D__STDC_CONSTANT_MACROS

if BOXTYPE_SPARK
N_CPPFLAGS += -I$(driverdir)/frontcontroller/aotom_spark
endif

if BOXTYPE_SPARK7162
N_CPPFLAGS += -I$(driverdir)/frontcontroller/aotom_spark
endif

N_CONFIG_OPTS = --enable-silent-rules --enable-freesatepg
# --enable-pip

if ENABLE_EXTERNALLCD
N_CONFIG_OPTS += --enable-graphlcd
endif

if ENABLE_MEDIAFWGSTREAMER
N_CONFIG_OPTS += --enable-gstreamer
else
N_CONFIG_OPTS += --enable-libeplayer3
endif

OBJDIR = $(buildtmp)
N_OBJDIR = $(OBJDIR)/neutrino-mp
LH_OBJDIR = $(OBJDIR)/libstb-hal

################################################################################
#
# fs-basis - libstb-hal-cst-next
#
NEUTRINO_MP_LIBSTB_CST_NEXT_PATCHES =

$(D)/libstb-hal-cst-next.do_prepare:
	rm -rf $(sourcedir)/libstb-hal-cst-next
	rm -rf $(sourcedir)/libstb-hal-cst-next.org
	rm -rf $(LH_OBJDIR)
	[ -d "$(archivedir)/libstb-hal-cst-next.git" ] && \
	(cd $(archivedir)/libstb-hal-cst-next.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/libstb-hal-cst-next.git" ] || \
	git clone https://github.com/fs-basis/libstb-hal-cst-next.git $(archivedir)/libstb-hal-cst-next.git; \
	cp -ra $(archivedir)/libstb-hal-cst-next.git $(sourcedir)/libstb-hal-cst-next;\
	cp -ra $(sourcedir)/libstb-hal-cst-next $(sourcedir)/libstb-hal-cst-next.org
	for i in $(NEUTRINO_MP_LIBSTB_CST_NEXT_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		set -e; cd $(sourcedir)/libstb-hal-cst-next && patch -p1 -i $$i; \
	done;
	touch $@

$(D)/libstb-hal-cst-next.config.status: | $(NEUTRINO_DEPS)
	rm -rf $(LH_OBJDIR) && \
	test -d $(LH_OBJDIR) || mkdir -p $(LH_OBJDIR) && \
	cd $(LH_OBJDIR) && \
		$(sourcedir)/libstb-hal-cst-next/autogen.sh && \
		$(BUILDENV) \
		$(sourcedir)/libstb-hal-cst-next/configure \
			--host=$(target) \
			--build=$(build) \
			--prefix= \
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"

$(D)/libstb-hal-cst-next.do_compile: libstb-hal-cst-next.config.status
	cd $(sourcedir)/libstb-hal-cst-next && \
		$(MAKE) -C $(LH_OBJDIR)
	touch $@

$(D)/libstb-hal-cst-next: libstb-hal-cst-next.do_prepare libstb-hal-cst-next.do_compile
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(targetprefix)
	touch $@

libstb-hal-cst-next-clean:
	rm -f $(D)/libstb-hal-cst-next
	cd $(LH_OBJDIR) && \
		$(MAKE) -C $(LH_OBJDIR) distclean

libstb-hal-cst-next-distclean:
	rm -rf $(LH_OBJDIR)
	rm -f $(D)/libstb-hal-cst-next*

################################################################################
#
# neutrino-mp-cst-next
#
yaud-neutrino-mp-cst-next: yaud-none lirc \
		boot-elf neutrino-mp-cst-next release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

yaud-neutrino-mp-cst-next-plugins: yaud-none lirc \
		boot-elf neutrino-mp-cst-next neutrino-mp-plugins release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

NEUTRINO_MP_CST_NEXT_PATCHES =

$(D)/neutrino-mp-cst-next.do_prepare: | $(NEUTRINO_DEPS) libstb-hal-cst-next
	rm -rf $(sourcedir)/neutrino-mp-cst-next
	rm -rf $(sourcedir)/neutrino-mp-cst-next.org
	rm -rf $(N_OBJDIR)
	[ -d "$(archivedir)/neutrino-mp-cst-next.git" ] && \
	(cd $(archivedir)/neutrino-mp-cst-next.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino-mp-cst-next.git" ] || \
	git clone https://github.com/Duckbox-Developers/neutrino-mp-cst-next.git $(archivedir)/neutrino-mp-cst-next.git; \
	cp -ra $(archivedir)/neutrino-mp-cst-next.git $(sourcedir)/neutrino-mp-cst-next; \
	cp -ra $(sourcedir)/neutrino-mp-cst-next $(sourcedir)/neutrino-mp-cst-next.org
	for i in $(NEUTRINO_MP_CST_NEXT_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		set -e; cd $(sourcedir)/neutrino-mp-cst-next && patch -p1 -i $$i; \
	done;
	touch $@

$(D)/neutrino-mp-cst-next.config.status:
	rm -rf $(N_OBJDIR)
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR) && \
	cd $(N_OBJDIR) && \
		$(sourcedir)/neutrino-mp-cst-next/autogen.sh && \
		$(BUILDENV) \
		$(sourcedir)/neutrino-mp-cst-next/configure \
			--build=$(build) \
			--host=$(target) \
			$(N_CONFIG_OPTS) \
			--with-boxtype=$(BOXTYPE) \
			--enable-upnp \
			--enable-ffmpegdec \
			--enable-giflib \
			--with-tremor \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-plugindir=/var/tuxbox/plugins \
			--with-iconsdir=/usr/share/tuxbox/neutrino/icons \
			--with-localedir=/usr/share/tuxbox/neutrino/locale \
			--with-private_httpddir=/usr/share/tuxbox/neutrino/httpd \
			--with-themesdir=/usr/share/tuxbox/neutrino/themes \
			--with-stb-hal-includes=$(sourcedir)/libstb-hal-cst-next/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"

$(sourcedir)/neutrino-mp-cst-next/src/gui/version.h:
	@rm -f $@; \
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(sourcedir)/libstb-hal-cst-next ; then \
		pushd $(sourcedir)/libstb-hal-cst-next ; \
		HAL_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(sourcedir)/neutrino-mp-cst-next ; \
		NMP_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(buildprefix) ; \
		DDT_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'_NMP-rev'$$NMP_REV'"' >> $@ ; \
	fi

$(D)/neutrino-mp-cst-next.do_compile: neutrino-mp-cst-next.config.status $(sourcedir)/neutrino-mp-cst-next/src/gui/version.h
	cd $(sourcedir)/neutrino-mp-cst-next && \
		$(MAKE) -C $(N_OBJDIR) all
	touch $@

$(D)/neutrino-mp-cst-next: neutrino-mp-cst-next.do_prepare neutrino-mp-cst-next.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(targetprefix) && \
	rm -f $(targetprefix)/var/etc/.version
	make $(targetprefix)/var/etc/.version
	$(target)-strip $(targetprefix)/usr/local/bin/neutrino
	$(target)-strip $(targetprefix)/usr/local/bin/pzapit
	$(target)-strip $(targetprefix)/usr/local/bin/sectionsdcontrol
	$(target)-strip $(targetprefix)/usr/local/sbin/udpstreampes
	touch $@

neutrino-mp-cst-next-clean:
	rm -f $(D)/neutrino-mp-cst-next
	rm -f $(sourcedir)/neutrino-mp-cst-next/src/gui/version.h
	cd $(N_OBJDIR) && \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-mp-cst-next-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-mp-cst-next*

################################################################################
#
# yaud-neutrino-mp-next
#
yaud-neutrino-mp-next: yaud-none lirc \
		boot-elf neutrino-mp-next release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

yaud-neutrino-mp-next-plugins: yaud-none lirc \
		boot-elf neutrino-mp-next neutrino-mp-plugins release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

yaud-neutrino-mp-next-all: yaud-none lirc \
		boot-elf neutrino-mp-next neutrino-mp-plugins shairport release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

#
# libstb-hal-next
#
NEUTRINO_MP_LIBSTB_NEXT_PATCHES =

$(D)/libstb-hal-next.do_prepare:
	rm -rf $(sourcedir)/libstb-hal-next
	rm -rf $(sourcedir)/libstb-hal-next.org
	rm -rf $(LH_OBJDIR)
	[ -d "$(archivedir)/libstb-hal-next.git" ] && \
	(cd $(archivedir)/libstb-hal-next.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/libstb-hal-next.git" ] || \
	git clone https://github.com/Duckbox-Developers/libstb-hal-next.git $(archivedir)/libstb-hal-next.git; \
	cp -ra $(archivedir)/libstb-hal-next.git $(sourcedir)/libstb-hal-next;\
	cp -ra $(sourcedir)/libstb-hal-next $(sourcedir)/libstb-hal-next.org
	for i in $(NEUTRINO_MP_LIBSTB_NEXT_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		set -e; cd $(sourcedir)/libstb-hal-next && patch -p1 -i $$i; \
	done;
	touch $@

$(D)/libstb-hal-next.config.status: bootstrap
	rm -rf $(LH_OBJDIR) && \
	test -d $(LH_OBJDIR) || mkdir -p $(LH_OBJDIR) && \
	cd $(LH_OBJDIR) && \
		$(sourcedir)/libstb-hal-next/autogen.sh && \
		$(BUILDENV) \
		$(sourcedir)/libstb-hal-next/configure \
			--host=$(target) \
			--build=$(build) \
			--prefix= \
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CPPFLAGS="$(N_CPPFLAGS)"

$(D)/libstb-hal-next.do_compile: libstb-hal-next.config.status
	cd $(sourcedir)/libstb-hal-next && \
		$(MAKE) -C $(LH_OBJDIR)
	touch $@

$(D)/libstb-hal-next: libstb-hal-next.do_prepare libstb-hal-next.do_compile
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(targetprefix)
	touch $@

libstb-hal-next-clean:
	rm -f $(D)/libstb-hal-next
	cd $(LH_OBJDIR) && \
		$(MAKE) -C $(LH_OBJDIR) distclean

libstb-hal-next-distclean:
	rm -rf $(LH_OBJDIR)
	rm -f $(D)/libstb-hal-next*

#
# neutrino-mp-next
#
NEUTRINO_MP_NEXT_PATCHES =

$(D)/neutrino-mp-next.do_prepare: | $(NEUTRINO_DEPS) libstb-hal-next
	rm -rf $(sourcedir)/neutrino-mp-next
	rm -rf $(sourcedir)/neutrino-mp-next.org
	rm -rf $(N_OBJDIR)
	[ -d "$(archivedir)/neutrino-mp-next.git" ] && \
	(cd $(archivedir)/neutrino-mp-next.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino-mp-next.git" ] || \
	git clone https://github.com/Duckbox-Developers/neutrino-mp-next.git $(archivedir)/neutrino-mp-next.git; \
	cp -ra $(archivedir)/neutrino-mp-next.git $(sourcedir)/neutrino-mp-next; \
	cp -ra $(sourcedir)/neutrino-mp-next $(sourcedir)/neutrino-mp-next.org
	for i in $(NEUTRINO_MP_NEXT_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		set -e; cd $(sourcedir)/neutrino-mp-next && patch -p1 -i $$i; \
	done;
	touch $@

$(D)/neutrino-mp-next.config.status:
	rm -rf $(N_OBJDIR)
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR) && \
	cd $(N_OBJDIR) && \
		$(sourcedir)/neutrino-mp-next/autogen.sh && \
		$(BUILDENV) \
		$(sourcedir)/neutrino-mp-next/configure \
			--build=$(build) \
			--host=$(target) \
			$(N_CONFIG_OPTS) \
			--enable-ffmpegdec \
			--enable-giflib \
			--with-boxtype=$(BOXTYPE) \
			--with-tremor \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-plugindir=/var/tuxbox/plugins \
			--with-stb-hal-includes=$(sourcedir)/libstb-hal-next/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CPPFLAGS="$(N_CPPFLAGS)"

$(sourcedir)/neutrino-mp-next/src/gui/version.h:
	@rm -f $@; \
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(sourcedir)/libstb-hal-next ; then \
		pushd $(sourcedir)/libstb-hal-next ; \
		HAL_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(sourcedir)/neutrino-mp-next ; \
		NMP_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(buildprefix) ; \
		DDT_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'-next_NMP-rev'$$NMP_REV'-next"' >> $@ ; \
	fi


$(D)/neutrino-mp-next.do_compile: neutrino-mp-next.config.status $(sourcedir)/neutrino-mp-next/src/gui/version.h
	cd $(sourcedir)/neutrino-mp-next && \
		$(MAKE) -C $(N_OBJDIR) all
	touch $@

$(D)/neutrino-mp-next: neutrino-mp-next.do_prepare neutrino-mp-next.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(targetprefix) && \
	rm -f $(targetprefix)/var/etc/.version
	make $(targetprefix)/var/etc/.version
	$(target)-strip $(targetprefix)/usr/local/bin/neutrino
	$(target)-strip $(targetprefix)/usr/local/bin/pzapit
	$(target)-strip $(targetprefix)/usr/local/bin/sectionsdcontrol
	$(target)-strip $(targetprefix)/usr/local/sbin/udpstreampes
	touch $@

neutrino-mp-next-clean:
	rm -f $(D)/neutrino-mp-next
	rm -f $(sourcedir)/neutrino-mp-next/src/gui/version.h
	cd $(N_OBJDIR) && \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-mp-next-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-mp-next*

################################################################################
#
# yaud-neutrino-hd2-exp
#
yaud-neutrino-hd2-exp: yaud-none lirc \
		boot-elf neutrino-hd2-exp release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

#
# neutrino-hd2-exp
#
NEUTRINO_HD2_PATCHES =

$(D)/neutrino-hd2-exp.do_prepare: | $(NEUTRINO_DEPS) $(NEUTRINO_DEPS2) $(MEDIAFW_DEP) libflac
	rm -rf $(sourcedir)/nhd2-exp
	rm -rf $(sourcedir)/nhd2-exp.org
	[ -d "$(archivedir)/neutrino-hd2-exp.svn" ] && \
	(cd $(archivedir)/neutrino-hd2-exp.svn; svn up ; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino-hd2-exp.svn" ] || \
	svn co http://neutrinohd2.googlecode.com/svn/branches/nhd2-exp $(archivedir)/neutrino-hd2-exp.svn; \
	cp -ra $(archivedir)/neutrino-hd2-exp.svn $(sourcedir)/nhd2-exp; \
	cp -ra $(sourcedir)/nhd2-exp $(sourcedir)/nhd2-exp.org
	for i in $(NEUTRINO_HD2_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		set -e; cd $(sourcedir)/nhd2-exp && patch -p1 -i $$i; \
	done;
	touch $@

$(sourcedir)/nhd2-exp/config.status:
	cd $(sourcedir)/nhd2-exp && \
		./autogen.sh && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			$(N_CONFIG_OPTS) \
			--with-boxtype=$(BOXTYPE) \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-plugindir=/var/tuxbox/plugins \
			--with-isocodesdir=/usr/share/iso-codes \
			--enable-standaloneplugins \
			--enable-radiotext \
			--enable-upnp \
			--enable-scart \
			--enable-ci \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CPPFLAGS="$(N_CPPFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)"

$(D)/neutrino-hd2-exp: neutrino-hd2-exp.do_prepare neutrino-hd2-exp.do_compile
	$(MAKE) -C $(sourcedir)/nhd2-exp install DESTDIR=$(targetprefix) && \
	rm -f $(targetprefix)/var/etc/.version
	make $(targetprefix)/var/etc/.version
	$(target)-strip $(targetprefix)/usr/local/bin/neutrino
	$(target)-strip $(targetprefix)/usr/local/bin/pzapit
	$(target)-strip $(targetprefix)/usr/local/bin/sectionsdcontrol
	touch $@

$(D)/neutrino-hd2-exp.do_compile: $(sourcedir)/nhd2-exp/config.status
	cd $(sourcedir)/nhd2-exp && \
		$(MAKE) all
	touch $@

neutrino-hd2-exp-clean:
	rm -f $(D)/neutrino-hd2-exp
	cd $(sourcedir)/nhd2-exp && \
		$(MAKE) clean

neutrino-hd2-exp-distclean:
	rm -f $(D)/neutrino-hd2-exp
	rm -f $(D)/neutrino-hd2-exp.do_compile
	rm -f $(D)/neutrino-hd2-exp.do_prepare

################################################################################
#
# yaud-neutrino-mp-tangos
#
yaud-neutrino-mp-tangos: yaud-none lirc \
		boot-elf neutrino-mp-tangos release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

yaud-neutrino-mp-tangos-plugins: yaud-none lirc \
		boot-elf neutrino-mp-tangos neutrino-mp-plugins release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

yaud-neutrino-mp-tangos-all: yaud-none lirc \
		boot-elf neutrino-mp-tangos neutrino-mp-plugins shairport release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

#
# neutrino-mp-tangos
#
NEUTRINO_MP_TANGOS_PATCHES =

$(D)/neutrino-mp-tangos.do_prepare: | $(NEUTRINO_DEPS) libstb-hal-cst-next
	rm -rf $(sourcedir)/neutrino-mp-tangos
	rm -rf $(sourcedir)/neutrino-mp-tangos.org
	rm -rf $(N_OBJDIR)
	[ -d "$(archivedir)/neutrino-mp-tangos.git" ] && \
	(cd $(archivedir)/neutrino-mp-tangos.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino-mp-tangos.git" ] || \
	git clone https://github.com/TangoCash/neutrino-mp-cst-next.git $(archivedir)/neutrino-mp-tangos.git; \
	cp -ra $(archivedir)/neutrino-mp-tangos.git $(sourcedir)/neutrino-mp-tangos; \
	cp -ra $(sourcedir)/neutrino-mp-tangos $(sourcedir)/neutrino-mp-tangos.org
	for i in $(NEUTRINO_MP_TANGOS_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		set -e; cd $(sourcedir)/neutrino-mp-tangos && patch -p1 -i $$i; \
	done;
	touch $@

$(D)/neutrino-mp-tangos.config.status:
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR) && \
	cd $(N_OBJDIR) && \
		$(sourcedir)/neutrino-mp-tangos/autogen.sh && \
		$(BUILDENV) \
		$(sourcedir)/neutrino-mp-tangos/configure \
			--build=$(build) \
			--host=$(target) \
			$(N_CONFIG_OPTS) \
			--disable-upnp \
			--enable-lua \
			--enable-ffmpegdec \
			--enable-giflib \
			--with-boxtype=$(BOXTYPE) \
			--with-tremor \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-plugindir=/var/tuxbox/plugins \
			--with-iconsdir=/usr/share/tuxbox/neutrino/icons \
			--with-localedir=/usr/share/tuxbox/neutrino/locale \
			--with-private_httpddir=/usr/share/tuxbox/neutrino/httpd \
			--with-themesdir=/usr/share/tuxbox/neutrino/themes \
			--with-stb-hal-includes=$(sourcedir)/libstb-hal-cst-next/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CPPFLAGS="$(N_CPPFLAGS)"

$(sourcedir)/neutrino-mp-tangos/src/gui/version.h:
	@rm -f $@; \
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(sourcedir)/libstb-hal-cst-next ; then \
		pushd $(sourcedir)/libstb-hal-cst-next ; \
		HAL_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(sourcedir)/neutrino-mp-tangos ; \
		NMP_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(buildprefix) ; \
		DDT_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'-next_NMP-rev'$$NMP_REV'-tangos"' >> $@ ; \
	fi


$(D)/neutrino-mp-tangos.do_compile: neutrino-mp-tangos.config.status $(sourcedir)/neutrino-mp-tangos/src/gui/version.h
	cd $(sourcedir)/neutrino-mp-tangos && \
		$(MAKE) -C $(N_OBJDIR) all
	touch $@

$(D)/neutrino-mp-tangos: neutrino-mp-tangos.do_prepare neutrino-mp-tangos.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(targetprefix) && \
	rm -f $(targetprefix)/var/etc/.version
	make $(targetprefix)/var/etc/.version
	$(target)-strip $(targetprefix)/usr/local/bin/neutrino
	$(target)-strip $(targetprefix)/usr/local/bin/pzapit
	$(target)-strip $(targetprefix)/usr/local/bin/sectionsdcontrol
	$(target)-strip $(targetprefix)/usr/local/sbin/udpstreampes
	touch $@

neutrino-mp-tangos-clean:
	rm -f $(D)/neutrino-mp-tangos
	rm -f $(sourcedir)/neutrino-mp-tangos/src/gui/version.h
	cd $(N_OBJDIR) && \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-mp-tangos-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-mp-tangos*

################################################################################
#
# yaud-neutrino-test
#
yaud-neutrino-test: yaud-none lirc \
		boot-elf neutrino-test release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

yaud-neutrino-test-plugins: yaud-none lirc \
		boot-elf neutrino-test neutrino-mp-plugins release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

yaud-neutrino-test-xupnpd: yaud-none lirc \
		boot-elf neutrino-test xupnpd release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

#
# fs-basis neutrino-test
#
FS_NEUTRINO_TEST_PATCHES =

$(D)/neutrino-test.do_prepare: | $(NEUTRINO_DEPS) libstb-hal-cst-next
	rm -rf $(sourcedir)/neutrino-test
	rm -rf $(sourcedir)/neutrino-test.org
	rm -rf $(N_OBJDIR)
	[ -d "$(archivedir)/neutrino-test.git" ] && \
	(cd $(archivedir)/neutrino-test.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino-test.git" ] || \
	git clone https://github.com/fs-basis/neutrino-test.git $(archivedir)/neutrino-test.git; \
	cp -ra $(archivedir)/neutrino-test.git $(sourcedir)/neutrino-test; \
	cp -ra $(sourcedir)/neutrino-test $(sourcedir)/neutrino-test.org
	for i in $(FS_NEUTRINO_TEST_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		set -e; cd $(sourcedir)/neutrino-test && patch -p1 -i $$i; \
	done;
	touch $@

$(D)/neutrino-test.config.status:
	rm -rf $(N_OBJDIR)
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR) && \
	cd $(N_OBJDIR) && \
		$(sourcedir)/neutrino-test/autogen.sh && \
		$(BUILDENV) \
		$(sourcedir)/neutrino-test/configure \
			--build=$(build) \
			--host=$(target) \
			$(N_CONFIG_OPTS) \
			--with-boxtype=$(BOXTYPE) \
			--disable-upnp \
			--disable-fastscan \
			--enable-ffmpegdec \
			--enable-giflib \
			--with-tremor \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-plugindir=/var/tuxbox/plugins \
			--with-iconsdir=/usr/share/tuxbox/neutrino/icons \
			--with-localedir=/usr/share/tuxbox/neutrino/locale \
			--with-private_httpddir=/usr/share/tuxbox/neutrino/httpd \
			--with-themesdir=/usr/share/tuxbox/neutrino/themes \
			--with-stb-hal-includes=$(sourcedir)/libstb-hal-cst-next/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"

$(sourcedir)/neutrino-test/src/gui/version.h:
	@rm -f $@; \
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(sourcedir)/libstb-hal-cst-next ; then \
		pushd $(sourcedir)/libstb-hal-cst-next ; \
		HAL_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(sourcedir)/neutrino-test ; \
		NMP_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(buildprefix) ; \
		DDT_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		echo '#define VCS "FS_BASE-rev'$$DDT_REV'_HAL-github-rev'$$HAL_REV'_FS-Neutrino-test-rev'$$NMP_REV'"' >> $@ ; \
	fi

$(D)/neutrino-test.do_compile: neutrino-test.config.status $(sourcedir)/neutrino-test/src/gui/version.h
	cd $(sourcedir)/neutrino-test && \
		$(MAKE) -C $(N_OBJDIR) all
	touch $@

$(D)/neutrino-test: neutrino-test.do_prepare neutrino-test.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(targetprefix) && \
	rm -f $(targetprefix)/var/etc/.version
	make $(targetprefix)/var/etc/.version
	$(target)-strip $(targetprefix)/usr/local/bin/neutrino
	$(target)-strip $(targetprefix)/usr/local/bin/pzapit
	$(target)-strip $(targetprefix)/usr/local/bin/sectionsdcontrol
	$(target)-strip $(targetprefix)/usr/local/sbin/udpstreampes
	touch $@

neutrino-test-clean:
	rm -f $(D)/neutrino-test
	rm -f $(sourcedir)/neutrino-test/src/gui/version.h
	cd $(N_OBJDIR) && \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-test-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-test*

################################################################################
#
# yaud-neutrino
#
yaud-neutrino: yaud-none lirc \
		boot-elf neutrino release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

yaud-neutrino-plugins: yaud-none lirc \
		boot-elf neutrino neutrino-mp-plugins release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

yaud-neutrino-xupnpd: yaud-none lirc \
		boot-elf neutrino xupnpd release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

#
# fs-basis neutrino
#
FS_NEUTRINO_PATCHES =

$(D)/neutrino.do_prepare: | $(NEUTRINO_DEPS) libstb-hal-cst-next
	rm -rf $(sourcedir)/neutrino
	rm -rf $(sourcedir)/neutrino.org
	rm -rf $(N_OBJDIR)
	[ -d "$(archivedir)/neutrino.git" ] && \
	(cd $(archivedir)/neutrino.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino.git" ] || \
	git clone https://github.com/fs-basis/neutrino.git $(archivedir)/neutrino.git; \
	cp -ra $(archivedir)/neutrino.git $(sourcedir)/neutrino; \
	cp -ra $(sourcedir)/neutrino $(sourcedir)/neutrino.org
	for i in $(FS_NEUTRINO_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		set -e; cd $(sourcedir)/neutrino && patch -p1 -i $$i; \
	done;
	touch $@

$(D)/neutrino.config.status:
	rm -rf $(N_OBJDIR)
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR) && \
	cd $(N_OBJDIR) && \
		$(sourcedir)/neutrino/autogen.sh && \
		$(BUILDENV) \
		$(sourcedir)/neutrino/configure \
			--build=$(build) \
			--host=$(target) \
			$(N_CONFIG_OPTS) \
			--with-boxtype=$(BOXTYPE) \
			--disable-upnp \
			--disable-fastscan \
			--enable-ffmpegdec \
			--enable-giflib \
			--with-tremor \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-plugindir=/var/tuxbox/plugins \
			--with-iconsdir=/usr/share/tuxbox/neutrino/icons \
			--with-localedir=/usr/share/tuxbox/neutrino/locale \
			--with-private_httpddir=/usr/share/tuxbox/neutrino/httpd \
			--with-themesdir=/usr/share/tuxbox/neutrino/themes \
			--with-stb-hal-includes=$(sourcedir)/libstb-hal-cst-next/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"

$(sourcedir)/neutrino/src/gui/version.h:
	@rm -f $@; \
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(sourcedir)/libstb-hal-cst-next ; then \
		pushd $(sourcedir)/libstb-hal-cst-next ; \
		HAL_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(sourcedir)/neutrino ; \
		NMP_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(buildprefix) ; \
		DDT_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		echo '#define VCS "FS_BASE-rev'$$DDT_REV'_HAL-github-rev'$$HAL_REV'_FS-Neutrino-rev'$$NMP_REV'"' >> $@ ; \
	fi

$(D)/neutrino.do_compile: neutrino.config.status $(sourcedir)/neutrino/src/gui/version.h
	cd $(sourcedir)/neutrino && \
		$(MAKE) -C $(N_OBJDIR) all
	touch $@

$(D)/neutrino: neutrino.do_prepare neutrino.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(targetprefix) && \
	rm -f $(targetprefix)/var/etc/.version
	make $(targetprefix)/var/etc/.version
	$(target)-strip $(targetprefix)/usr/local/bin/neutrino
	$(target)-strip $(targetprefix)/usr/local/bin/pzapit
	$(target)-strip $(targetprefix)/usr/local/bin/sectionsdcontrol
	$(target)-strip $(targetprefix)/usr/local/sbin/udpstreampes
	touch $@

neutrino-clean:
	rm -f $(D)/neutrino
	rm -f $(sourcedir)/neutrino/src/gui/version.h
	cd $(N_OBJDIR) && \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino*

################################################################################
#
# yaud-neutrino-old
#
yaud-neutrino-old: yaud-none lirc \
		boot-elf neutrino-old release_neutrino-old
	@TUXBOX_YAUD_CUSTOMIZE@

yaud-neutrino-old-plugins: yaud-none lirc \
		boot-elf neutrino-old neutrino-old-mp-plugins release_neutrino-old
	@TUXBOX_YAUD_CUSTOMIZE@

yaud-neutrino-old-xupnpd: yaud-none lirc \
		boot-elf neutrino-old xupnpd release_neutrino-old
	@TUXBOX_YAUD_CUSTOMIZE@

#
# fs-basis neutrino-old
#
FS_NEUTRINO_OLD_PATCHES =

$(D)/neutrino-old.do_prepare: | $(neutrino-old_DEPS) libstb-hal-cst-next
	rm -rf $(sourcedir)/neutrino-old
	rm -rf $(sourcedir)/neutrino-old.org
	rm -rf $(N_OBJDIR)
	[ -d "$(archivedir)/neutrino-old.git" ] && \
	(cd $(archivedir)/neutrino-old.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino-old.git" ] || \
	git clone https://github.com/fs-basis/neutrino-old.git $(archivedir)/neutrino-old.git; \
	cp -ra $(archivedir)/neutrino-old.git $(sourcedir)/neutrino-old; \
	cp -ra $(sourcedir)/neutrino-old $(sourcedir)/neutrino-old.org
	for i in $(FS_NEUTRINO_OLD_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		set -e; cd $(sourcedir)/neutrino-old && patch -p1 -i $$i; \
	done;
	touch $@

$(D)/neutrino-old.config.status:
	rm -rf $(N_OBJDIR)
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR) && \
	cd $(N_OBJDIR) && \
		$(sourcedir)/neutrino-old/autogen.sh && \
		$(BUILDENV) \
		$(sourcedir)/neutrino-old/configure \
			--build=$(build) \
			--host=$(target) \
			$(N_CONFIG_OPTS) \
			--with-boxtype=$(BOXTYPE) \
			--disable-upnp \
			--disable-fastscan \
			--enable-ffmpegdec \
			--enable-giflib \
			--with-tremor \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-plugindir=/var/tuxbox/plugins \
			--with-iconsdir=/usr/share/tuxbox/neutrino-old/icons \
			--with-localedir=/usr/share/tuxbox/neutrino-old/locale \
			--with-private_httpddir=/usr/share/tuxbox/neutrino-old/httpd \
			--with-themesdir=/usr/share/tuxbox/neutrino-old/themes \
			--with-stb-hal-includes=$(sourcedir)/libstb-hal-cst-next/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"

$(sourcedir)/neutrino-old/src/gui/version.h:
	@rm -f $@; \
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(sourcedir)/libstb-hal-cst-next ; then \
		pushd $(sourcedir)/libstb-hal-cst-next ; \
		HAL_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(sourcedir)/neutrino-old ; \
		NMP_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(buildprefix) ; \
		DDT_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		echo '#define VCS "FS_BASE-rev'$$DDT_REV'_HAL-github-rev'$$HAL_REV'_FS-Neutrino-old-rev'$$NMP_REV'"' >> $@ ; \
	fi

$(D)/neutrino-old.do_compile: neutrino-old.config.status $(sourcedir)/neutrino-old/src/gui/version.h
	cd $(sourcedir)/neutrino-old && \
		$(MAKE) -C $(N_OBJDIR) all
	touch $@

$(D)/neutrino-old: neutrino-old.do_prepare neutrino-old.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(targetprefix) && \
	rm -f $(targetprefix)/var/etc/.version
	make $(targetprefix)/var/etc/.version
	$(target)-strip $(targetprefix)/usr/local/bin/neutrino-old
	$(target)-strip $(targetprefix)/usr/local/bin/pzapit
	$(target)-strip $(targetprefix)/usr/local/bin/sectionsdcontrol
	$(target)-strip $(targetprefix)/usr/local/sbin/udpstreampes
	touch $@

neutrino-old-clean:
	rm -f $(D)/neutrino-old
	rm -f $(sourcedir)/neutrino-old/src/gui/version.h
	cd $(N_OBJDIR) && \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-old-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-old*

################################################################################
