#!/bin/bash

src_file=$1
dst_file=$2

if [ $# -ne 2 ]; then
    echo "$0 src_file dst_file"
    exit 1
fi

if [ ! -f $src_file ]; then
    echo "File ($src_file) does not exist"
    exit 1
fi

# Commont out abstract environment
abs_file='content/0-abstract.tex'
if [ ! -f $abs_file ]; then
    echo "Abstract file ($abs_file) does not exist"
    exit 1
fi

echo "Preprocessing"
sed -i 's/\\begin{abstract}/\%\\begin{abstract}/g' $abs_file
sed -i 's/\\end{abstract}/\%\\end{abstract}/g' $abs_file
sed -i 's/\\figref/Figure\~\\ref/g' content/*.tex
sed -i 's/\\tabref/Table\~\\ref/g' content/*.tex
sed -i 's/\\secref/Section\~\\ref/g' content/*.tex
sed -i 's/\\para/\\paragraph/g' content/*.tex

pandoc --wrap=none -f latex -t plain $src_file -o $dst_file

echo "Reverting preprocess changes"
sed -i 's/\%\\begin{abstract}/\\begin{abstract}/g' $abs_file
sed -i 's/\%\\end{abstract}/\\end{abstract}/g'     $abs_file
sed -i 's/Figure\~\\ref/\\figref/g'                content/*.tex
sed -i 's/Table\~\\ref/\\tabref/g'                 content/*.tex
sed -i 's/Section\~\\ref/\\secref/g'               content/*.tex
sed -i 's/\\paragraph/\\para/g' content/*.tex


sed -i 's/ \././g' $dst_file
sed -i 's/ \,/,/g' $dst_file
sed -i 's/ \;/;/g' $dst_file
sed -i 's/  / /g' $dst_file
