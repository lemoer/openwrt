#!/bin/sh

toolname='000-meta-prepare'

set -e

tmpcurrent=tmpcurrent
tmpmetabasic=tmpmetabasic
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

# TODO: This consumes way too many inputs, I think.

copyit include
copyit rules.mk
copyit scripts
copyit Makefile
copyit target/Makefile
copyit target/linux
copyit package/Makefile
copyit tools/Makefile
copyit toolchain/Makefile
copyit toolchain/info.mk
copyit feeds
test -f feeds.conf.default && copyit feeds.conf.default
test -f feeds.conf && copyit feeds.conf
copyit Config.in
copyit config
copyit .config
copyit tools/include

for file in $(find target/ toolchain/ feeds/ package/ -name Config.in); do
    copyit $file
done

for file in $(find target/ toolchain/ feeds/ package/ -name Config.version); do
    copyit $file
done

# build hashes over $tmpenv before build (which marks all inputs)
find $tmpenv -type f -exec md5sum {} + | sort -k 2 > $tmpmeta/input.hashes
cat $tmpmeta/input.hashes | md5sum - | awk '{print $1}' > $tmpmeta/input.hash
inputhash=$(cat $tmpmeta/input.hash)

tmpfinished=tmpfinished/$toolname/$inputhash

if [ -d $tmpfinished ]; then
    echo "reusing $tmpfinished, since it already exists."
    ln -s ../tmpfinished/$toolname/$inputhash $tmpcurrent/$toolname
    exit 0
fi


make V=s TOPDIR=$(pwd)/tmpenv $(pwd)/tmpenv/staging_dir/host/.prepared -C $(pwd)/tmpenv
rm -fr $tmpenv/staging_dir/host/bin/* # little hack to avoid prereq tools in this tool

mkdir -p $tmpfinished

# To be atomic and make sure a build has really finished, we first build to $tmpbuild
# and then move it to $tmpfinished.
mv $(pwd)/tmpenv/staging_dir/host/ $tmpfinished/host


# TODO: remove $tmpenv/... from hashes

# Generate output hashes
find $tmpfinished/ -type f | xargs -r md5sum | sed "s|$tmpfinished/|staging_dir/|" | sort -k 2 > $tmpmeta/output.hashes

mkdir -p $tmpfinished/.meta

# Copy outputhashes to output metadata
cp $tmpmeta/output.hashes $tmpfinished/.meta/output.hashes

ln -s ../tmpfinished/$toolname/$inputhash $tmpcurrent/$toolname

find $tmpfinished
