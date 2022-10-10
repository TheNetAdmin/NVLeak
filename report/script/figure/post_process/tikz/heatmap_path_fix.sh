#!/bin/bash

# $1 tikz file name

origin_path=$(echo $(basename $1) | sed 's/\.tikz//g')

sed -i "s/$origin_path/figure\/plot\/$origin_path/g" $1
