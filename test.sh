#!/bin/sh

sh testprereq.sh
sh testtool.sh libdeflate
sh testtool.sh patch
sh testtool.sh tar
sh testtool.sh zstd
sh testtool.sh m4
sh testtool.sh autoconf
