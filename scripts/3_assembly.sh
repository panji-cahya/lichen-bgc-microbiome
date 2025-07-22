#!/usr/bin/env -S bash -l

#SBATCH --job-name=assembly
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=500G
#SBATCH --time=96:00:00

# Set variables
export threads="32"
export analysis_dir="./PAW59641_PAW59566/"

cd "${analysis_dir}"

# Number duplicate read IDs with seqkit
eval "$(conda shell.bash hook)"
conda activate seqkit

find evernia_mapping_reads -type f -exec sh -c 'seqkit rename ${1} > ${1%.fastq}_dedup.fastq' sh {} \;
find non_evernia_reads -type f -exec sh -c 'seqkit rename ${1} > ${1%.fastq}_dedup.fastq' sh {} \;

# Activate conda env
conda activate flye

# Make directory structure
mkdir -p assemblies/evernia assemblies/non-evernia

# Assemble evernia reads
find evernia_mapping_reads -name "*_dedup.fastq" -type f -exec sh -c 'flye --nano-hq $1 --threads $threads --out-dir assemblies/evernia/$(basename ${1%_dedup.fastq}.fastq)' sh {} \;

# Assemble the non-evernia reads
find non_evernia_reads -name "*_dedup.fastq" -type f -exec sh -c 'flye --meta --nano-hq $1 --threads $threads --out-dir assemblies/non-evernia/$(basename ${1%_dedup.fastq}.fastq)' sh {} \;

