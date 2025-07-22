#!/usr/bin/env -S bash -l

#SBATCH --job-name=quality_control_trimming
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=30G
#SBATCH --time=72:00:00


export threads="32"
export analysis_dir="./PAW59641_PAW59566/"

cd "${analysis_dir}"

# Activate the conda environment
eval "$(conda shell.bash hook)"
conda activate hocort

# Build minimap2 index for evernia genome (Currently one is already present in my folder)
# hocort index minimap2 -i /exports/work/duijker.d/reference_genomes/GCA_003184365.1_ASM318436v1_genomic.fna -o /exports/work/duijker.d/reference_genomes//exports/work/duijker.d/reference_genomes/GCA_003184365.1_ASM318436v1_genomic.fna_mm2index -t 24 -p nanopore

# Then export it with the following command (already set to your environment @panji)
export mm2index="/exports/hornet/scratch/mawarda.p/reference_genomes/GCA_003184365.1_ASM318436v1_genomic.fna.mm2index"

# Make directories for folders
mkdir -p evernia_mapping_reads non_evernia_reads

# Get evernia-mapping reads
find ./chopper_filtered/ -type f -exec sh -c 'hocort map minimap2 --index $mm2index --input $1 --preset nanopore --filter false --output ./evernia_mapping_reads/$(basename $1) --threads $threads' sh {} \;

# And get the reads that do not map to evernia
find ./chopper_filtered/ -type f -exec sh -c 'hocort map minimap2 --index $mm2index --input $1 --preset nanopore --filter true --output ./non_evernia_reads/$(basename $1) --threads $threads' sh {} \;
