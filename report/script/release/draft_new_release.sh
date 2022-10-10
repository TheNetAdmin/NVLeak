#!/bin/bash

# set -x

old_ver=$(perl -lne ' print $2 if /(\{\\draftversion\}\{)([\d\.]+)(\})/' config/utils.tex)
new_ver=$1

if [ -z $new_ver ]
then
  echo "No new version specified, current version $old_ver"
  echo "Usage: $0 version_number (e.g 1)"
  exit 1
fi

conf=micro20

tag_base=$conf-ver

old_tag=$(git describe --abbrev=0)
new_tag=$tag_base$new_ver

google_drive_base_dir="Paper Build/[Paper] NVRAM Simulator"
google_drive_releases_dir=$google_drive_base_dir/releases

echo "Ver change: $old_ver ==> $new_ver"
echo "Tag change: $old_tag ==> $new_tag"
echo "Google Drive mkdir: $google_drive_releases_dir/$new_tag"
echo "Press any key to proceed"
read

# Local Operation
echo "Press any key to update draftversion in config/utils.tex"
read
sed -r -i "s/draftversion\}\{$old_ver/draftversion\}\{$new_ver/" config/utils.tex || true
cat config/utils.tex | grep draftversion

# Google Drive Operation
echo "Press any key to  update google drive"
read

skicka mkdir -p "$google_drive_releases_dir"
skicka mkdir -p "$google_drive_releases_dir/$new_tag"

# Git Operation
commit_msg="[$conf] Update draft version to $new_ver"
echo "Git Commit Message: $commit_msg"
git status

echo "Press any key to commit"
read
git add config/utils.tex
git commit -am "$commit_msg"

echo "Press any key to tag current commit"
read
git tag -a -m "$commit_msg" "$new_tag"
git push
git push --tags
