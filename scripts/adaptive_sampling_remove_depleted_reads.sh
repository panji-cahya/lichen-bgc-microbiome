#!/usr/bin/env bash

usage() {
    cat << EOF
Usage: $0 --sequencing_summary_file <directory> --output_dir <dir>
Options:
  -s, --sequencing_summary_file      From nanopore sequencing directory
  -o, --output_dir      Output directory for results (default is current dir)
EOF
    exit 1
}

# Parse options with getopts
while getopts "s:o:" opt; do
    case $opt in
        s)
            sequencing_summary_file="$OPTARG"
            ;;

        o)
            output_dir="$OPTARG"
            ;; 

        *)
            echo "Invalid option: -$opt" >&2
            usage
            exit 1
            ;;
    esac
done

mkdir -p $output_dir

tail -n+2 ${sequencing_summary_file} | \
    cut -f21,5,24 | awk '$2 == "signal_positive" && $3 != "unclassified" && $3 != "-"' | cut -f1 > $output_dir/keep_signal_positive_read_ids.txt
