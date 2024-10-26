#!/bin/bash
# uncomment to echo *fully* expanded script commands to terminal
# set -x


get_abs_filename() {
    # $1 : relative filename
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

script_folder=$(get_abs_filename "$(dirname $(readlink -f $0))")

"${script_folder}"/misra_check/check_misra.sh --quiet --clean "$@"
