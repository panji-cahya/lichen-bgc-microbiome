#!/usr/bin/env -S bash -l

#SBATCH --job-name=eukarya_annotate
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=24G
#SBATCH --time=72:00:00

export threads="12"
export analysis_dir="./PAW59641_PAW59566/PAW59641_PAW59566_eukarya"

cd "${analysis_dir}"

# Make directories
mkdir -p ./unbinned_contigs_repeat_masked 
mkdir -p ./binned_contigs_repeat_masked

# Activate conda env
eval "$(conda shell.bash hook)"
conda activate red 

# Run Red to mask repeats on unbinned contigs
Red -gnm ./unbinned_contigs -msk unbinned_contigs_repeat_masked -cor "${threads}"

# Only run Red when bins are present (it crashes when the directory is empty)
find ./binned_contigs ! -empty -type d -exec Red -gnm ./binned_contigs -msk binned_contigs_repeat_masked -cor "${threads}" \;

# Activate funannotate environment
conda activate funannotate

# Make annotation directory 
mkdir -p unbinned_annotation/gff binned_annotation/gff

# Tell funannotate where the database is
export FUNANNOTATE_DB="/exports/nas/data2/Database_Archive/funannotate/2025-03-10-120046"

# Run funannotate on the binned sequences
find unbinned_contigs_repeat_masked/ -type f -exec sh -c 'funannotate predict --cpus $threads --input $1 --out unbinned_annotation/$(basename $1) --species "metagenome" --organism "other" --busco_db eukaryota --name "FUN_" --header_length 100 && ln -rs unbinned_annotation/$(basename $1)/predict_results/metagenome.gff3 unbinned_annotation/gff/$(basename ${1%.msk}).gff3' sh {} \;

# And on the unbinned sequences
find binned_contigs_repeat_masked/ -type f -exec sh -c 'funannotate predict --cpus $threads --input $1 --out binned_annotation/$(basename $1) --species "metagenome" --organism "other" --busco_db eukaryota --name "FUN_" --header_length 100 && ln -rs binned_annotation/$(basename $1)/predict_results/metagenome.gff3 binned_annotation/gff/$(basename ${1%.msk}).gff3' sh {} \;
