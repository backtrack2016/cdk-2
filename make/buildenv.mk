#
# Python Version
#
PYTHON_VERSION = $(word 1,$(subst ., ,$(VERSION_python))).$(word 2,$(subst ., ,$(VERSION_python)))
PYTHON_DIR = /usr/lib/python$(PYTHON_VERSION)
PYTHON_INCLUDE_DIR = /usr/include/python$(PYTHON_VERSION)

#
#
#
PATH := $(hostprefix)/bin:$(crossprefix)/bin:$(PATH):/sbin:/usr/sbin:/usr/local/sbin

#PKG_CONFIG = $(hostprefix)/bin/$(target)-pkg-config
#PKG_CONFIG_LIBDIR = $(targetprefix)/usr/lib
#PKG_CONFIG_PATH = $(PKG_CONFIG_LIBDIR)/pkgconfig

PATCHES         = $(buildprefix)/Patches
#TARGETLIB       = $(targetprefix)/usr/lib
#REWRITE_LIBDIR  = sed -i "s,^libdir=.*,libdir='$(TARGETLIB)'," $(TARGETLIB)
#REWRITE_LIBDEP  = sed -i -e "s,\(^dependency_libs='\| \|-L\|^dependency_libs='\)/usr/lib,\$(TARGETLIB)," $(TARGETLIB)
#REWRITE_PKGCONF = sed -i "s,^prefix=.*,prefix=$(targetprefix)/usr,"

#
#
#
export RM=$(shell which rm) -f
INSTALL_DIR=$(INSTALL) -d
INSTALL_BIN=$(INSTALL) -m 755
INSTALL_FILE=$(INSTALL) -m 644
LN_SF=$(shell which ln) -sf
CP_D=$(shell which cp) -d
CP_P=$(shell which cp) -p
CP_RD=$(shell which cp) -rd
SED=$(shell which sed)
ADAPTED_ETC_FILES =
ETC_RW_FILES =
SOCKSIFY=
WGET=$(SOCKSIFY) wget --progress=bar

#
#
#
BUILDENV := \
	unset CONFIG_SITE && \
	CC=$(target)-gcc \
	CXX=$(target)-g++ \
	LD=$(target)-ld \
	NM=$(target)-nm \
	AR=$(target)-ar \
	AS=$(target)-as \
	RANLIB=$(target)-ranlib \
	STRIP=$(target)-strip \
	OBJCOPY=$(target)-objcopy \
	OBJDUMP=$(target)-objdump \
	LN_S="ln -s" \
	CFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CFLAGS)" \
	CXXFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	PKG_CONFIG_PATH="$(targetprefix)/usr/lib/pkgconfig"

BUILDENV_ALSA := \
	unset CONFIG_SITE && \
	CC=$(target)-gcc \
	CXX=$(target)-g++ \
	LD=$(target)-ld \
	NM=$(target)-nm \
	AR=$(target)-ar \
	AS=$(target)-as \
	RANLIB=$(target)-ranlib \
	STRIP=$(target)-strip \
	OBJCOPY=$(target)-objcopy \
	OBJDUMP=$(target)-objdump \
	LN_S="ln -s" \
	CFLAGS="-pipe -Os -I$(targetprefix)/usr/include" \
	CPPFLAGS="-pipe -Os -I$(targetprefix)/usr/include" \
	CXXFLAGS="-pipe -Os -I$(targetprefix)/usr/include" \
	LDFLAGS="-Wl,-rpath -Wl,/usr/lib -Wl,-rpath-link -Wl,$(targetprefix)/usr/lib -L$(targetprefix)/usr/lib -L$(targetprefix)/lib" \
	PKG_CONFIG_PATH="$(targetprefix)/usr/lib/pkgconfig"

CONFIGURE_ALSA = \
   test -f ./configure || ./autogen.sh && \
   $(BUILDENV_ALSA) \
   ./configure $(CONFIGURE_OPTS)

CONFIGURE_OPTS = \
	--build=$(build) --host=$(target)

CONFIGURE = \
	test -f ./configure || ./autogen.sh && \
	$(BUILDENV) \
	./configure $(CONFIGURE_OPTS)


MAKE_OPTS := \
	CC=$(target)-gcc \
	CXX=$(target)-g++ \
	LD=$(target)-ld \
	NM=$(target)-nm \
	AR=$(target)-ar \
	AS=$(target)-as \
	RANLIB=$(target)-ranlib \
	STRIP=$(target)-strip \
	OBJCOPY=$(target)-objcopy \
	OBJDUMP=$(target)-objdump \
	LN_S="ln -s" \
	ARCH=sh \
	CROSS_COMPILE=$(target)-

PLATFORM_CPPFLAGS := \
	$(if $(UFS910),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_UFS910 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(UFS912),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_UFS912 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(UFS913),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_UFS913 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(UFS922),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_UFS922 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(UFC960),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_UFC960 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(FORTIS_HDBOX),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_FORTIS_HDBOX -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(ATEVIO7500),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_ATEVIO7500 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(OCTAGON1008),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_OCTAGON1008 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(HS7110),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_HS7110 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(HS7810A),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_HS7810A -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(HS7119),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_HS7119 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(HS7819),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_HS7819 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(ATEMIO520),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_ATEMIO520 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(ATEMIO530),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_ATEMIO530 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(TF7700),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_TF7700 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include" --enable-tf7700) \
	$(if $(HL101),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_HL101 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include" --enable-hl101) \
	$(if $(VIP1_V2),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_VIP1_V2 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include" --enable-vip1_v2) \
	$(if $(VIP2_V1),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_VIP2_V1 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include" --enable-vip2_v1) \
	$(if $(SPARK),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_SPARK -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(SPARK7162),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_SPARK7162 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(ADB_BOX),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_ADB_BOX -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include" --enable-adb_box) \
	$(if $(CUBEREVO),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_CUBEREVO -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include" --enable-cuberevo) \
	$(if $(CUBEREVO_MINI),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_CUBEREVO_MINI -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include" --enable-cuberevo) \
	$(if $(CUBEREVO_MINI2),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_CUBEREVO_MINI2 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include" --enable-cuberevo) \
	$(if $(CUBEREVO_MINI_FTA),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_CUBEREVO_MINI_FTA -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include" --enable-cuberevo) \
	$(if $(CUBEREVO_250HD),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_CUBEREVO_250HD -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include" --enable-cuberevo) \
	$(if $(CUBEREVO_2000HD),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_CUBEREVO_2000HD -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include" --enable-cuberevo) \
	$(if $(CUBEREVO_9500HD),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_CUBEREVO_9500HD -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include" --enable-cuberevo) \
	$(if $(IPBOX9900),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_IPBOX9900 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(IPBOX99),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_IPBOX99 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(IPBOX55),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_IPBOX55 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(VITAMIN_HD5000),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_VITAMIN_HD5000 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(SAGEMCOM88),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_SAGEMCOM88 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(ARIVALINK200),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_ARIVALINK200 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include") \
	$(if $(FORTIS_DP7000),CPPFLAGS="$(CPPFLAGS) -DPLATFORM_FORTIS_DP7000 -I$(driverdir)/include -I $(buildprefix)/$(KERNEL_DIR)/include")

DRIVER_PLATFORM := \
	$(if $(UFS910),UFS910=$(UFS910)) \
	$(if $(UFS912),UFS912=$(UFS912)) \
	$(if $(UFS913),UFS913=$(UFS913)) \
	$(if $(UFS922),UFS922=$(UFS922)) \
	$(if $(UFC960),UFC960=$(UFC960)) \
	$(if $(FORTIS_HDBOX),FORTIS_HDBOX=$(FORTIS_HDBOX)) \
	$(if $(ATEVIO7500),ATEVIO7500=$(ATEVIO7500)) \
	$(if $(OCTAGON1008),OCTAGON1008=$(OCTAGON1008)) \
	$(if $(HS7110),HS7110=$(HS7110)) \
	$(if $(HS7810A),HS7810A=$(HS7810A)) \
	$(if $(HS7119),HS7119=$(HS7119)) \
	$(if $(HS7819),HS7810A=$(HS7819)) \
	$(if $(ATEMIO520),ATEMIO520=$(ATEMIO520)) \
	$(if $(ATEMIO530),ATEMIO530=$(ATEMIO530)) \
	$(if $(TF7700),TF7700=$(TF7700)) \
	$(if $(HL101),HL101=$(HL101)) \
	$(if $(VIP1_V2),VIP1_V2=$(VIP1_V2)) \
	$(if $(VIP2_V1),VIP2_V1=$(VIP2_V1)) \
	$(if $(SPARK),SPARK=$(SPARK)) \
	$(if $(SPARK7162),SPARK7162=$(SPARK7162)) \
	$(if $(ADB_BOX),ADB_BOX=$(ADB_BOX)) \
	$(if $(CUBEREVO),CUBEREVO=$(CUBEREVO)) \
	$(if $(CUBEREVO_MINI),CUBEREVO_MINI=$(CUBEREVO_MINI)) \
	$(if $(CUBEREVO_MINI2),CUBEREVO_MINI2=$(CUBEREVO_MINI2)) \
	$(if $(CUBEREVO_MINI_FTA),CUBEREVO_MINI_FTA=$(CUBEREVO_MINI_FTA)) \
	$(if $(CUBEREVO_250HD),CUBEREVO_250HD=$(CUBEREVO_250HD)) \
	$(if $(CUBEREVO_2000HD),CUBEREVO_2000HD=$(CUBEREVO_2000HD)) \
	$(if $(CUBEREVO_9500HD),CUBEREVO_9500HD=$(CUBEREVO_9500HD)) \
	$(if $(HOMECAST5101),HOMECAST5101=$(HOMECAST5101)) \
	$(if $(IPBOX9900),IPBOX9900=$(IPBOX9900)) \
	$(if $(IPBOX99),IPBOX99=$(IPBOX99)) \
	$(if $(IPBOX55),IPBOX55=$(IPBOX55)) \
	$(if $(VITAMIN_HD5000),VITAMIN_HD5000=$(VITAMIN_HD5000)) \
	$(if $(SAGEMCOM88),SAGEMCOM88=$(SAGEMCOM88)) \
	$(if $(ARIVALINK200),ARIVALINK200=$(ARIVALINK200)) \
	$(if $(FORTIS_DP7000),FORTIS_DP7000=$(FORTIS_DP7000)) \
	$(if $(WLANDRIVER),WLANDRIVER=$(WLANDRIVER)) \
	$(if $(PLAYER191),PLAYER191=$(PLAYER191))

D      = .deps
# backwards compatibility
DEPDIR = $(D)

VPATH  = $(D)

ACLOCAL_AMFLAGS = -I .

CONFIG_STATUS_DEPENDENCIES = \
	$(top_srcdir)/rules.pl \
	$(top_srcdir)/rules-install \
	$(top_srcdir)/rules-make \
	Makefile-archive
