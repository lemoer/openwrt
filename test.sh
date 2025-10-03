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

sh testtool.sh meson       # depends on ninja

sh testtool.sh sed         # no dependencies

# Level 2: Second-level dependencies
sh testtool.sh pkgconf     # depends on meson
sh testtool.sh autoconf    # depends on m4
sh testtool.sh automake    # depends on autoconf, pkgconf, xz
sh testtool.sh libtool

# Level 1: Single direct dependencies
sh testtool.sh flex        # depends on libtool (but libtool needs automake, so flex is independent)

sh testtool.sh bison       # depends on flex
sh testtool.sh lzma-old    # depends on zlib

sh testtool.sh missing-macros  # depends on autoconf
sh testtool.sh findutils   # depends on bison

# Level 3: Third-level dependencies
sh testtool.sh libressl    # depends on pkgconf

sh testtool.sh gnulib      # no dependencies

# Level 5: Fifth-level dependencies
sh testtool.sh cmake       # depends on libressl, ninja, expat, xz, zlib, zstd
sh testtool.sh gmp         # depends on libtool
sh testtool.sh fakeroot    # depends on libtool
sh testtool.sh genext2fs   # depends on libtool
sh testtool.sh gengetopt   # depends on libtool
sh testtool.sh patchelf    # depends on libtool
sh testtool.sh dosfstools  # depends on automake
sh testtool.sh coreutils   # depends on automake, bison, gnulib
sh testtool.sh quilt       # depends on autoconf, findutils
sh testtool.sh padjffs2    # depends on findutils
sh testtool.sh sdcc        # depends on bison
sh testtool.sh squashfs4   # depends on xz, zlib
sh testtool.sh squashfs3-lzma  # depends on lzma-old
sh testtool.sh util-linux  # depends on bison, automake

# Level 6: Sixth-level dependencies
sh testtool.sh mpfr        # depends on gmp
sh testtool.sh isl         # depends on gmp
sh testtool.sh bzip2       # depends on cmake
sh testtool.sh firmware-utils  # depends on cmake
sh testtool.sh liblzo      # depends on cmake
sh testtool.sh lzop        # depends on cmake, liblzo
sh testtool.sh llvm-bpf    # depends on cmake
sh testtool.sh mold        # depends on cmake, zlib, zstd
sh testtool.sh yafut       # depends on cmake
sh testtool.sh make-ext4fs # depends on zlib
sh testtool.sh elfutils    # depends on bison, gnulib, m4, zlib
sh testtool.sh e2fsprogs   # depends on libtool, util-linux
sh testtool.sh erofs-utils # depends on libtool, xz, lz4, util-linux
sh testtool.sh mtd-utils   # depends on libtool, zlib, util-linux
sh testtool.sh cbootimage  # depends on automake

# Level 7: Seventh-level dependencies
sh testtool.sh mpc         # depends on mpfr, gmp
sh testtool.sh lz4         # depends on meson
sh testtool.sh mkimage     # depends on bison, libressl
sh testtool.sh mklibs      # depends on libtool

# Level 8: Eighth-level dependencies
sh testtool.sh bc          # depends on bison, libtool
sh testtool.sh b43-tools   # depends on bison