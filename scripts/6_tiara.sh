#!/usr/bin/env -S bash -l

#SBATCH --job-name=tiara
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=50G
#SBATCH --time=24:00:00

export threads="12"
export analysis_dir="./PAW59641_PAW59566"

cd "${analysis_dir}"

# Make tiara base directory
mkdir -p tiara

# activate conda environment
eval "$(conda shell.bash hook)"
conda activate tiara

# Run tiara
find assemblies/non-evernia/ -maxdepth 1 -mindepth 1 -type d -exec sh -c 'mkdir -p tiara/$(basename ${1%.fastq}) && tiara --threads ${threads} --input $1/assembly.fasta --output tiara/$(basename ${1%.fastq})/main_result.txt --to_fasta bac arc euk' sh {} \;
