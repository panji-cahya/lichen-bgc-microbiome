#!/usr/bin/env -S bash -l

#SBATCH --job-name=eukarya_binning
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=50G
#SBATCH --time=24:00:00

export threads="12"
export analysis_dir="./PAW59641_PAW59566/PAW59641_PAW59566_eukarya"

cd "${analysis_dir}"

# activate conda 
eval "$(conda shell.bash hook)"

mkdir -p bins/metabat2

# Binning with metabat2
conda activate metabat2

find assemblies/ -name "*.fa*" -type f,l -exec sh -c 'metabat2 -i $(realpath ${1}) -o "bins/metabat2/$(basename ${1%.fasta})" -a fairy_coverage/metabat2/$(basename ${1%.fasta}_metabat2.tsv) -t "${threads}" --unbinned' sh {} \;

# Organize contigs into these folders
mkdir -p unbinned_contigs binned_contigs
find bins/metabat2 -name "*.unbinned.fa" -type f,l -exec sh -c 'ln -rs ${1} unbinned_contigs/$(basename ${1%.unbinned.fa}).fa' sh {} \;
find bins/metabat2 -regextype posix-awk -regex ".*+[0-9]+.fa" -type f,l -exec sh -c 'ln -rs ${1} binned_contigs/$(basename ${1%.fa}).fa' sh {} \;

find assemblies/ -name "*.fa*" -type f,l -exec sh -c 'mkdir -p binned_contigs/$(basename ${1%.fasta}) && mv binned_contigs/$(basename ${1%.fasta})* binned_contigs/$(basename ${1%.fasta})' sh {} \;


