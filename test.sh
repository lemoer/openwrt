#!/bin/sh

set -e

tmpenv=tmpenv
tmpmetabasic=tmpmetabasic

export tmpmetabasic=tmpmetabasic
rm -rf $tmpmetabasic
mkdir -p $tmpmetabasic

export tmpassembly=tmpassembly
rm -rf $tmpassembly
mkdir -p $tmpassembly

# some preparations

rm -rf $tmpenv
mkdir -p $tmpenv

copyit() {
    destpath=$tmpenv/$(dirname $1)
    mkdir -p $destpath
    cp -r $1 $tmpenv/$1
}

copyit include
copyit rules.mk
copyit scripts

find $tmpenv -type f -exec md5sum {} + | sort -k 2 > $tmpmetabasic/basic.hashes

sh testprereq.sh

# Level 0: No dependencies (except libdeflate dependency for most)
sh testtool.sh libdeflate  # special: no libdeflate dependency
sh testtool.sh patch       # no dependencies
sh testtool.sh tar         # no dependencies
sh testtool.sh zstd        # no dependencies
sh testtool.sh m4          # no dependencies
sh testtool.sh ninja       # no dependencies
sh testtool.sh expat       # no dependencies
sh testtool.sh xz          # no dependencies
sh testtool.sh zlib        # no dependencies
sh testtool.sh gnulib      # no dependencies
sh testtool.sh sed         # no dependencies

# Level 1: Single direct dependencies
sh testtool.sh meson       # depends on ninja
sh testtool.sh autoconf    # depends on m4

# Level 2: Second-level dependencies
sh testtool.sh pkgconf     # depends on meson
sh testtool.sh missing-macros  # depends on autoconf

# Level 3: Third-level dependencies
sh testtool.sh automake    # depends on autoconf, pkgconf, xz

# Level 4: Fourth-level dependencies
sh testtool.sh libtool     # depends on automake, gnulib, missing-macros

# Level 5: Fifth-level dependencies that depend on libtool
sh testtool.sh flex        # depends on libtool
sh testtool.sh gmp         # depends on libtool
sh testtool.sh fakeroot    # depends on libtool
sh testtool.sh genext2fs   # depends on libtool
sh testtool.sh gengetopt   # depends on libtool
sh testtool.sh patchelf    # depends on libtool

# Level 6: Tools that depend on flex or other level 5 tools
sh testtool.sh bison       # depends on flex

# Level 7: Tools that depend on bison
sh testtool.sh findutils   # depends on bison

# Level 8: Third-level dependencies (no libtool conflict)
sh testtool.sh lzma-old    # depends on zlib

# Level 9: Tools that depend on multiple previous levels
sh testtool.sh dosfstools  # depends on automake  
sh testtool.sh coreutils   # depends on automake, bison, gnulib
sh testtool.sh padjffs2    # depends on findutils
sh testtool.sh squashfs4   # depends on xz, zlib
sh testtool.sh squashfs3-lzma  # depends on lzma-old
sh testtool.sh util-linux  # depends on bison, automake


sh testtool.sh autoconf-archive
sh testtool.sh lz4         # depends on meson

# Level 6: Sixth-level dependencies
sh testtool.sh make-ext4fs # depends on zlib

sh testtool.sh mtd-utils   # depends on libtool, zlib, util-linux
sh testtool.sh cbootimage  # depends on automake

# Level 7: Seventh-level dependencies
sh testtool.sh mklibs      # depends on libtool

# Level 8: Eighth-level dependencies
sh testtool.sh bc          # depends on bison, libtool
sh testtool.sh b43-tools   # depends on bison


sh testtool.sh quilt       # depends on autoconf, findutils

sh testtool.sh libressl    # depends on pkgconf
sh testtool.sh mkimage     # depends on bison, libressl



sh testtool.sh mpfr        # depends on gmp
sh testtool.sh mpc         # depends on mpfr, gmp

sh testtool.sh isl         # depends on gmp


sh testtool.sh cmake       # depends on libressl, ninja, expat, xz, zlib, zstd

sh testtool.sh bzip2       # depends on cmake
sh testtool.sh firmware-utils  # depends on cmake
sh testtool.sh liblzo      # depends on cmake
sh testtool.sh lzop        # depends on cmake, liblzo
sh testtool.sh llvm-bpf    # depends on cmake
sh testtool.sh mold        # depends on cmake, zlib, zstd
sh testtool.sh yafut       # depends on cmake


sh testtool.sh elfutils    # depends on bison, gnulib, m4, zlib
sh testtool.sh e2fsprogs   # depends on libtool, util-linux, lz4
sh testtool.sh erofs-utils # depends on libtool, xz, lz4, util-linux