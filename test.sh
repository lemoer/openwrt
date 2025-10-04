#!/bin/sh

set -e

tmpenv=tmpenv
tmpmetabasic=tmpmetabasic

export tmpmetabasic=tmpmetabasic
rm -rf $tmpmetabasic
mkdir -p $tmpmetabasic

export tmpcurrent=tmpcurrent
rm -rf $tmpcurrent
mkdir -p $tmpcurrent

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

sh testtool.sh libdeflate
sh testtool.sh patch
sh testtool.sh tar
sh testtool.sh zstd
sh testtool.sh m4
sh testtool.sh ninja
sh testtool.sh expat
sh testtool.sh xz
sh testtool.sh zlib
sh testtool.sh gnulib
sh testtool.sh sed

sh testtool.sh meson
sh testtool.sh autoconf

sh testtool.sh pkgconf
sh testtool.sh missing-macros

sh testtool.sh automake

sh testtool.sh libtool

sh testtool.sh flex
sh testtool.sh gmp
sh testtool.sh fakeroot
sh testtool.sh genext2fs
sh testtool.sh gengetopt
sh testtool.sh patchelf

sh testtool.sh bison

sh testtool.sh findutils

sh testtool.sh lzma-old

sh testtool.sh dosfstools
sh testtool.sh coreutils
sh testtool.sh padjffs2
sh testtool.sh squashfs4
sh testtool.sh squashfs3-lzma
sh testtool.sh util-linux

sh testtool.sh autoconf-archive
sh testtool.sh lz4

sh testtool.sh make-ext4fs

sh testtool.sh mtd-utils
sh testtool.sh cbootimage

sh testtool.sh mklibs

sh testtool.sh bc
sh testtool.sh b43-tools

sh testtool.sh quilt

sh testtool.sh libressl
sh testtool.sh mkimage

sh testtool.sh mpfr
sh testtool.sh mpc

sh testtool.sh isl

sh testtool.sh cmake

sh testtool.sh bzip2
sh testtool.sh firmware-utils
sh testtool.sh liblzo
sh testtool.sh lzop
#sh testtool.sh llvm-bpf
sh testtool.sh mold
sh testtool.sh yafut

sh testtool.sh elfutils
sh testtool.sh e2fsprogs
sh testtool.sh erofs-utils
