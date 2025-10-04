#!/bin/sh

toolname=$1
flag=$2

set -e

if [ -z "$toolname" ]; then
    echo "Usage: $0 <toolname> [-r]"
    exit 1
fi

if ! [ -z "$flag" ] && [ "$flag" != "-r" ]; then
    echo "Unknown flag: $flag"
    exit 1
fi

if ! [ -z "$flag" ] && [ "$flag" = "-r" ]; then
    rm -rf tmp/$toolname-after
fi

if [ ! -f tmp/$toolname-after ]; then
    # TODO: this only fetches what is really cleaned up
    make tools/$toolname/clean
    find staging_dir -type f > tmp/$toolname-before
    make tools/$toolname/compile
    find staging_dir -type f > tmp/$toolname-after
fi

diff --color=auto -u tmp/$toolname-before tmp/$toolname-after | grep '^+' | grep -v '^+++' | sed 's,^+,,' | sed 's|^staging_dir/||' | sort > tmp/$toolname.noniso.txt

find tmpcurrent/$toolname/ -type f | sed " s|tmpcurrent/$toolname/||" | grep -ve '^.meta' | sort > tmp/$toolname.iso.txt

diff --color=auto -u tmp/$toolname.noniso.txt tmp/$toolname.iso.txt || true