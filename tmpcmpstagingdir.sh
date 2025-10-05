#!/bin/sh

set -e

flag=$1


find -L staging_dir/ -type f | sort > /tmp/staging_dir_filelist.txt
find -L tmpcurrent/ -type f | sort > /tmp/current_dir_filelist.txt

sed 's|^staging_dir/| |' /tmp/staging_dir_filelist.txt > /tmp/staging_dir_filelist_filtered.txt
sed 's|^tmpcurrent/[^\/]*/| |' /tmp/current_dir_filelist.txt | grep -ve '\.meta/.*.hashes' > /tmp/current_dir_filelist_filtered.txt

sort /tmp/staging_dir_filelist_filtered.txt -o /tmp/staging_dir_filelist_filtered.txt
sort /tmp/current_dir_filelist_filtered.txt -u -o /tmp/current_dir_filelist_filtered.txt

diff --color=auto -u /tmp/staging_dir_filelist_filtered.txt /tmp/current_dir_filelist_filtered.txt > tmpcmpfilelist.diff || true

if [ $flag = '-c' ]; then
    #find -L staging_dir/ -type f -exec md5sum {} \; | sort -k 2 > /tmp/staging_dir_md5sums.txt
    #find -L tmpcurrent/ -type f -exec md5sum {} \; | sort -k 2 > /tmp/current_dir_md5sums.txt
    sed 's| staging_dir/| |' /tmp/staging_dir_md5sums.txt > /tmp/staging_dir_md5sums_filtered.txt
    sed 's| tmpcurrent/[^\/]*/| |' /tmp/current_dir_md5sums.txt | grep -ve ' \.meta/.*.hashes' > /tmp/current_dir_md5sums_filtered.txt
    sort -k 2 /tmp/current_dir_md5sums_filtered.txt -o /tmp/current_dir_md5sums_filtered.txt
    sort -k 2 /tmp/staging_dir_md5sums_filtered.txt -o /tmp/staging_dir_md5sums_filtered.txt
    diff --color=auto -u /tmp/staging_dir_md5sums_filtered.txt /tmp/current_dir_md5sums_filtered.txt > tmpcmp.diff || true
else
    rm -f tmpcmp.diff
fi