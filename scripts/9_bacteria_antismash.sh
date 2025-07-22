#!/usr/bin/env -S bash -l

#SBATCH --job-name=bacteria_antismash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=230G
#SBATCH --time=24:00:00

export threads="16"
export analysis_dir="./PAW59641_PAW59566/PAW59641_PAW59566_bacteria"

cd "${analysis_dir}"

# activate conda 
eval "$(conda shell.bash hook)"
conda activate antismash7

# Link the multismash config from the pipeline dir to the analysis dir
ln -rs ../../lichen_bgc_pipeline/workflow/config/multismash_bacteria*.yml .

# Run multismash
multismash ./multismash_bacteria_binned.yml

multismash ./multismash_bacteria_unbinned.yml



