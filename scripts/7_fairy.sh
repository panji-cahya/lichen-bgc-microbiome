#!/usr/bin/env -S bash -l

#SBATCH --job-name=fairy
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=50G
#SBATCH --time=24:00:00

export threads="32"
export analysis_dir="./PAW59641_PAW59566"

cd "${analysis_dir}"

# Activate fairy environment
eval "$(conda shell.bash hook)"
conda activate fairy

# Make directory
mkdir -p non_evernia_fairy_read_sketches

# Sketch reads
fairy sketch --reads non_evernia_reads/* --sample-output-directory non_evernia_fairy_read_sketches -t "${threads}"

# Make directories for bacteria and eukarya
mkdir -p PAW59641_PAW59566_bacteria/fairy_coverage/metabat2
mkdir -p PAW59641_PAW59566_bacteria/fairy_coverage/maxbin2
mkdir -p PAW59641_PAW59566_bacteria/fairy_coverage/semibin

mkdir -p PAW59641_PAW59566_eukarya/fairy_coverage/metabat2

# Get the tiara categorized contigs and put them in the folders below
mkdir -p PAW59641_PAW59566_bacteria/assemblies/ PAW59641_PAW59566_eukarya/assemblies/

# Link bacteria tiara assembly files to the bacteria folder
find tiara/ -mindepth 1 -maxdepth 1 -type d -exec sh -c 'ln -s $(realpath $1)/bacteria_assembly.fasta PAW59641_PAW59566_bacteria/assemblies/$(basename $1).fasta' sh {} \;

# Link eukarya tiara assembly files to the eukarya folder
find tiara/ -mindepth 1 -maxdepth 1 -type d -exec sh -c 'ln -s $(realpath $1)/eukarya_assembly.fasta PAW59641_PAW59566_eukarya/assemblies/$(basename $1).fasta' sh {} \;

# Fairy coverage for bacteria (three binner formats)

## metabat2 format
find PAW59641_PAW59566_bacteria/assemblies/ -name "*.fa*" -type f,l -exec sh -c 'fairy coverage -t "${threads}" non_evernia_fairy_read_sketches/*.bcsp $1 > PAW59641_PAW59566_bacteria/fairy_coverage/metabat2/$(basename ${1%.fasta})_metabat2.tsv' sh {} \;

## maxbin2 format
find PAW59641_PAW59566_bacteria/assemblies/ -name "*.fa*" -type f,l -exec sh -c 'fairy coverage -t "${threads}" --maxbin-format non_evernia_fairy_read_sketches/*.bcsp $1 > PAW59641_PAW59566_bacteria/fairy_coverage/maxbin2/$(basename ${1%.fasta})_maxbin2.tsv' sh {} \;

## semibin format (need some preprocessing with SemiBin2 commands)
conda activate semibin
SemiBin2 concatenate_fasta --input-fasta PAW59641_PAW59566_bacteria/assemblies/*.fasta --output PAW59641_PAW59566_bacteria/semibin_temp/concatenate_fasta/
SemiBin2 split_contigs --input-fasta PAW59641_PAW59566_bacteria/semibin_temp/concatenate_fasta/concatenated.fa.gz --output PAW59641_PAW59566_bacteria/semibin_temp/split_contigs/

conda activate fairy

find non_evernia_fairy_read_sketches/ -name "*.bcsp" -type f,l -exec sh -c 'fairy coverage -t "${threads}" --aemb-format $(realpath $1) PAW59641_PAW59566_bacteria/semibin_temp/split_contigs/split_contigs.fna.gz > PAW59641_PAW59566_bacteria/fairy_coverage/semibin/$(basename ${1%.fastq.bcsp})_semibin2.tsv' sh {} \;

# Fairy coverage for eukarya (only metabat2)
find PAW59641_PAW59566_eukarya/assemblies/ -name "*.fa*" -type f,l -exec sh -c 'fairy coverage -t "${threads}" non_evernia_fairy_read_sketches/*.bcsp $1 > PAW59641_PAW59566_eukarya/fairy_coverage/metabat2/$(basename ${1%.fasta})_metabat2.tsv' sh {} \;
