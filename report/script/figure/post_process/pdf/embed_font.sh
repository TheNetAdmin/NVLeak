#!/bin/bash

set -e
set -u

if [ $# -ne 1 ]; then
    echo "process_pdf needs one arguments but got $#"
    exit 2
fi

dir="$(dirname "$1")"

pushd "$dir" || exit 2

src_pdf="$(basename "$1")"
tmp_pdf="${src_pdf}.emb.pdf"

gs \
    -q \
    -dNOPAUSE \
    -dBATCH \
    -dPDFSETTINGS=/prepress \
    -sDEVICE=pdfwrite \
    -sOutputFile="${tmp_pdf}" \
    "${src_pdf}" \
;

mv "${tmp_pdf}" "${src_pdf}"

popd
