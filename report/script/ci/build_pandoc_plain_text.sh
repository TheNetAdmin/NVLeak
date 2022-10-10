#! /bin/sh

this_path="$( cd "$(dirname "$0")" ; pwd -P )"
script=$this_path/../text_process/pandoc_latex_to_plain.sh

sh $script paper.tex paper.txt