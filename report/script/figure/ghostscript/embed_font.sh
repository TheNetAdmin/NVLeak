#!/bin/bash

set -e
set -u

# $1 src_pdf
# $2 dst_pdf

if [ $# -ne 2 ]; then
    echo "process_pdf needs two arguments but got $#"
    exit 2
fi

src_pdf="$1"
dst_pdf="$2"

gs \
    -q \
    -dNOPAUSE \
    -dBATCH \
    -dPDFSETTINGS=/prepress \
    -sDEVICE=pdfwrite \
    -sOutputFile="${dst_pdf}" \
    "${src_pdf}" \
;
