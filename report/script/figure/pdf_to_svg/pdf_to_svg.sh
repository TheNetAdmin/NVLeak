#!/bin/bash

TIKZ_FILE=${1}

if [ -z $TIKZ_FILE ]
then
    echo "$0 TIKZ_FILE"
    exit 1
fi

BASE_FILE=$(echo $TIKZ_FILE | sed 's/.pdf//')

PDF_FILE=$BASE_FILE.pdf
SVG_FILE=$BASE_FILE.svg

outdir=out/$BASE_FILE

pdf2svg $PDF_FILE $SVG_FILE