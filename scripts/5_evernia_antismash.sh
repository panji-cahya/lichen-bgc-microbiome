#!/usr/bin/env -S bash -l

#SBATCH --job-name=evernia_antismash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=200G
#SBATCH --time=72:00:00

export threads="16"
export analysis_dir="./PAW59641_PAW59566/PAW59641_PAW59566_evernia"

cd "${analysis_dir}"

# Prepare directory for multismash
mkdir -p bgc/input_assembly_and_annotation

# Link input files to the input folder
find annotation/gff/ -name "*.gff3" -exec sh -c 'cp $(realpath $1) bgc/input_assembly_and_annotation/$(basename $1)' sh {} \;
find assemblies/fasta/ -name  "*.fa*" -exec sh -c 'cp $(realpath $1) bgc/input_assembly_and_annotation/$(basename $1)' sh {} \;

# Run multismash
eval "$(conda shell.bash hook)"
conda activate antismash7

ln -s ../../lichen_bgc_pipeline/workflow/config/multismash_evernia.yml .
multismash ./multismash_evernia.yml
