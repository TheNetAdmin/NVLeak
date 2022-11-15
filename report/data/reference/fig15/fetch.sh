#!/bin/bash

if [ $# -ne 1 ]; then
    echo "ERROR: expectes one argument but got $#"
    exit 1
fi

ln -sf ../../../../data/side_wolfssl/results/$1/summary.csv summary.csv
