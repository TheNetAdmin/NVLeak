#! /bin/bash

if [ $# -ne 1 ]; then
    echo "ERROR: expect to get one argument as task_id"
    exit 1
fi

python3 data.py pull "${1}"
python3 data.py parse
