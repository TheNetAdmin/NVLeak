#!/bin/bash

if [ $# -ne 2 ]; then
    echo "ERROR: expectes two argument but got $#"
    exit 1
fi

cp ../../../../data/covert_inode/results/single/$1/receiver.csv nvram.csv
cp ../../../../data/covert_inode/results/single/$2/receiver.csv dram.csv
