#!/usr/bin/env -S bash -l

#SBATCH --job-name=evernia_annotate
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=500G
#SBATCH --time=72:00:00

export threads="32"
export analysis_dir="./PAW59641_PAW59566/"

cd "${analysis_dir}"

# Make directories
mkdir -p ./PAW59641_PAW59566_evernia/assemblies/repeat_masked 
mkdir -p ./PAW59641_PAW59566_evernia/assemblies/fasta

# Grab assembly.fasta from flye dir
find assemblies/evernia -maxdepth 1 -name '*barcode*' -type d  -exec sh -c 'export filebase=$(basename $1) && cp $1/assembly.fasta PAW59641_PAW59566_evernia/assemblies/fasta/${filebase%.fastq}.fa' sh {} \;

# Activate conda env
eval "$(conda shell.bash hook)"
conda activate red 

# Run Red to mask repeats
Red -gnm PAW59641_PAW59566_evernia/assemblies/fasta -msk PAW59641_PAW59566_evernia/assemblies/repeat_masked -cor "${threads}"

conda activate funannotate

mkdir -p annotations/evernia
mkdir -p ./PAW59641_PAW59566_evernia/annotation/gff

# Tell funannotate where the database is
export FUNANNOTATE_DB="/exports/nas/data2/Database_Archive/funannotate/2025-03-10-120046"
#export FUNANNOTATE_DB="/exports/hornet/galaxy/LCAB_PROD/galaxy_export/tool-data/funannotate/2025-03-10-120046"

# Run funannotate
find PAW59641_PAW59566_evernia/assemblies/repeat_masked -type f -exec sh -c 'funannotate predict --cpus $threads --input $1 --out PAW59641_PAW59566_evernia/annotation/$(basename $1) --species "Evernia prunastri" --organism "fungus" --name "FUN_" --header_length 100 && ln -s $(realpath PAW59641_PAW59566_evernia/annotation/$(basename $1)/predict_results/Evernia_prunastri.gff3) PAW59641_PAW59566_evernia/annotation/gff/$(basename ${1%.msk}).gff3' sh {} \;
