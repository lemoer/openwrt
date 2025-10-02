#!/bin/sh

toolname='000-meta-prereq'

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

# TODO: find out if CONFIG_... variables can leak in

copyit include
copyit rules.mk
copyit scripts
copyit Makefile

# build hashes over $tmpenv before build (which marks all inputs)
find $tmpenv -type f -exec md5sum {} + | sort -k 2 > $tmpmeta/input.hashes
cat $tmpmeta/input.hashes | md5sum - | awk '{print $1}' > $tmpmeta/input.hash
inputhash=$(cat $tmpmeta/input.hash)

tmpout=tmpout/$toolname-$inputhash/host

if [ -d $tmpout ]; then
    echo "$tmpout already exists, remove it first if you want to rebuild."
    exit 1
fi

make V=s TOPDIR=$(pwd)/tmpenv $(pwd)/tmpenv/staging_dir/host/.prereq-build -C $(pwd)/tmpenv

mkdir -p $(dirname $tmpout)

# To be atomic and make sure a build has really finished, we first build to $tmpbuild
# and then move it to $tmpout.
mv $(pwd)/tmpenv/staging_dir/host/ $tmpout

find $tmpout
