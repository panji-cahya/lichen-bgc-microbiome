#!/usr/bin/env -S bash -l

#SBATCH --job-name=bgc_gather_data
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G
#SBATCH --time=96:00:00
#SBATCH -o bgc_gather_data_step1-%j.out
#SBATCH -e bgc_gather_data_step1-%j.error

export threads="8"
barcodes="01 02 04 05 07 08 09 10"

SCRIPTDIR="./lichen_bgc_pipeline/workflow/scripts"

# Make a directory for this analysis in the current directory
mkdir -p ./PAW59641_PAW59566 ./PAW59641_PAW59566/fastq ./PAW59641_PAW59566/unmerged_fastq

# Obtain fastqs from both flowcells

# Flowcell paths:
# Run 1                     - /exports/nas/data2/Sequence_Archive/20250220_1424_P2S-02265-A_PAW59641_63fae0ff
# Run 2 (adaptive sampling) - /exports/nas/data2/Sequence_Archive/20250522_1351_P2S-02265-A_PAW59566_a7960b05

PATH_PAW59641="/exports/nas/data2/Sequence_Archive/20250220_1424_P2S-02265-A_PAW59641_63fae0ff/"
PATH_PAW59566="/exports/nas/data2/Sequence_Archive/20250522_1351_P2S-02265-A_PAW59566_a7960b05/"

# Gather reads for both flowcells
for barcode in ${barcodes}; do
    ${SCRIPTDIR}/gather_fastq.sh -f $PATH_PAW59641 -s ${barcode} -o ./PAW59641_PAW59566/unmerged_fastq
    ${SCRIPTDIR}/gather_fastq.sh -f $PATH_PAW59566 -s ${barcode} -o ./PAW59641_PAW59566/unmerged_fastq
done

# Get list of reads that were depleted using adaptive sampling
${SCRIPTDIR}/adaptive_sampling_remove_depleted_reads.sh -s ${PATH_PAW59566}/sequencing_summary_PAW59566_a7960b05_fa6d5d8d.txt -o ./PAW59641_PAW59566/

# Use seqkit to keep only fully sequenced molecules (state is 'signal_positive' in MinKNOW/nanopore sequencer)
eval "$(conda shell.bash hook)"
conda activate seqkit

find ./PAW59641_PAW59566/unmerged_fastq/ -name "*.fastq" -type f -exec sh -c 'seqkit grep --threads "${threads}" --pattern-file ./PAW59641_PAW59566/keep_signal_positive_read_ids.txt $1 > ./PAW59641_PAW59566/fastq/PAW59641_PAW59566_$(basename $1 | cut -d "_" -f2)' sh {} \;

# Append PAW59641 to complete the dataset
find ./PAW59641_PAW59566/unmerged_fastq/ -type f -name "*.fastq" -type f -exec sh -c 'cat $1 >> ./PAW59641_PAW59566/fastq/PAW59641_PAW59566_$(basename $1 | cut -d "_" -f2)' sh {} \;

# After getting the merged dataset of both flowcells, you can manually delete the gathered fastqs to save space, if necessary
# rm ./PAW59641_PAW59566/unmerged_fastq/*
# rmdir ./PAW59641_PAW59566/unmerged_fastq/
