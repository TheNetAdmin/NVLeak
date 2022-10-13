#!/bin/bash

if [ $# -ne 1 ]; then
    echo "ERROR: expectes one argument but got $#"
    exit 1
fi

ln -s ../../../../data/side_map_cli/results/$1/summary.csv summary.csv
