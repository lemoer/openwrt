#!/bin/sh

find staging_dir/ -type f -exec md5sum {} \; | sort -k 2 > /tmp/staging_dir_md5sums.txt
find -L tmpcurrent/ -type f -exec md5sum {} \; | sort -k 2 > /tmp/current_dir_md5sums.txt

sed 's| staging_dir/| |' /tmp/staging_dir_md5sums.txt > /tmp/staging_dir_md5sums_filtered.txt
sed 's| tmpcurrent/[^\/]*/| |' /tmp/current_dir_md5sums.txt | grep -ve ' \.meta/.*.hashes' > /tmp/current_dir_md5sums_filtered.txt

sort -k 2 /tmp/current_dir_md5sums_filtered.txt -o /tmp/current_dir_md5sums_filtered.txt
sort -k 2 /tmp/staging_dir_md5sums_filtered.txt -o /tmp/staging_dir_md5sums_filtered.txt

diff --color=auto -u /tmp/staging_dir_md5sums_filtered.txt /tmp/current_dir_md5sums_filtered.txt > tmpcmp.diff