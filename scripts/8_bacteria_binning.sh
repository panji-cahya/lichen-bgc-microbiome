#!/usr/bin/env -S bash -l

#SBATCH --job-name=bacteria_binning
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=50G
#SBATCH --time=24:00:00

export threads="12"
export analysis_dir="./PAW59641_PAW59566/PAW59641_PAW59566_bacteria"

cd "${analysis_dir}"

# activate conda 
eval "$(conda shell.bash hook)"

mkdir -p bins/semibin bins/maxbin2 bins/metabat2

# Binning with SemiBin
conda activate semibin

SemiBin2 multi_easy_bin -o bins/semibin/ -i semibin_temp/concatenate_fasta/concatenated.fa.gz -a fairy_coverage/semibin/*.tsv -t "${threads}" 

# Binning with metabat2
conda activate metabat2

find assemblies/ -name "*.fa*" -type f,l -exec sh -c 'metabat2 -i $(realpath ${1}) -o "bins/metabat2/$(basename ${1%.fasta})" -a fairy_coverage/metabat2/$(basename ${1%.fasta}_metabat2.tsv) -t "${threads}"' sh {} \;


# Binning with maxbin2
conda activate maxbin2

find assemblies/ -name "*.fa*" -type f,l -exec sh -c 'run_MaxBin.pl -contig ${1} -out "bins/maxbin2/$(basename ${1%.fasta})" -abund fairy_coverage/maxbin2/$(basename ${1%.fasta}_maxbin2.tsv)' sh {} \;

# Prepare bin sequences for DAS tool

# Activate das tool environment
conda activate dastool

## Loop through all assemblies

for sample in assemblies/*.fasta
    do
        export sample_base=$(basename ${sample%.fasta})

        mkdir -p bin_sequences/${sample_base}/metabat2 bin_sequences/${sample_base}/maxbin2 bin_sequences/${sample_base}/semibin

        ## maxbin2

        # Gather bin fastas
        find bins/maxbin2/ -name "${sample_base}*.fasta" -exec sh -c 'ln -s $(realpath ${1}) bin_sequences/${sample_base}/maxbin2/$(basename ${1})' sh {} \;

        # Make a contig2bin table
        Fasta_to_Contig2Bin.sh -i bin_sequences/${sample_base}/maxbin2/ -e fasta > bin_sequences/${sample_base}/maxbin2_contig2bin.tsv

        ## metabat2

        # Gather bin fastas
        find bins/metabat2 -name "${sample_base}*.fa" -exec sh -c 'ln -s $(realpath ${1}) bin_sequences/${sample_base}/metabat2/$(basename ${1})' sh {} \;

        # Make a contig2bin table
        Fasta_to_Contig2Bin.sh -i bin_sequences/${sample_base}/metabat2/ -e fa > bin_sequences/${sample_base}/metabat2_contig2bin.tsv

        ## semibin

        # Unzip bins
        find bins/semibin/bins/ -name "${sample_base}*.fa.gz" -exec gunzip {} \;

        # Gather bin fastas
        find bins/semibin/bins/ -name "${sample_base}*.fa" -exec sh -c 'ln -s $(realpath ${1}) bin_sequences/${sample_base}/semibin/$(basename ${1})' sh {} \;

        # Make a contig2bin table
        Fasta_to_Contig2Bin.sh -i bin_sequences/${sample_base}/semibin/ -e fa > bin_sequences/${sample_base}/semibin_contig2bin.tsv


        ## Run DAS Tool
        DAS_Tool \
            --write_bins \
            --write_unbinned \
            --score_threshold=0.5 \
            -t ${threads} \
            -i bin_sequences/${sample_base}/maxbin2_contig2bin.tsv,bin_sequences/${sample_base}/metabat2_contig2bin.tsv,bin_sequences/${sample_base}/semibin_contig2bin.tsv \
            -c ${sample} \
            -o ./das_tool/${sample_base}

done

# Organize contigs into these folders
mkdir -p unbinned_contigs binned_contigs
find assemblies -name "*.fa*" -type f,l -exec sh -c 'mkdir -p binned_contigs/$(basename ${1%.fasta}) && if [ -d das_tool/$(basename ${1%.fasta})_DASTool_bins ] ; then ln -rs das_tool/$(basename ${1%.fasta})_DASTool_bins/$(basename ${1%.fasta})*.fa* binned_contigs/$(basename ${1%.fasta})/ && ln -rs das_tool/$(basename ${1%.fasta})_DASTool_bins/unbinned.fa unbinned_contigs/$(basename ${1}) ; else ln -rs ${1} unbinned_contigs/ ; fi' sh {} \;

# Rename .fa to .fasta
find unbinned_contigs -name "*.fa" -type f,l -exec sh -c 'mv ${1} ${1%.fa}.fasta' sh {} \;
find binned_contigs -name "*.fa" -type f,l -exec sh -c 'mv ${1} ${1%.fa}.fasta' sh {} \;
