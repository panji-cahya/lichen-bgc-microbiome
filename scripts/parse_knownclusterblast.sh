#! /usr/bin/env bash


shopt -s globstar
for i in **/knownclusterblast/*.txt; do
    file_basename=$(basename "${i}" | sed -e 's/_c/.region00/' | sed -e 's/.txt/.gbk/') 
    output_barcode=$(echo $i | cut -d '/' -f1)
    top_hits=$(grep -A1 'Significant hits:' "${i}" | sed -e 's/Significant hits: //' | tr '\n' ' ' | sed -e 's/1. //')
    echo "$output_barcode	$file_basename	$top_hits" >> knownclusterblast_summary.tsv
done
