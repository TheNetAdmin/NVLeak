#!/bin/bash

set -x

if [ $# -ne 2 ]; then
    echo "ERROR: expect to get two arguments: task_id and signal_id"
    exit 1
fi

python3 data.py "${1}"
python3 pull_signal.py "${2}"
