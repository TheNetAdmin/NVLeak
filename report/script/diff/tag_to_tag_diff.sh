#!/bin/bash

set -x

this_path="$( cd "$(dirname "$0")" ; pwd -P )"
cd $this_path/../../
echo $PWD

curr_tag=$(git describe --exact-match --abbrev=0)
if [[ $? -ne 0 ]]; then
    echo "Error: current commit does not have a tag"
    exit 1
fi

past_tag=$(git describe --abbrev=0 $curr_tag^)
if [[ $? -ne 0 ]]; then
    echo "Error: no past tag"
    exit 1
fi

curr_commit=$(git rev-list -n 1 $curr_tag)
past_commit=$(git rev-list -n 1 $past_tag)

this_path="$( cd "$(dirname "$0")" ; pwd -P )"
$this_path/generate_diff.sh CFONT $past_commit $curr_commit
