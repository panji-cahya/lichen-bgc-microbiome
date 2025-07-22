#! /usr/bin/env bash


#find . -name '*region*gbk' -exec bash -c "cp {} eval $(echo {} | cut -d '.' -f3 | sed -e 's@/antismash@antismash_per_contig@')"  \;

shopt -s globstar
for i in **/*region*gbk; do
    output_directory=$(echo $i | cut -d '.' -f1 | sed -e 's@antismash@antismash_per_contig@')
    mkdir -p "${output_directory}"
    cp "${i}" "${output_directory}"
done
