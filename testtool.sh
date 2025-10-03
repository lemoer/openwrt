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

add_dependency() {
    #echo "$toolname: Adding dependency $1"
    cat tmpassembly/$1/.meta/output.hashes >> $prefile
}

prefile=$tmpmeta/input.hashes.pre
cat $tmpmetabasic/basic.hashes > $prefile

. ./testtool_deps.sh

find tools/$toolname -type f -exec md5sum {} + | sort -k 2 | sed "s| tools/| $tmpenv/tools/|" >> $prefile

sort -k 2 $prefile -o $prefile

## try to use cached package

inputhashpre=$(cat $prefile | md5sum - | awk '{print $1}')
tmpout=tmpout/$toolname/$inputhashpre

if [ -d $tmpout ]; then
    echo "reusing $tmpout, since it already exists."
    ln -s ../$tmpout $tmpassembly/$toolname
    exit 0
fi

## build

add_dependency() {
    destpath=$tmpenv/staging_dir
    mkdir -p $destpath
    cp -r $tmpassembly/$1/* $destpath
}

# TODO: find out if CONFIG_... variables can leak in

. ./testtool_deps.sh

copyit include
copyit rules.mk
copyit tools/$toolname
copyit scripts

# build hashes over $tmpenv before build (which marks all inputs)
find $tmpenv -type f -exec md5sum {} + | sort -k 2 > $tmpmeta/input.hashes
cat $tmpmeta/input.hashes | md5sum - | awk '{print $1}' > $tmpmeta/input.hash
inputhash=$(cat $tmpmeta/input.hash)

diff -q $tmpmeta/input.hashes.pre $tmpmeta/input.hashes || {
    echo "Input hashes changed between pre and actual build! This should not happen."
    diff --color=auto -u $tmpmeta/input.hashes.pre $tmpmeta/input.hashes || true
    exit 1
}

tmpout=tmpout/$toolname/$inputhash
tmpbuild=tmpbuild/$toolname/$inputhash

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

# Generate output hashes
find $tmpout/ -type f | xargs -r md5sum | sed "s|$tmpout/|$tmpenv/staging_dir/|" | sort -k 2 > $tmpmeta/output.hashes

mkdir -p $tmpout/.meta

# TODO: remove $tmpenv/... from hashes

# Copy input & outputhashes to output metadata
cp $tmpmeta/input.hashes $tmpout/.meta/
cp $tmpmeta/output.hashes $tmpout/.meta/

ln -s ../$tmpout/ $tmpassembly/$toolname

find $tmpout
