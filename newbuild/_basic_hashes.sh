#!/bin/sh

set -e

tmpenv=${tmpprefix}tmpenv
tmpmetabasic=${tmpprefix}tmpmetabasic
tmpcurrent=${tmpprefix}tmpcurrent

rm -rf $tmpmetabasic
mkdir -p $tmpmetabasic
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

find $tmpenv -type f -exec md5sum {} + | sed "s| $tmpenv/| |" | sort -k 2 > $tmpmetabasic/basic.hashes
