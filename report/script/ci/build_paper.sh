#! /bin/bash

this_path="$( cd "$(dirname "$0")" ; pwd -P )"
project_path=$this_path/../../

cd $project_path
latexmk -pdf -f -outdir=out paper.tex || true

tree .

if [[ ! -f out/paper.pdf ]]; then
    echo "No output"
    exit 1
fi
