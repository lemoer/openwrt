#!/bin/sh

export tmpprefix=tmpreprod/

mkdir -p $tmpprefix

sh newbuild/_basic_hashes.sh
ninja -j 1