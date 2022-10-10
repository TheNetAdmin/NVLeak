#!/bin/bash

set -x

this_path="$( cd "$(dirname "$0")" ; pwd -P )"
project_path=$this_path/../../

cd $project_path

diff_style=${1:-CFONT}
old_commit=${2:-b27035} # ISCA submission ID
new_commit=${3:-$(git rev-parse paper)}
draft_version=${4:-false}

git diff --quiet || exit 3

old_tag=$(git describe --exact-match --abbrev=0 $old_commit)
if [[ $? -ne 0 ]]; then
    echo "old_commit $old_commit does not have a tag"
    old_tag=$(git describe $old_commit)
fi

if [[ $(git rev-list -n 1 $new_commit) == $(git rev-parse paper) ]]; then
    new_tag="latest"
else
    new_tag=$(git describe --exact-match --abbrev=0 $new_commit)
    if [[ $? -ne 0 ]]; then
        echo "new_commit $new_commit does not have a tag"
        new_tag=$(git describe $new_commit)
    fi
fi

new_tag=$(git describe --exact-match --abbrev=0 $new_commit)
if [[ $? -ne 0 ]]; then
    if [[ $(git rev-list -n 1 $new_commit) == $(git rev-parse paper) ]]; then
        new_tag="latest"
    else
        echo "new_commit $new_commit does not have a tag"
        new_tag=$(git describe $new_commit)
    fi
fi

diff_fname=diff-[$old_tag]-[$new_tag]

echo old_commit $old_commit
echo new_commit $new_commit

rm -rf diffout diff.tex

if [[ $draft_version == 'false' ]]; then
    # for texfile in content/*.tex; do
    #     sed -r -i "s/\\\\hl//g" $texfile || true
    # done
    config_file="config/paper.cls"
    sed -i "s/\\\\setboolean{revisedversion\}{true\}/\\\\setboolean{revisedversion\}{false\}/g" "${config_file}"
fi

# latexdiff-vc --git --force --only-changes \
#              --config="PICTUREENV=(?:picture|DIFnomarkup|table|figure)[\w\d*@]*" \
#              --flatten -d diffout --type=$diff_style \
#              -r $old_commit \
#              -r $new_commit \
#              paper.tex \
# ;

            #  --append-textcmd="hl" \ # https://tex.stackexchange.com/a/478135

# Remove the '-r $new_commit' to compare the dirty current commit to previous commit
latexdiff-vc --git --force --only-changes \
             --flatten -d diffout --type=$diff_style \
             -r $old_commit \
             paper.tex \
;

ls -l diffout

fname=diffout/$(ls diffout | grep '.tex')
echo "Post processing $fname"

perl -pi.bak0 -e 's/\|clwb\|/clwb/'           $fname
perl -pi.bak1 -e 's/\|mkpt\|/mkpt/'           $fname
perl -pi.bak2 -e 's/\|fio\|/fio/'             $fname
perl -pi.bak3 -e 's/section\{/section\[\]\{/' $fname
perl -pi.bak4 -e 's/\\\\\\vspace\{/\\vspace\{/' $fname

if [[ $draft_version == 'false' ]]; then
    sed -r -i "s/publicversion\}\{.*\}/publicversion\}\{true\}/" config/paper.cls || true
    sed -r -i "s/revisedversion\}\{.*\}/revisedversion\}\{false\}/" config/paper.cls || true
    # sed -r -i "s/newcommand\{\\\hl\}.*/newcommand\{\\\hl\}\[1\]\{\#1\}/" config/paper.cls || true
    # sed -r -i "s/\\\DIFaddbegin\ \\\hl\{/\\\DIFaddbegin\ \\\DIFadd\{/" $fname || true
    # diff_fname=$diff_fname-[pub]
fi


cp $fname ./diff.tex
latexmk -shell-escape -pdf -f -outdir=diffout diff.tex
if [ ! -f diffout/diff.pdf ]; then
    echo "ERROR: diffout/diff.pdf doesn't exist"
    exit 1
fi
mv diffout/diff.pdf diffout/$diff_fname.pdf

rm -f diff.tex
git checkout .
