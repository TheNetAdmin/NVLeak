#!/bin/bash

if [ $# -ne 2 ]; then
    echo "ERROR: expect to get two arguments: task_id and signal_id"
    exit 1
fi

python3 data.py pull "${1}"
python3 data.py parse

python3 signal.py pull-data "${2}"
