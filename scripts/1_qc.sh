#!/usr/bin/env -S bash -l

#SBATCH --job-name=quality_control_trimming
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=30G
#SBATCH --time=48:00:00
#SBATCH -o quality_control_trimming-%j.out
#SBATCH -e quality_control_trimming-%j.error

# Set variables 
export quality="10"
export threads="24"
export analysis_dir="./PAW59641_PAW59566/"
export fastqdir="./fastq"

cd "${analysis_dir}"

# Activate the nanopack environment
eval "$(conda shell.bash hook)"
conda activate nanopack

# Create directory structure
mkdir -p chopper_filtered nanocomp/pre_filter nanocomp/post_filter

# Run NanoComp on pre-filtered reads
NanoComp --threads ${threads} --fastq "${fastqdir}"/* --outdir nanocomp/pre_filter

# Run Chopper to filter on quality (set quality value above to modify the desired Q score)
find "${fastqdir}" -type f -exec sh -c 'chopper --input $1 --quality "${quality}" --threads "${threads}" > chopper_filtered/$(basename $1)' sh {} \;

# Run NanoComp on post-filtered reads
NanoComp --threads ${threads} --fastq ./chopper_filtered/* --outdir nanocomp/post_filter
