#!/bin/bash

ref_file=$1

if [ ! -f $ref_file ]; then
    echo "File not exists $ref_file"
    exit 1
fi

trim_entris=(
    isbn
    location
    pages
    numpages
    doi
    acmid
    publisher
    address
    keywords
    month
    abstract
    ISSN
    issn
    volume
    number
    eprint
    timestamp
    archivePrefix
    Date-Added
    Date-Modified
    Pages
    issue_date
    articleno
    eprint
    primaryClass
    organization
    edition
)

for i in ${trim_entris[@]}; do
    sed -i "/\s*${i}.*/d" $ref_file
done
