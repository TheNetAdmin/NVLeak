#!/bin/bash

set -x
set -u

function copy_data() {
    if [ $# -ne 2 ]; then
        echo "ERROR: copy_data() expects two arguments but got $#"
        exit 1
    fi
    sub_dir="${1}"
    data_dir="${2}"
    mkdir -p "${data_dir}"
    pushd "${data_dir}" || exit 2
    rsync -avr "nv-4:/home/usenix/NVLeak/${sub_dir}/results" .
    popd || exit 2
}

copy_data lens   ./lens
copy_data nvleak ./nvleak
copy_data nvleak/user/covert_channel/cross_vm           ./covert_cross_vm
copy_data nvleak/user/covert_channel/inode              ./covert_inode
copy_data nvleak/user/side_channel/sqlite               ./side_sqlite
copy_data nvleak/user/side_channel/map_cli              ./side_map_cli
copy_data nvleak/user/side_channel/wolfssl              ./side_wolfssl
copy_data nvleak/user/side_channel/mitigation_benchmark ./mitigation_benchmark
