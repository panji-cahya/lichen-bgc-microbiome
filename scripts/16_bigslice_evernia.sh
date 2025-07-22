#!/usr/bin/env -S bash -l

#SBATCH --job-name=bigslice_evernia
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=200G
#SBATCH --time=24:00:00

export threads="16"
export analysis_dir="./PAW59641_PAW59566/"
export script_dir="$(realpath ./lichen_bgc_pipeline/workflow/scripts/)"
export datasheet="$(realpath ./lichen_bgc_pipeline/workflow/sample_sheet/sample_sheet_bigslice.tsv)"
export evernia_taxonomy="$(realpath ./lichen_bgc_pipeline/workflow/sample_sheet/evernia_taxonomy.tsv)"

cd "${analysis_dir}PAW59641_PAW59566_evernia"


# Reorganize antismash output
cd bgc/
"${script_dir}"/reorganize_antismash_evernia.sh 
cd ..

# Create dummy taxonomy for evernia
mkdir -p bgc/taxonomy
find assemblies/ -name "*.fa" -exec sh -c 'cp "${evernia_taxonomy}" bgc/taxonomy/$(basename ${1%.fa})' sh {} \;

# Get a copy of the datasheet
cp ${datasheet} ./bgc/datasets.tsv

# Replace old antismash folder with reorganized one
mv bgc/antismash bgc/antismash_base
mv bgc/antismash_reorganized bgc/antismash

# Run bigslice
cd bgc/

eval "$(conda shell.bash hook)"
conda activate bigslice

bigslice --complete --threshold 0.4 --n_ranks 1 -i . -t ${threads} bigslice/

cd ..

sqlite3 bgc/bigslice/result/data.db < ${script_dir}/main_table.sql | sed 's/|/_/g' > evernia_bgcs_bigslice.tsv
