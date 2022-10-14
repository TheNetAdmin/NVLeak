#!/bin/bash

original_pmdk="" # results from 2_read_only.sh
mitigate_pmdk="" # results from 6_read_only_secure.sh

if [ -z "$original_pmdk" ] || [ -z "$mitigate_pmdk" ]; then
    echo "ERROR: Invalid task ID for PMDK benchmark results"
    echo "       Set original_pmdk and mitigate_pmdk as corresponding folder name under NVLeak/data/side_map_cli/results"
    exit 2
fi


function link_data() {
    ln -s "../../../../data/side_map_cli/results/${1}/memory_layout.csv" "${2}.csv"
}

link_data "${original_pmdk}" original_memory_layout
link_data "${mitigate_pmdk}" mitigate_memory_layout
ln -s "../../../../data/mitigation_benchmark/results/performance.csv" .
