#!/bin/sh

toolname=$1

set -e

tmpcurrent=tmpcurrent
tmpmetabasic=tmpmetabasic
tmpenv=$(mktemp -d)
tmpmeta=$tmpenv.meta

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
    cat tmpcurrent/$1/.meta/output.hashes 2>/dev/null >> $prefile || {
        echo "$toolname: Dependency $1 not found in tmpcurrent! Did you forget to build it first?"
        exit 1
    }
}

prefile=$tmpmeta/input.hashes.pre
cat $tmpmetabasic/basic.hashes > $prefile

. ./testtool_deps.sh

find tools/$toolname -type f -exec md5sum {} + | sort -k 2 >> $prefile

sort -u -k 2 $prefile -o $prefile

## try to use cached package

inputhashpre=$(cat $prefile | md5sum - | awk '{print $1}')
tmpfinished=tmpfinished/$toolname/$inputhashpre

if [ -d $tmpfinished ]; then
    echo "reusing $tmpfinished, since it already exists."
    ln -s ../$tmpfinished $tmpcurrent/$toolname
    exit 0
fi

## build

add_dependency() {
    destpath=$tmpenv/staging_dir
    mkdir -p $destpath
    cp --remove-destination -r $tmpcurrent/$1/* $destpath
}

# TODO: find out if CONFIG_... variables can leak in

. ./testtool_deps.sh

copyit include
copyit rules.mk
copyit tools/$toolname
copyit scripts

# build hashes over $tmpenv before build (which marks all inputs)
find $tmpenv -type f -exec md5sum {} + | sort -k 2 | sed "s| $tmpenv/| |" > $tmpmeta/input.hashes
cat $tmpmeta/input.hashes | md5sum - | awk '{print $1}' > $tmpmeta/input.hash
inputhash=$(cat $tmpmeta/input.hash)

diff -q $tmpmeta/input.hashes.pre $tmpmeta/input.hashes || {
    echo "$toolname: Input hashes changed between pre and actual build! This should not happen."
    diff --color=auto -u $tmpmeta/input.hashes.pre $tmpmeta/input.hashes || true
    exit 1
}

tmpfinished=tmpfinished/$toolname/$inputhash
tmpbuild=tmpbuild/$toolname/$inputhash

mkdir -p $tmpbuild/host/bin # some packages seem to require this

# build hashes over $tmpenv/staging_dir
find $tmpenv/staging_dir -type f -exec md5sum {} + | sed "s| $tmpenv/| |" | sort -k 2 > $tmpmeta/staging_dir_before.hash

# HOST_BUILD_PREFIX sets where the tool is installed to.

isolate=0
usepath=$PATH:$tmpenv/staging_dir/host/bin
if [ "$isolate" -eq 1 ]; then
    # Isolate build from host tools as much as possible
    usepath=$tmpenv/staging_dir/host/bin
    ln -s /bin/rm $tmpenv/staging_dir/host/bin/rm
    ln -s /bin/mkdir $tmpenv/staging_dir/host/bin/mkdir
    ln -s /bin/sort $tmpenv/staging_dir/host/bin/sort
    ln -s /bin/cat $tmpenv/staging_dir/host/bin/cat
    ln -s /bin/ls $tmpenv/staging_dir/host/bin/ls
    ln -s /bin/wc $tmpenv/staging_dir/host/bin/wc
    ln -s /bin/touch $tmpenv/staging_dir/host/bin/touch
    ln -s /bin/chmod $tmpenv/staging_dir/host/bin/chmod
    ln -s /bin/expr $tmpenv/staging_dir/host/bin/expr
    ln -s /bin/date $tmpenv/staging_dir/host/bin/date
    ln -s /bin/ln $tmpenv/staging_dir/host/bin/ln
    ln -s /bin/sh $tmpenv/staging_dir/host/bin/sh
    ln -s /bin/hostinfo $tmpenv/staging_dir/host/bin/hostinfo
    ln -s /bin/uname $tmpenv/staging_dir/host/bin/uname
    ln -s /bin/cut $tmpenv/staging_dir/host/bin/cut
    ln -s /bin/echo $tmpenv/staging_dir/host/bin/echo
    ln -s /bin/as $tmpenv/staging_dir/host/bin/as
    ln -s /bin/ld $tmpenv/staging_dir/host/bin/ld
    ln -s /bin/mv $tmpenv/staging_dir/host/bin/mv
    ln -s /usr/bin/ar $tmpenv/staging_dir/host/bin/ar
    ln -s /usr/bin/env $tmpenv/staging_dir/host/bin/env
    ln -s /usr/bin/make $tmpenv/staging_dir/host/bin/make
    ln -s /usr/bin/od $tmpenv/staging_dir/host/bin/od
    ln -s /usr/bin/tr $tmpenv/staging_dir/host/bin/tr
fi


env -i make -j 1 V=s HOST_OS=Linux PATH=$PATH:$tmpenv/staging_dir/host/bin HOST_BUILD_PREFIX=$(pwd)/$tmpbuild/host TOPDIR=$tmpenv -C tools/$toolname/ compile

# Build hashes over $tmpenv/staging_dir again and check that
# they are unchanged.
find $tmpenv/staging_dir -type f -exec md5sum {} + | sort -k 2 | sed "s| $tmpenv/| |" > $tmpmeta/staging_dir_after.hash

cmp -s $tmpmeta/staging_dir_before.hash $tmpmeta/staging_dir_after.hash || {
    diff --color=auto -u $tmpmeta/staging_dir_before.hash $tmpmeta/staging_dir_after.hash || true
    echo "\nERROR: staging_dir changed by build! This should not happen. See diff above."
    exit 1
}

# To be atomic and make sure a build has really finished, we first build to $tmpbuild
# and then move it to $tmpfinished.
mkdir -p $(dirname $tmpfinished)
ln -s ../../$tmpbuild/ $tmpfinished

# Generate output hashes
find $tmpfinished/ -type f -exec md5sum {} + | sed "s| $tmpfinished/| staging_dir/|" | sort -k 2 > $tmpmeta/output.hashes

mkdir -p $tmpfinished/.meta

# TODO: remove $tmpenv/... from hashes

# Copy input & outputhashes to output metadata
cp $tmpmeta/input.hashes $tmpfinished/.meta/
cp $tmpmeta/output.hashes $tmpfinished/.meta/

ln -s ../$tmpfinished/ $tmpcurrent/$toolname

find $tmpfinished

rm -rf $tmpenv
rm -rf $tmpmeta