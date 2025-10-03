#!/bin/sh

set -e

export tmpassembly=tmpassembly
rm -rf $tmpassembly
mkdir -p $tmpassembly

sh testprereq.sh
sh testtool.sh libdeflate
sh testtool.sh patch
sh testtool.sh tar
sh testtool.sh zstd
sh testtool.sh m4
sh testtool.sh autoconf
sh testtool.sh ninja
sh testtool.sh meson
