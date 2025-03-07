# $Copyright: $
# Copyright (c) 1996 - 2022 by Steve Baker
# All Rights reserved
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

PREFIX=/usr/local

CC=gcc
INSTALL=install

VERSION=2.1.0
TREE_DEST=tree
DESTDIR=${PREFIX}/bin
MAN=tree.1
# Probably needs to be ${PREFIX}/share/man for most systems now
MANDIR=${PREFIX}/man
OBJS=tree.o list.o hash.o color.o file.o filter.o info.o unix.o xml.o json.o html.o strverscmp.o

# Uncomment options below for your particular OS:

# Linux defaults:
#CFLAGS+=-ggdb -std=c11 -pedantic -Wall -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64
CFLAGS+=-O3 -std=c11 -pedantic -Wall -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64
#LDFLAGS+=-s

# Uncomment for FreeBSD:
#CC=cc
#CFLAGS+=-O2 -Wall -fomit-frame-pointer
#LDFLAGS+=-s

# Uncomment for OpenBSD:
#TREE_DEST=colortree
#MAN=colortree.1
#CFLAGS+=-O2 -Wall -fomit-frame-pointer
#LDFLAGS+=-s

# Uncomment for Solaris:
#CC=cc
#CFLAGS+=-xO0 -v
#LDFLAGS+=
#MANDIR=${prefix}/share/man

# Uncomment for Cygwin:
#CFLAGS+=-O2 -Wall -fomit-frame-pointer
#LDFLAGS+=-s
#TREE_DEST=tree.exe

# Uncomment for OS X:
# It is not allowed to install to /usr/bin on OS X any longer (SIP):

#CC=cc
#CFLAGS+=-O2 -Wall -fomit-frame-pointer -no-cpp-precomp
#LDFLAGS+=
#MANDIR=${PREFIX}/share/man

# tvOS
TVOS_SDK		:= appletvos
TVOS_SDK_PATH	:= $(shell /usr/bin/xcrun --sdk $(TVOS_SDK) --show-sdk-path)
TVOS_CFLAGS+=-arch arm64 -isysroot "$(TVOS_SDK_PATH)" -mappletvos-version-min=9.0 -O3
TVOS_LDFLAGS+=-arch arm64 -isysroot "$(TVOS_SDK_PATH)" -mappletvos-version-min=9.0 -O3

# iOS:
IOS_CC=clang
IOS_SDK         := iphoneos
IOS_SDK_PATH   	:= $(shell /usr/bin/xcrun --sdk $(IOS_SDK) --show-sdk-path)
IOS_CFLAGS		:= -arch arm64 -isysroot "$(IOS_SDK_PATH)" -miphoneos-version-min=8.1 -O3
IOS_LDFLAGS		:= -arch arm64 -isysroot "$(IOS_SDK_PATH)" -miphoneos-version-min=8.1 -O3

FILES			:= $(wildcard *.c)

# Uncomment for HP/UX:
#prefix=/opt
#CC=cc
# manpage of mbsrtowcs() requires C99 and the two defines
#CFLAGS+=+w -D_XOPEN_SOURCE=500 -D_POSIX_C_SOURCE=200112 -AC99
#LDFLAGS+=
#MANDIR=${PREFIX}/share/man

# Uncomment for OS/2:
#CFLAGS+=-02 -Wall -fomit-frame-pointer -Zomf -Zsmall-conv
#LDFLAGS+=-s -Zomf -Zsmall-conv

# Uncomment for HP NonStop:
#prefix = /opt
#CC=c89
#CFLAGS+=-Wextensions -WIEEE_float -g -Wnowarn=1506 -D_XOPEN_SOURCE_EXTENDED=1 \
#	 -Wallow_cplusplus_comments
#LDFLAGS+=

# AIX
#CC=cc_r -q64
#LD=ld -d64
#LDFLAGS+=-lc

#------------------------------------------------------------

all:	tree ios tvos

ios: $(FILES)
	@echo "[i] Building $@..."
	@clang $(FILES) -o $@ $(IOS_CFLAGS) $(IOS_LDFLAGS)
	@strip $@
	@ldid -S $@
	@echo "[i] Updating ios folder..."
	@mkdir -p build/$@
	@mv $@ build/$@/tree
	
tvos: $(FILES)
	@echo "[i] Building $@..."
	@clang $(FILES) -o $@ $(TVOS_CFLAGS) $(TVOS_LDFLAGS)
	@strip $@
	@ldid -S $@
	@echo "[i] Updating tvos folder..."
	@mkdir -p build/$@
	@mv $@ build/$@/tree
	
tree:	$(OBJS)
	$(CC) $(LDFLAGS) -o $(TREE_DEST) $(OBJS)

$(OBJS): %.o:	%.c tree.h
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(TREE_DEST) *.o *~ ios tvos

install: tree
	$(INSTALL) -d $(DESTDIR)
	$(INSTALL) -d $(MANDIR)/man1
	$(INSTALL) $(TREE_DEST) $(DESTDIR)/$(TREE_DEST); \
	$(INSTALL) -m 644 doc/$(MAN) $(MANDIR)/man1/$(MAN)

distclean:
	rm -f *.o *~

dist:	distclean
	tar zcf ../tree-$(VERSION).tgz -C .. `cat .tarball`
