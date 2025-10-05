#!/bin/sh

set -e

for file in $(ls tmpreprod/tmpcurrent/); do
    diff --color=auto -u tmpcurrent/$file/.meta/output.hashes tmpreprod/tmpcurrent/$file/.meta/output.hashes || true
done