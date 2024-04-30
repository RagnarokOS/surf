# surf version
VERSION = 2.1

# Customize below to fit your system
PKG_CONFIG ?= pkg-config

# paths
PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man
LIBPREFIX = $(PREFIX)/lib
LIBDIR = $(LIBPREFIX)/surf

X11INC = $(shell $(PKG_CONFIG) --cflags x11)
X11LIB = $(shell $(PKG_CONFIG) --libs x11)

GTKINC = $(shell $(PKG_CONFIG) --cflags gtk+-3.0 gcr-3 webkit2gtk-4.1)
GTKLIB = $(shell $(PKG_CONFIG) --libs gtk+-3.0 gcr-3 webkit2gtk-4.1)
WEBEXTINC = $(shell $(PKG_CONFIG) --cflags webkit2gtk-4.1 webkit2gtk-web-extension-4.1 gio-2.0)
WEBEXTLIBS = $(shell $(PKG_CONFIG) --libs webkit2gtk-4.1 webkit2gtk-web-extension-4.1 gio-2.0)

# includes and libs
INCS = $(X11INC) $(GTKINC)
LIBS = $(X11LIB) $(GTKLIB) -lgthread-2.0

# flags
CPPFLAGS += -DVERSION=\"$(VERSION)\" -DGCR_API_SUBJECT_TO_CHANGE \
           -DLIBPREFIX=\"$(LIBPREFIX)\" -DWEBEXTDIR=\"$(LIBDIR)\" \
           -D_DEFAULT_SOURCE
SURFCFLAGS = -fPIC $(INCS) $(CPPFLAGS)
WEBEXTCFLAGS = -fPIC $(WEBEXTINC) $(CPPFLAGS)

# compiler
#CC = c99
