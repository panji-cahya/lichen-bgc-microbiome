#!/usr/bin/env -S bash -l

#SBATCH --job-name=bigslice_eukarya
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=200G
#SBATCH --time=24:00:00

export threads="16"
export analysis_dir="./PAW59641_PAW59566/"
export script_dir="$(realpath ./lichen_bgc_pipeline/workflow/scripts/)"
export datasheet="$(realpath ./lichen_bgc_pipeline/workflow/sample_sheet/sample_sheet_bigslice.tsv)"

cd "${analysis_dir}PAW59641_PAW59566_eukarya"


# Reorganize unbinned antismash output
cd unbinned_bgc/
"${script_dir}"/reorganize_antismash_contig.sh 
cd ..

# Reorganize binned antismash output
cd binned_bgc/
"${script_dir}"/reorganize_antismash_bin.sh
cd ..

# Prepare directory for bigslice
mkdir -p bgc/antismash

# Link taxonomy dir
ln -rs taxonomy/ bgc/taxonomy

# Populate bgc/antismash dir with the content of the reorganized antismash outputs from binned and unbinned
cp -r unbinned_bgc/antismash_per_contig/* bgc/antismash/
cp -r binned_bgc/antismash_reorganized/* bgc/antismash/

# Get a copy of the datasheet
cp ${datasheet} ./bgc/datasets.tsv

# Run bigslice
cd bgc/

eval "$(conda shell.bash hook)"
conda activate bigslice

bigslice --complete --threshold 0.4 --n_ranks 1 -i . -t ${threads} bigslice/

cd ..

sqlite3 bgc/bigslice/result/data.db < ${script_dir}/main_table.sql | sed 's/|/_/g' > eukarya_bgcs_bigslice.tsv
