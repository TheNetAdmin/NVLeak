#!/bin/bash

dir=${1:-.}

pushd $dir > /dev/null
find . -name "*.pdf" | grep -v "plot/"
popd > /dev/null
