#!/usr/bin/env -S bash -l

#SBATCH --job-name=eukarya_antismash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=200G
#SBATCH --time=72:00:00

export threads="16"
export analysis_dir="./PAW59641_PAW59566/PAW59641_PAW59566_eukarya"

cd "${analysis_dir}"


# Prepare directory for multismash
mkdir -p unbinned_bgc/input_assembly_and_annotation
mkdir -p binned_bgc/input_assembly_and_annotation

# Link input files to the input folder
find unbinned_annotation/gff/ -name "*.gff3" -exec sh -c 'cp $(realpath $1) unbinned_bgc/input_assembly_and_annotation/$(basename $1)' sh {} \;
find binned_annotation/gff/ -name "*.gff3" -exec sh -c 'cp $(realpath $1) binned_bgc/input_assembly_and_annotation/$(basename $1)' sh {} \;

find unbinned_contigs/ -name  "*.fa*" -exec sh -c 'cp $(realpath $1) unbinned_bgc/input_assembly_and_annotation/$(basename $1)' sh {} \;
find binned_contigs/ -name  "*.fa*" -exec sh -c 'cp $(realpath $1) binned_bgc/input_assembly_and_annotation/$(basename $1)' sh {} \;

# activate conda 
eval "$(conda shell.bash hook)"
conda activate antismash7

# Link the multismash config from the pipeline dir to the analysis dir
ln -rs ../../lichen_bgc_pipeline/workflow/config/multismash_eukarya*.yml .

# Run multismash
multismash ./multismash_eukarya_binned.yml

multismash ./multismash_eukarya_unbinned.yml
