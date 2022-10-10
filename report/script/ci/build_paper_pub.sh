#! /bin/bash

this_path="$( cd "$(dirname "$0")" ; pwd -P )"
project_path=$this_path/../../

cd $project_path

sed -r -i "s/publicversion\}\{.*\}/publicversion\}\{true\}/" config/utils.tex || true

latexmk -pdf -f -outdir=out paper.tex

tree .

if [[ ! -f out/paper.pdf ]]; then
    echo "No output"
    exit 1
fi

mv out/paper.pdf out/paper-pub.pdf
