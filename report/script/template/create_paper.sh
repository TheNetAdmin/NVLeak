#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 GITHUB_USER PAPER_NAME"
    echo "E.g. $0 TheNetAdmin paper-awesome"
fi

github_user=$1
paper_name=$2
github_repo=git@github.com:${github_user}/${paper_name}

git clone git@github.com:TheNetAdmin/nap ${paper_name}

cd ${paper_name}
git remote set-url origin ${github_repo}
git push origin -u master
git checkout -b paper
git push origin -u paper

echo "Template initlization is done."
echo "NOTE: Remember to change GitHub default branch to 'paper' before you link it to Overleaf"
