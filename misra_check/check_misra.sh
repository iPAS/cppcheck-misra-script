#!/bin/bash
# uncomment to echo *fully* expanded script commands to terminal
# set -x


get_abs_filename() {
  # $1 : relative filename
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

script_folder=$(get_abs_filename "$(dirname $(readlink -f $0))")

# Initialize variables with defaults
source_folders=()                            # -s, --source
out_folder=""                               # -o, --out
cppcheck_path="$script_folder/../cppcheck"  # -c, --cppcheck
quiet=0                                     # -q, --quiet
output_xml=0                                # -x, --xml
output_html=0                               # --html
clean_old_tempdir=0                         # --clean

function parse_command_line() {
  while [ $# -gt 0 ] ; do
    args=()
    # for arg in "$@"; do echo "arg: $arg"; done; exit
    for arg in "$@"; do args+=( "$arg" ); done;

    case "$1" in
      -s | --source)
        # Have to use absolute paths for source:
        # 1. CPPCheck (or the shell) expands globs to absolute paths.
        # 2. CPPCheck matches paths from the command line using simple string comparisons
        #   2.1. E.g. exclusion folders
        # source_folders+=( "$2" )
        source_folders+=( "${args[1]}" )
        # source_folders+=( $(get_abs_filename "$2") )
        ;;
      -o | --out) out_folder="$2" ;;
      -c | --cppcheck) cppcheck_path="$2" ;;
      -q | --quiet) quiet=1 ;;
      -x | --xml) output_xml=1 ;;
      --html) output_html=1; output_xml=1 ;;
      --html_out) html_folder="$2" ;;
      --html_title) html_title="$2" ;;
      --clean) clean_old_tempdir=1 ;;
      -*)
        echo "Unknown option: " $1
        exit 1
        ;;
    esac
    shift
  done
}

# for arg in "$@"; do echo "arg: $arg"; done; exit
parse_command_line "$@"

[[ ${#source_folders[@]} -eq 0 ]] && source_folders+="'$script_folder/..'"
for s in "${source_folders[@]}"; do
    echo "$s"
done

out_folder_prefix=misra_check-out
[[ $clean_old_tempdir -gt 0 ]] && trash ${out_folder_prefix}.*

[[ -z "${out_folder}" ]] && out_folder=$(mktemp -d ${out_folder_prefix}.XXX)
[[ ! -d "${out_folder}" ]] && echo "Cannot access the output directory: ${out_folder}" && exit 255

cppcheck_bin="${cppcheck_path}/cppcheck"
cppcheck_misra="${cppcheck_path}/addons/misra.py"
cppcheck_html="${cppcheck_path}/htmlreport/cppcheck-htmlreport"

[[ -z "$html_title"  ]] && html_title="xxx"
[[ -z "$html_folder" ]] && html_folder="$out_folder"

num_cores=`getconf _NPROCESSORS_ONLN`
let num_cores--
num_cores=$(nproc)

mkdir -p "$out_folder"
echo '{"script": "misra.py","args": ["--rule-texts='"$script_folder"'/misra_2012_text.txt"]}' > "$out_folder/misra.json"

cppcheck_parameters=( --inline-suppr
                      # --language=c++
                      --enable=warning
                      --enable=information
                      --enable=performance
                      --enable=portability
                      --enable=style
                      # --addon="$script_folder/misra.json"
                      --addon="$out_folder/misra.json"
                      --suppressions-list="$script_folder/suppressions.txt"
                      --suppress=unusedFunction:*
                      --suppress=missingInclude:*
                      --suppress=missingIncludeSystem:*
                      --suppress=unmatchedSuppression:*
                      --suppress=cstyleCast:*
                      # --platform=avr8
                      --cppcheck-build-dir="$out_folder"
                      -j "$num_cores"

                      # All violations from included libraries (*src* folders) are ignored
                      # --suppress="*:$source_folders/*"

                      # Don't parse the /src folder
                      # -i "$source_folders"
                      # "$source_folders/**.ino"
                      # "$source_folders/**.c"
                      # "$source_folders/**.cpp"
                      # "$source_folders"
                      )

for s in "${source_folders[@]}"; do
  cppcheck_parameters+=( "$s" )  # Add source code folders
done

cppcheck_out_file="$out_folder/results.txt"
if [ $output_xml -eq 1 ]; then
  cppcheck_out_file="$out_folder/results.xml"
  cppcheck_parameters+=(--xml)
fi

"$cppcheck_bin" ${cppcheck_parameters[@]} 2> $cppcheck_out_file

[[ $output_html -gt 0 ]] && \
"$cppcheck_html" --file="$cppcheck_out_file" --source-dir="$source_folders" --title="$html_title" --report-dir="$html_folder"

# Count lines for Mandatory or Required rules
error_count=`grep -i "Mandatory - \|Required - " < "$cppcheck_out_file" | wc -l`

if [ $quiet -eq 0 ]; then
  cat "$cppcheck_out_file"
fi
echo $error_count MISRA violations
echo $error_count > "$out_folder/error_count.txt"

echo "All output files are in $out_folder"
echo "Result: $cppcheck_out_file"
# ls "${out_folder}"

exit 0
