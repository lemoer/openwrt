#!/bin/sh

# rm -fr tmpbuild/e2fsprogs/; ninja &> buildlog-ourapproach.orig
# make tools/e2fsprogs/{clean,compile} V=s -j 1 &> buildlog-openwrt.orig

cp buildlog-openwrt.orig buildlog-openwrt
cp buildlog-ourapproach.orig buildlog-ourapproach

sed -i 's|/home/lemoer/git/ff/openwrt/build_dir/|@BUILD_DIR@/|g' buildlog-openwrt
sed -i 's|/tmp/tmp.[^/]*/build_dir/|@BUILD_DIR@/|g' buildlog-ourapproach

#sed -i 's|/home/lemoer/git/ff/openwrt/tmpbuild/[^/]*/[^/]*/|@DESTDIR@/|g' buildlog-ourapproach
#sed -i 's|/home/lemoer/git/ff/openwrt/staging_dir|@DESTDIR@|g' buildlog-openwrt
sed -i 's|/home/lemoer/git/ff/openwrt/tmpbuild/[^/]*/[^/]*/|@TOPDIR@/staging_dir/|g' buildlog-ourapproach

sed -i 's|^make\[.*\]|make[@]/|g' buildlog-openwrt
sed -i 's|^make\[.*\]|make[@]/|g' buildlog-ourapproach

sed -i 's|/home/lemoer/git/ff/openwrt|@TOPDIR@|g' buildlog-openwrt
sed -i 's|/tmp/tmp.[a-zA-Z0-9_]*|@TOPDIR@|gm' buildlog-ourapproach

meld buildlog-openwrt buildlog-ourapproach