#!/bin/bash

set -x

if [[ $? -ne 0 ]]; then
    echo "Error: no past tag"
    exit 1
fi

this_path="$( cd "$(dirname "$0")" ; pwd -P )"
cd $this_path/../../
echo $PWD

past_tag=$(git describe --abbrev=0)

curr_commit=$(git rev-parse paper)
past_commit=$(git rev-list -n 1 $past_tag)

if [[ $past_commit == $curr_commit ]]; then
    echo "Latest commit has a tag, compare to last tag"
    past_tag=$(git describe --abbrev=0 $past_tag^)
    past_commit=$(git rev-list -n 1 $past_tag)
fi

$this_path/generate_diff.sh CFONT $past_commit $curr_commit
