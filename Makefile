# The contents of this file are subject to the Mozilla Public
# License Version 1.1 (the "License"); you may not use this file
# except in compliance with the License. You may obtain a copy of
# the License at http://www.mozilla.org/MPL/
# 
# Software distributed under the License is distributed on an "AS
# IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
# implied. See the License for the specific language governing
# rights and limitations under the License.
# 
# The Original Code is the Netscape Portable Runtime library.
# 
# The Initial Developer of the Original Code is Netscape
# Communications Corporation.  Portions created by Netscape are 
# Copyright (C) 1994-2000 Netscape Communications Corporation.  All
# Rights Reserved.
# 
# Contributor(s):  Silicon Graphics, Inc.
# 
# Portions created by SGI are Copyright (C) 2000-2001 Silicon
# Graphics, Inc.  All Rights Reserved.
# 
# Alternatively, the contents of this file may be used under the
# terms of the GNU General Public License Version 2 or later (the
# "GPL"), in which case the provisions of the GPL are applicable 
# instead of those above.  If you wish to allow use of your 
# version of this file only under the terms of the GPL and not to
# allow others to use your version of this file under the MPL,
# indicate your decision by deleting the provisions above and
# replace them with the notice and other provisions required by
# the GPL.  If you do not delete the provisions above, a recipient
# may use your version of this file under either the MPL or the
# GPL.

# This is the full version of the libst library - modify carefully
VERSION     = 1.3

##########################
# Supported OSes:
#
#OS         = AIX
#OS         = FREEBSD
#OS         = HPUX
#OS         = HPUX_64
#OS         = IRIX
#OS         = IRIX_64
#OS         = LINUX
#OS         = LINUX_IA64
#OS         = OPENBSD
#OS         = OSF1
#OS         = SOLARIS

# Please see the "Other possible defines" section below for
# possible compilation options.
##########################

CC          = cc
AR          = ar
LD          = ld
RANLIB      = ranlib
LN          = ln

SHELL       = /bin/sh
ECHO        = /bin/echo

BUILD       = DBG
TARGETDIR   = $(OS)_$(shell uname -r)_$(BUILD)

DEFINES     = -D$(OS)
CFLAGS      =
SFLAGS      =
ARFLAGS     = -rv
LNFLAGS     = -s
DSO_SUFFIX  = so


##########################
# Platform section.
# Possible targets:

TARGETS     = aix-debug aix-optimized               \
              freebsd-debug freebsd-optimized       \
              hpux-debug hpux-optimized             \
              hpux-64-debug hpux-64-optimized       \
              irix-n32-debug irix-n32-optimized     \
              irix-64-debug irix-64-optimized       \
              linux-debug linux-optimized           \
              linux-ia64-debug linux-ia64-optimized \
              openbsd-debug openbsd-optimized       \
              osf1-debug osf1-optimized             \
              solaris-debug solaris-optimized

#
# Platform specifics
#

ifeq ($(OS), AIX)
AIX_VERSION = $(shell uname -v).$(shell uname -r)
TARGETDIR   = $(OS)_$(AIX_VERSION)_$(BUILD)
CC          = xlC
STATIC_ONLY = yes
ifeq ($(BUILD), OPT)
OTHER_FLAGS = -w
endif
ifneq ($(filter-out 4.1 4.2, $(AIX_VERSION)),)
DEFINES     += -DMD_HAVE_SOCKLEN_T
endif
endif

ifeq ($(OS), FREEBSD)
SFLAGS      = -fPIC
LDFLAGS     = -shared -soname=$(SONAME) -lc
OTHER_FLAGS = -Wall
endif

ifeq (HPUX, $(findstring HPUX, $(OS)))
ifeq ($(OS), HPUX_64)
DEFINES     = -DHPUX
CFLAGS      = -Ae +DD64 +Z
else
CFLAGS      = -Ae +DAportable +Z
endif
RANLIB      = true
LDFLAGS     = -b
DSO_SUFFIX  = sl
endif

ifeq (IRIX, $(findstring IRIX, $(OS)))
ifeq ($(OS), IRIX_64)
DEFINES     = -DIRIX
ABIFLAG     = -64
else
ABIFLAG     = -n32
endif
RANLIB      = true
CFLAGS      = $(ABIFLAG) -mips3
LDFLAGS     = $(ABIFLAG) -shared
OTHER_FLAGS = -fullwarn
endif

ifeq (LINUX, $(findstring LINUX, $(OS)))
ifeq ($(OS), LINUX_IA64)
DEFINES     = -DLINUX
EXTRA_OBJS  = $(TARGETDIR)/ia64asm.o
endif
SFLAGS      = -fPIC
LDFLAGS     = -shared -soname=$(SONAME) -lc
OTHER_FLAGS = -Wall
endif

ifeq ($(OS), OPENBSD)
SFLAGS      = -fPIC
LDFLAGS     = -shared -soname=$(SONAME) -lc
OTHER_FLAGS = -Wall
endif

ifeq ($(OS), OSF1)
RANLIB      = true
LDFLAGS     = -shared -all -expect_unresolved "*"
endif

ifeq ($(OS), SOLARIS)
TARGETDIR   = $(OS)_$(shell uname -r | sed 's/^5/2/')_$(BUILD)
CC          = gcc
LD          = gcc
RANLIB      = true
LDFLAGS     = -G
OTHER_FLAGS = -Wall
endif

#
# End of platform section.
##########################


ifeq ($(BUILD), OPT)
OTHER_FLAGS += -O
else
OTHER_FLAGS += -g
DEFINES     += -DDEBUG
endif

##########################
# Other possible defines:
# To use poll(2) instead of select(2) for events checking:
# DEFINES += -DUSE_POLL
# You may prefer to use select for applications that have many threads
# using one file descriptor, and poll for applications that have many
# different file descriptors.  With USE_POLL poll() is called with at
# least one pollfd per I/O-blocked thread, so 1000 threads sharing one
# descriptor will poll 1000 identical pollfds and select would be more
# efficient.  But if the threads all use different descriptors poll()
# may be better depending on your operating system's implementation of
# poll and select.  Really, it's up to you.  Oh, and on some platforms
# poll() fails with more than a few dozen descriptors.
#
# Some platforms allow to define FD_SETSIZE (if select() is used), e.g.:
# DEFINES += -DFD_SETSIZE=4096
#
# To use malloc(3) instead of mmap(2) for stack allocation:
# DEFINES += -DMALLOC_STACK
##########################

CFLAGS      += $(DEFINES) $(OTHER_FLAGS)

OBJS        = $(TARGETDIR)/sched.o \
              $(TARGETDIR)/stk.o   \
              $(TARGETDIR)/sync.o  \
              $(TARGETDIR)/key.o   \
              $(TARGETDIR)/io.o
OBJS        += $(EXTRA_OBJS)
HEADER      = $(TARGETDIR)/st.h
SLIBRARY    = $(TARGETDIR)/libst.a
DLIBRARY    = $(TARGETDIR)/libst.$(DSO_SUFFIX).$(VERSION)
EXAMPLES    = examples

MAJOR       = $(shell echo $(VERSION) | sed 's/^\([^\.]*\).*/\1/')
LINKNAME    = libst.$(DSO_SUFFIX)
SONAME      = libst.$(DSO_SUFFIX).$(MAJOR)
FULLNAME    = libst.$(DSO_SUFFIX).$(VERSION)
DESC        = st.pc

ifeq ($(STATIC_ONLY), yes)
LIBRARIES   = $(SLIBRARY)
else
LIBRARIES   = $(SLIBRARY) $(DLIBRARY)
endif

ifeq ($(OS),)
ST_ALL      = unknown
else
ST_ALL      = $(TARGETDIR) $(LIBRARIES) $(HEADER) $(EXAMPLES) $(DESC)
endif

all: $(ST_ALL)

unknown:
	@echo
	@echo "Please specify one of the following targets:"
	@echo
	@for target in $(TARGETS); do echo $$target; done
	@echo

st.pc:	st.pc.in
	sed "s/@VERSION@/${VERSION}/g" < $< > $@

$(TARGETDIR):
	if [ ! -d $(TARGETDIR) ]; then mkdir $(TARGETDIR); fi

$(SLIBRARY): $(OBJS)
	$(AR) $(ARFLAGS) $@ $(OBJS)
	$(RANLIB) $@
	rm -f obj; $(LN) $(LNFLAGS) $(TARGETDIR) obj

$(DLIBRARY): $(OBJS:%.o=%-pic.o)
	$(LD) $(LDFLAGS) $^ -o $@
	cd $(TARGETDIR); rm -f $(SONAME); $(LN) $(LNFLAGS) $(FULLNAME) $(SONAME)
	cd $(TARGETDIR); rm -f $(LINKNAME); $(LN) $(LNFLAGS) $(FULLNAME) $(LINKNAME)

$(HEADER): public.h
	rm -f $@
	cp public.h $@

$(TARGETDIR)/%asm.o: %asm.S
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGETDIR)/%.o: %.c common.h md.h
	$(CC) $(CFLAGS) -c $< -o $@

examples::
	@cd $@; $(MAKE) CC="$(CC)" CFLAGS="$(CFLAGS)" OS="$(OS)" TARGETDIR="$(TARGETDIR)"

clean:
	rm -rf *_OPT *_DBG obj st.pc

##########################
# Pattern rules:

ifneq ($(SFLAGS),)
# Compile with shared library options if it's a C file
$(TARGETDIR)/%-pic.o: %.c
	$(CC) $(CFLAGS) $(SFLAGS) -c $< -o $@
endif

# Compile assembly as normal or C as normal if no SFLAGS
%-pic.o: %.o
	rm -f $@; $(LN) $(LNFLAGS) $(<F) $@

##########################
# Target rules:

default-debug:
	. ./osguess.sh; $(MAKE) OS="$$OS" BUILD="DBG"
default default-optimized:
	. ./osguess.sh; $(MAKE) OS="$$OS" BUILD="OPT"

aix-debug:
	$(MAKE) OS="AIX" BUILD="DBG"
aix-optimized:
	$(MAKE) OS="AIX" BUILD="OPT"

freebsd-debug:
	$(MAKE) OS="FREEBSD" BUILD="DBG"
freebsd-optimized:
	$(MAKE) OS="FREEBSD" BUILD="OPT"

hpux-debug:
	$(MAKE) OS="HPUX" BUILD="DBG"
hpux-optimized:
	$(MAKE) OS="HPUX" BUILD="OPT"
hpux-64-debug:
	$(MAKE) OS="HPUX_64" BUILD="DBG"
hpux-64-optimized:
	$(MAKE) OS="HPUX_64" BUILD="OPT"

irix-n32-debug:
	$(MAKE) OS="IRIX" BUILD="DBG"
irix-n32-optimized:
	$(MAKE) OS="IRIX" BUILD="OPT"
irix-64-debug:
	$(MAKE) OS="IRIX_64" BUILD="DBG"
irix-64-optimized:
	$(MAKE) OS="IRIX_64" BUILD="OPT"

linux-debug:
	$(MAKE) OS="LINUX" BUILD="DBG"
linux-optimized:
	$(MAKE) OS="LINUX" BUILD="OPT"
linux-ia64-debug:
	$(MAKE) OS="LINUX_IA64" BUILD="DBG"
linux-ia64-optimized:
	$(MAKE) OS="LINUX_IA64" BUILD="OPT"

openbsd-debug:
	$(MAKE) OS="OPENBSD" BUILD="DBG"
openbsd-optimized:
	$(MAKE) OS="OPENBSD" BUILD="OPT"

osf1-debug:
	$(MAKE) OS="OSF1" BUILD="DBG"
osf1-optimized:
	$(MAKE) OS="OSF1" BUILD="OPT"

solaris-debug:
	$(MAKE) OS="SOLARIS" BUILD="DBG"
solaris-optimized:
	$(MAKE) OS="SOLARIS" BUILD="OPT"

##########################

