#!/bin/sh

toolname=$1

set -e

tmpenv=tmpenv
tmpmeta=tmpmeta

rm -rf $tmpenv
mkdir -p $tmpenv
mkdir -p $tmpenv/tmp

rm -rf $tmpmeta
mkdir -p $tmpmeta

copyit() {
    destpath=$tmpenv/$(dirname $1)
    mkdir -p $destpath
    cp -r $1 $tmpenv/$1
}

copy_staging_dir_fromtool() {
    destpath=$tmpenv/staging_dir
    mkdir -p $destpath
    cp -r $tmpassembly/$1/* $destpath
}

# TODO: find out if CONFIG_... variables can leak in

copy_staging_dir_fromtool 000-meta-prereq

if [ $toolname != "libdeflate" ]; then
    copy_staging_dir_fromtool libdeflate
fi

# The following are the dependencies between tools, as far as I could
# figure out.
# For each dependency, call copy_staging_dir_fromtool with the dependency name.

case "$toolname" in
    autoconf)
        copy_staging_dir_fromtool m4
        ;;
    automake)
        copy_staging_dir_fromtool autoconf
        copy_staging_dir_fromtool pkgconf
        copy_staging_dir_fromtool xz
        ;;
    b43-tools)
        copy_staging_dir_fromtool bison
        ;;
    bc)
        copy_staging_dir_fromtool bison
        copy_staging_dir_fromtool libtool
        ;;
    bison)
        copy_staging_dir_fromtool flex
        ;;
    bzip2)
        copy_staging_dir_fromtool cmake
        ;;
    cbootimage)
        copy_staging_dir_fromtool automake
        ;;
    cmake)
        copy_staging_dir_fromtool libressl
        copy_staging_dir_fromtool ninja
        copy_staging_dir_fromtool expat
        copy_staging_dir_fromtool xz
        copy_staging_dir_fromtool zlib
        copy_staging_dir_fromtool zstd
        ;;
    coreutils)
        copy_staging_dir_fromtool automake
        copy_staging_dir_fromtool bison
        copy_staging_dir_fromtool gnulib
        ;;
    dosfstools)
        copy_staging_dir_fromtool automake
        ;;
    e2fsprogs)
        copy_staging_dir_fromtool libtool
        copy_staging_dir_fromtool util-linux
        ;;
    elfutils)
        copy_staging_dir_fromtool bison
        copy_staging_dir_fromtool gnulib
        copy_staging_dir_fromtool m4
        copy_staging_dir_fromtool zlib
        ;;
    erofs-utils)
        copy_staging_dir_fromtool libtool
        copy_staging_dir_fromtool xz
        copy_staging_dir_fromtool lz4
        copy_staging_dir_fromtool util-linux
        ;;
    fakeroot)
        copy_staging_dir_fromtool libtool
        ;;
    findutils)
        copy_staging_dir_fromtool bison
        ;;
    firmware-utils)
        copy_staging_dir_fromtool cmake
        ;;
    flex)
        copy_staging_dir_fromtool libtool
        ;;
    genext2fs)
        copy_staging_dir_fromtool libtool
        ;;
    gengetopt)
        copy_staging_dir_fromtool libtool
        ;;
    gmp)
        copy_staging_dir_fromtool libtool
        ;;
    isl)
        copy_staging_dir_fromtool gmp
        ;;
    liblzo)
        copy_staging_dir_fromtool cmake
        ;;
    libressl)
        copy_staging_dir_fromtool pkgconf
        ;;
    libtool)
        copy_staging_dir_fromtool automake
        copy_staging_dir_fromtool gnulib
        copy_staging_dir_fromtool missing-macros
        ;;
    lz4)
        copy_staging_dir_fromtool meson
        ;;
    lzma-old)
        copy_staging_dir_fromtool zlib
        ;;
    lzop)
        copy_staging_dir_fromtool cmake
        copy_staging_dir_fromtool liblzo
        ;;
    llvm-bpf)
        copy_staging_dir_fromtool cmake
        ;;
    make-ext4fs)
        copy_staging_dir_fromtool zlib
        ;;
    meson)
        copy_staging_dir_fromtool ninja
        ;;
    missing-macros)
        copy_staging_dir_fromtool autoconf
        ;;
    mkimage)
        copy_staging_dir_fromtool bison
        copy_staging_dir_fromtool libressl
        ;;
    mklibs)
        copy_staging_dir_fromtool libtool
        ;;
    mold)
        copy_staging_dir_fromtool cmake
        copy_staging_dir_fromtool zlib
        copy_staging_dir_fromtool zstd
        ;;
    mpc)
        copy_staging_dir_fromtool mpfr
        copy_staging_dir_fromtool gmp
        ;;
    mpfr)
        copy_staging_dir_fromtool gmp
        ;;
    mtd-utils)
        copy_staging_dir_fromtool libtool
        copy_staging_dir_fromtool zlib
        copy_staging_dir_fromtool util-linux
        ;;
    padjffs2)
        copy_staging_dir_fromtool findutils
        ;;
    patchelf)
        copy_staging_dir_fromtool libtool
        ;;
    pkgconf)
        copy_staging_dir_fromtool meson
        ;;
    quilt)
        copy_staging_dir_fromtool autoconf
        copy_staging_dir_fromtool findutils
        ;;
    sdcc)
        copy_staging_dir_fromtool bison
        ;;
    squashfs3-lzma)
        copy_staging_dir_fromtool lzma-old
        ;;
    squashfs4)
        copy_staging_dir_fromtool xz
        copy_staging_dir_fromtool zlib
        ;;
    util-linux)
        copy_staging_dir_fromtool bison
        copy_staging_dir_fromtool automake
        ;;
    yafut)
        copy_staging_dir_fromtool cmake
        ;;
esac

copyit include
copyit rules.mk
copyit tools/$toolname
copyit scripts

# build hashes over $tmpenv before build (which marks all inputs)
find $tmpenv -type f -exec md5sum {} + | sort -k 2 > $tmpmeta/input.hashes
cat $tmpmeta/input.hashes | md5sum - | awk '{print $1}' > $tmpmeta/input.hash
inputhash=$(cat $tmpmeta/input.hash)

tmpout=tmpout/$toolname/$inputhash
tmpbuild=tmpbuild/$toolname/$inputhash

if [ -d $tmpout ]; then
    echo "reusing $tmpout, since it already exists."
    ln -s ../$tmpout $tmpassembly/$toolname
    exit 0
fi
mkdir -p $tmpbuild/host/bin # some packages seem to require this

# build hashes over $tmpenv/staging_dir
find $tmpenv/staging_dir -type f -exec md5sum {} + | sort -k 2 > $tmpmeta/staging_dir_before.hash

# HOST_BUILD_PREFIX sets where the tool is installed to.

make V=s HOST_BUILD_PREFIX=$(pwd)/$tmpbuild/host TOPDIR=$(pwd)/tmpenv -j 1 -C tools/$toolname/ compile

# Build hashes over $tmpenv/staging_dir again and check that
# they are unchanged.
find $tmpenv/staging_dir -type f -exec md5sum {} + | sort -k 2 > $tmpmeta/staging_dir_after.hash

cmp -s $tmpmeta/staging_dir_before.hash $tmpmeta/staging_dir_after.hash || {
    diff --color=auto -u $tmpmeta/staging_dir_before.hash $tmpmeta/staging_dir_after.hash || true
    echo "\nERROR: staging_dir changed by build! This should not happen. See diff above."
    exit 1
}

# To be atomic and make sure a build has really finished, we first build to $tmpbuild
# and then move it to $tmpout.
mkdir -p $(dirname $tmpout)
mv $tmpbuild $tmpout

ln -s ../$tmpout $tmpassembly/$toolname

find $tmpout
