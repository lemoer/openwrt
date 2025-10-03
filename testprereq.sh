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

tmpout=tmpout/$toolname/$inputhash

if [ -d $tmpout ]; then
    echo "reusing $tmpout, since it already exists."
    ln -s ../tmpout/$toolname/$inputhash $tmpassembly/$toolname
    exit 0
fi

make V=s TOPDIR=$(pwd)/tmpenv $(pwd)/tmpenv/staging_dir/host/.prereq-build -C $(pwd)/tmpenv

mkdir -p $tmpout

# To be atomic and make sure a build has really finished, we first build to $tmpbuild
# and then move it to $tmpout.
mv $(pwd)/tmpenv/staging_dir/host/ $tmpout/host


# TODO: remove $tmpenv/... from hashes

# Generate output hashes
find $tmpout/ -type f | xargs -r md5sum | sed "s|$tmpout/|$tmpenv/staging_dir/|" | sort -k 2 > $tmpmeta/output.hashes

mkdir -p $tmpout/.meta

# Copy outputhashes to output metadata
cp $tmpmeta/output.hashes $tmpout/.meta/output.hashes

ln -s ../tmpout/$toolname/$inputhash $tmpassembly/$toolname

find $tmpout
