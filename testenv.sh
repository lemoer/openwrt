#!/bin/sh

#toolname=libdeflate
#toolname=patch
#toolname=tar
#toolname=zstd
#toolname=m4
toolname=autoconf

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
    cp -r tmpout/$1-$2/* $destpath
}

# TODO: find out if CONFIG_... variables can leak in

copy_staging_dir_fromtool 000-meta-prereq 8921fc20661dccd4747c9542b002aeca
if [ $toolname = "patch" ] || [ $toolname = "tar" ] || [ $toolname = "zstd" ] || [ $toolname = "m4" ]; then
    copy_staging_dir_fromtool libdeflate b4726be1a4b019490580d5e470d15986
fi
if [ $toolname = "autoconf" ]; then
    copy_staging_dir_fromtool m4 f80176190dd11a05d2813204e880dffe
fi

#copyit staging_dir/host/bin/m4         # dependency of autoconf
copyit include
copyit rules.mk
copyit tools/$toolname
copyit scripts

# build hashes over $tmpenv before build (which marks all inputs)
find $tmpenv -type f -exec md5sum {} + | sort -k 2 > $tmpmeta/input.hashes
cat $tmpmeta/input.hashes | md5sum - | awk '{print $1}' > $tmpmeta/input.hash
inputhash=$(cat $tmpmeta/input.hash)

tmpout=tmpout/$toolname-$inputhash/host
tmpbuild=tmpbuild/$toolname-$inputhash/host

if [ -d $tmpout ]; then
    echo "$tmpout already exists, remove it first if you want to rebuild."
    exit 1
fi
mkdir -p $tmpbuild/bin

# build hashes over $tmpenv/staging_dir
find $tmpenv/staging_dir -type f -exec md5sum {} + | sort -k 2 > $tmpmeta/staging_dir_before.hash

# HOST_BUILD_PREFIX sets where the tool is installed to.

make V=s HOST_BUILD_PREFIX=$(pwd)/$tmpbuild TOPDIR=$(pwd)/tmpenv -j 1 -C tools/$toolname/ compile

# To be atomic and make sure a build has really finished, we first build to $tmpbuild
# and then move it to $tmpout.
mkdir -p $(dirname $tmpout)
mv $tmpbuild $tmpout

find $tmpout

# Build hashes over $tmpenv/staging_dir again and check that
# they are unchanged.
find $tmpenv/staging_dir -type f -exec md5sum {} + | sort -k 2 > $tmpmeta/staging_dir_after.hash

cmp -s $tmpmeta/staging_dir_before.hash $tmpmeta/staging_dir_after.hash || {
    diff --color=auto -u $tmpmeta/staging_dir_before.hash $tmpmeta/staging_dir_after.hash || true
    echo "\nERROR: staging_dir changed by build! This should not happen. See diff above."
    exit 1
}