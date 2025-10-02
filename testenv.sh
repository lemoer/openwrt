#!/bin/sh

toolname=autoconf

set -e

tmpenv=tmpenv
tmpmeta=tmpmeta

rm -rf $tmpenv
mkdir -p $tmpenv

rm -rf $tmpmeta
mkdir -p $tmpmeta

copyit() {
    destpath=$tmpenv/$(dirname $1)
    mkdir -p $destpath
    cp -r $1 $tmpenv/$1
}

# TODO: find out if CONFIG_... variables can leak in

copyit staging_dir/host/bin/mkhash     # from prereq-build.mk
copyit staging_dir/host/bin/xxd        # from prereq-build.mk

copyit staging_dir/host/bin/m4         # dependency of autoconf
copyit include
copyit rules.mk
copyit tools/$toolname
copyit scripts

# build hashes over $tmpenv before build (which marks all inputs)
find $tmpenv -type f -exec md5sum {} + | sort -k 2 > $tmpmeta/input.hashes
cat $tmpmeta/input.hashes | md5sum - | awk '{print $1}' > $tmpmeta/input.hash
inputhash=$(cat $tmpmeta/input.hash)

tmpout=tmpout/$toolname-$inputhash/host
#rm -rf $tmpout

if [ -d $tmpout ]; then
    echo "$tmpout already exists, remove it first if you want to rebuild."
    exit 1
fi
mkdir -p $tmpout

# build hashes over $tmpenv/staging_dir
find $tmpenv/staging_dir -type f -exec md5sum {} + | sort -k 2 > $tmpmeta/staging_dir_before.hash

# HOST_BUILD_PREFIX sets where the tool is installed to.

make V=s HOST_BUILD_PREFIX=$(pwd)/$tmpout TOPDIR=$(pwd)/tmpenv -j 1 -C tools/$toolname/ compile

find $tmpout

# Build hashes over $tmpenv/staging_dir again and check that
# they are unchanged.
find $tmpenv/staging_dir -type f -exec md5sum {} + | sort -k 2 > $tmpmeta/staging_dir_after.hash

cmp -s $tmpmeta/staging_dir_before.hash $tmpmeta/staging_dir_after.hash || {
    diff --color=auto -u $tmpmeta/staging_dir_before.hash $tmpmeta/staging_dir_after.hash || true
    echo "\nERROR: staging_dir changed by build! This should not happen. See diff above."
    exit 1
}