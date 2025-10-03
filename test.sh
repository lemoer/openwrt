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
sh testtool.sh libdeflate
sh testtool.sh patch
sh testtool.sh tar
sh testtool.sh zstd
sh testtool.sh m4
sh testtool.sh autoconf
sh testtool.sh ninja
sh testtool.sh meson
