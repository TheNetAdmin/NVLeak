#!/bin/bash

set -e
set -x
set -u

function copy_data() {
    if [ $# -ne 1 ]; then
        echo "ERROR: copy_data() expects one argument to use as sub-dir"
        exit 1
    fi
    sub_dir="${1}"
    mkdir -p "${sub_dir}"
    pushd "${sub_dir}" || exit 2
    rsync -avr "nv-4:/home/usenix/NVLeak/${sub_dir}/results" .
    popd || exit 2
}

copy_data lens
copy_data nvleak
