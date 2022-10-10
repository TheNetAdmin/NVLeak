#!/bin/bash

file=$1

# gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile=$file.compressed.pdf $file
ps2pdf -dPDFSETTINGS=/ebook $file $file.compressed.pdf
