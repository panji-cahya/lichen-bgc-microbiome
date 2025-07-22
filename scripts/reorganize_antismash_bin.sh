#! /usr/bin/env bash


#find . -name '*region*gbk' -exec bash -c "cp {} eval $(echo {} | cut -d '.' -f3 | sed -e 's@/antismash@antismash_per_contig@')"  \;

shopt -s globstar
for i in **/*region*gbk; do
    output_barcode=$(echo $i | cut -d '/' -f2 | sed 's/\./_/g' | cut -d '_' -f1,2,3)
    output_bin=$(echo $i | cut -d '/' -f2 | sed 's/\./_/g' | cut -d '_' -f4- )
    output_file=$(basename $i)
    output_directory="antismash_reorganized/${output_barcode}/${output_bin}/"
    output_path="${output_directory}/${output_file}"
    mkdir -p "${output_directory}"
    cp "${i}" "${output_path}"
done
