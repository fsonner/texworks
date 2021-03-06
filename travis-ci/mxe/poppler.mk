# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := poppler
$(PKG)_WEBSITE  := https://poppler.freedesktop.org/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 0.64.0
$(PKG)_CHECKSUM := b21df92ca99f78067785cf2dc8e06deb04726b62389c0ee1f5d8b103c77f64b1
$(PKG)_SUBDIR   := poppler-$($(PKG)_VERSION)
$(PKG)_FILE     := poppler-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://poppler.freedesktop.org/$($(PKG)_FILE)
$(PKG)_DEPS     := cc cairo curl freetype glib jpeg lcms libpng qtbase tiff zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://poppler.freedesktop.org/' | \
    $(SED) -n 's,.*"poppler-\([0-9.]\+\)\.tar\.xz".*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    mkdir -p '$(1)/build'
    cd '$(1)/build' && '$(TARGET)-cmake' .. -DENABLE_XPDF_HEADERS=ON -DENABLE_LIBOPENJPEG='none' -DENABLE_UTILS=OFF -DBUILD_GTK_TESTS=OFF -DBUILD_QT4_TESTS=OFF -DBUILD_QT5_TESTS=OFF -DBUILD_CPP_TESTS=OFF
    $(MAKE) -C '$(1)/build' -j '$(JOBS)' $(MXE_DISABLE_CRUFT) HTML_DIR=
    $(MAKE) -C '$(1)/build' -j 1 install $(MXE_DISABLE_CRUFT) HTML_DIR=

    # Test program
    '$(TARGET)-g++' \
        -W -Wall -Werror -ansi -pedantic \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-poppler.exe' \
        `'$(TARGET)-pkg-config' poppler poppler-cpp --cflags --libs`
endef
