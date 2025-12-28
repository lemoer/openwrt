#!/bin/sh

set -e

# can be e.g. host/bin/pkgconf
toolpath=$1

tmpname=$(find -L tmpcurrent | grep -e "$toolpath\$")

diffoscope --text-color=always staging_dir/$toolpath $tmpname | less --raw-control-chars