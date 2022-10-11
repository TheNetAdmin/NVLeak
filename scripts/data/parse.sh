#!/bin/bash
set -x
set -e

help() {
    echo "Usage $0 BATCH_ID [-h|-c|-u]"
    echo
    echo "options:"
    echo "-h      print this help message."
    echo "-c      clean before each parse."
    echo "-u      update after each parse."
    echo "-s      send progress to slack."
    echo "-m      parse cross-VM covert channel results."
}

if [ $# -eq 0 ] ; then
    echo "Usage $0 BATCH_ID [clean]"
    help
    exit 1
fi

make_jobs=${make_jobs:-8}
id=$1
shift 1
slack=n

while getopts ":hcusm" option; do
    case $option in
        h)
            help
            exit 0
            ;;
        c)
            clean=y
            ;;
        u)
            update=y
            ;;
        s)
            slack=y
            ;;
        m)
            cross_vm_covert=y
            ;;
        \?)
            echo "ERROR: invalid option"
            help
            exit 1
            ;;
    esac
done

if test "${slack}" = "y"; then
    SlackURL="" # Fill with your Slack incoming webhook URL
    if [ -z "$SlackURL" ]; then
        echo "ERROR: Please fill the SlackURL in [$0]"
        exit 2
    fi

    function slack_notice() {
        # $1 Slack URL
        # $2 Slack message
        echo -n "Sending slack message -- ${1}"
        curl -X POST -H 'Content-type: application/json' --data "{'text':'$1'}" "$SlackURL" >/dev/null 2>&1
        echo ""
    }
else
    function slack_notice() {
        echo "$*"
    }
fi

batch_root="${batch_root:-nvleak/results}"
batch_path="${batch_root}/${id}"
parse="../scripts/parse/parse.py"

slack_notice "\`[Start    ]\` Parsing results ${batch_path}"

make_arg=''
if test "${cross_vm_covert}" = "y"; then
    make_arg='-c'
fi

if ! python3 "${parse}" gen-makefile ${make_arg} -b "${batch_path}"; then
    slack_notice "\`[Error    ]\` Failed to generate: ${batch_path}/Makefile"
    exit 1
fi

pushd "${batch_path}" || exit 1


if test "${clean}" = "y"; then
    make clean -j ${make_jobs}
fi

if ! make all -j ${make_jobs}; then
    slack_notice "\`[Error    ]\` Failed to generate all targets: ${batch_path}/Makefile"
    exit 1
fi

if test "${update}" = "y"; then
    if ! make all_update -j ${make_jobs}; then
        slack_notice "\`[Error    ]\` Failed to update all results to MongoDB: ${batch_path}/Makefile"
        exit 1
    fi
fi

popd || exit 1

slack_notice "\`[Finish   ]\` Parsing results ${batch_path}"
