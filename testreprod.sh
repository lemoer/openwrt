#!/bin/sh

export tmpprefix=tmpreprod/

mkdir -p $tmpprefix

sh test.sh
ninja -j 1