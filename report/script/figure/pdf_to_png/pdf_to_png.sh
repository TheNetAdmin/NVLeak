#!/bin/bash

TIKZ_FILE=${1}

if [ -z $TIKZ_FILE ]
then
    echo "$0 TIKZ_FILE"
    exit 1
fi

BASE_FILE=$(echo $TIKZ_FILE | sed 's/.pdf//')

PDF_FILE=$BASE_FILE.pdf
PNG_FILE=$BASE_FILE.png

pdftoppm $PDF_FILE $PNG_FILE -png
