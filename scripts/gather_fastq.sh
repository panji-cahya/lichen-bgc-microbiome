#!/usr/bin/env bash

# Variables
fastq_dir=""
output_dir=""
samples=()

usage() {
    cat << EOF
Usage: $0 --fastq_dir <directory> [ --samples <sample_array> ] [--output_dir <dir>]
Options:
  -f, --fastq_dir    Path to the nanopore fastq directory (required)
  -s, --samples      Optional: Array of sample numbers like {01..10} 41 {45..61}
  -o, --output_dir   Optional: Output directory for results (default is current dir)
EOF
    exit 1
}

# Parse options with getopts
while getopts "f:s:o:" opt; do
    case $opt in
        f)
            fastq_dir="$OPTARG"
            ;;
 

        s)
            samples=($OPTARG) # Store the sample array as a bash array
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

# Validate required argument
if [[ -z "$fastq_dir" ]]; then
    echo "Error: --fastq_dir is required"
    usage
fi

# Handle output directory (default to current dir)
if [[ -z "$output_dir" ]]; then
    output_dir="."
fi

samples=$(eval echo $samples | tr " " "\n" | awk '{printf "barcode%02d ", $1}')
export output_dir=$output_dir

mkdir -p $output_dir

# Loop through each sample and process (e.g., run fastqc or any other tool)
for sample in $samples; do
    echo "Processing sample: $sample"
    # Example: process fastq file (you can replace this with your logic)
    barcode_dir="${fastq_dir}fastq_pass/$sample/"
    find $barcode_dir -type f -exec sh -c 'zcat $1 >> $output_dir/$(echo $(basename $1) | cut -d "_" -f1,3 | sed "s/$/.fastq/")' sh {} \;
done

echo "Processing complete."
