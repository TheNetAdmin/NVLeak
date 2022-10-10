#!/bin/bash

TIKZ_FILE=${1}

if [ -z $TIKZ_FILE ]
then
    echo "$0 TIKZ_FILE"
    exit 1
fi

BASE_FILE=$(basename $(echo $TIKZ_FILE | sed 's/.tikz//'))
BASE_DIR=$(dirname $TIKZ_FILE)
TEX_PREFIX=$(echo $BASE_DIR | sed 's/\//-/g')
TEX_FILE=$TEX_PREFIX-$BASE_FILE.tex
PDF_FILE=$TEX_PREFIX-$BASE_FILE.pdf

FIGURE_DIR=$(realpath .)

outdir=out/$BASE_DIR/$BASE_FILE
mkdir -p $outdir

pushd $outdir || exit 2
ln -s $FIGURE_DIR figure >/dev/null 2>&1
popd || exit 2

cat << EOF >$TEX_FILE
\documentclass[tikz]{standalone}

%\fontfamily{aer}
\usepackage[T1]{fontenc}
\usepackage[scaled=.92]{helvet}
\usepackage{amsfonts}
\usepackage{mathptmx}
\usepackage{pgfplots}
\tikzstyle{every picture}+=[font=\sffamily]
%\usepgfplotslibrary{external}
%\tikzexternalize

\begin{document}
\input{$TIKZ_FILE}
\end{document}
EOF

latexmk -xelatex -shell-escape -pdf -silent -outdir=$outdir $TEX_FILE
mv $outdir/$PDF_FILE $BASE_DIR/$BASE_FILE.tikz.pdf

rm -f $TEX_FILE
