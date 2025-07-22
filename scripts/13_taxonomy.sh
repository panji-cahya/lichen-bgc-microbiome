#!/usr/bin/env -S bash -l

#SBATCH --job-name=bgc_taxonomy
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=500G
#SBATCH --time=72:00:00
#SBATCH -o taxonomy-%j.out
#SBATCH -e taxonomy-%j.error

export threads="32"
export analysis_dir="./PAW59641_PAW59566"
export catpack_tax="/exports/nas/data2/Database_Archive/CATBAT/20241212_CAT_nr_website/tax"
export catpack_db="/exports/nas/data2/Database_Archive/CATBAT/20241212_CAT_nr_website/db"

cd "${analysis_dir}"

eval "$(conda shell.bash hook)"
conda activate CAT_pack

# Start with bacteria taxonomy
cd PAW59641_PAW59566_bacteria

mkdir -p unbinned_taxonomy binned_taxonomy

# Unbinned
find unbinned_contigs/ -type f,l -exec sh -c 'mkdir -p unbinned_taxonomy/$(basename ${1%.fasta}) && CAT_pack contigs -c ${1} -d ${catpack_db} -t ${catpack_tax} -n "${threads}" --out_prefix unbinned_taxonomy/$(basename ${1%.fasta})/out.CAT' sh {} \;

# Binned
mkdir -p binned_taxonomy/
find binned_contigs/ -mindepth 1 -maxdepth 1 -type d -exec sh -c 'mkdir -p binned_taxonomy/$(basename ${1}) && CAT_pack bins -b ${1} -d ${catpack_db} -t ${catpack_tax} --bin_suffix ".fasta" -n "${threads}" --out_prefix binned_taxonomy/$(basename ${1})/out.BAT' sh {} \;

# Add taxa names
## unbinned
find unbinned_taxonomy -name "*contig2classification.txt" -type f -exec sh -c 'CAT_pack add_names -i ${1} -o ${1%.txt}.names.txt -t ${catpack_tax} --only_official' sh {} \;
## binned
find binned_taxonomy -name "*bin2classification.txt" -type f -exec sh -c 'CAT_pack add_names -i ${1} -o ${1%.txt}.names.txt -t ${catpack_tax} --only_official' sh {} \;

Parse named taxonomy files into taxonomy format for bigslice
# unbinned
find unbinned_taxonomy -name "*contig2classification.names.txt" -type f -exec sh -c 'cat ${1} | cut -f1,6,7,8,9,10,11,12 | perl -pe "s/: \d+.\d+//g" | perl -pe "s/(contig_\d+)/\1\//g" | sed "s/# contig	superkingdom	phylum	class	order	family	genus	species/# Genome folder	Kingdom	Phylum	Class	Order	Family	Genus	Species	Organism/" > $(dirname ${1})/taxonomy_sheet.tsv' sh {} \;

## binned
mkdir -p binned_taxonomy/per_barcode binned_taxonomy/per_barcode_temp

# Gather all info in one sheet
find binned_taxonomy -name "*bin2classification.names.txt" -type f -exec sh -c 'cat ${1} | cut -f1,6,7,8,9,10,11,12 | perl -pe "s/: \d+.\d+//g" | sed "s/\./_/g" | sed "s/.fasta//" | awk "BEGIN{FS=\"\\t\"} {split(\$1,p,\"_barcode\"); split(p[2],b,\"_\"); print p[1] \"_barcode\" b[1] \"\\t\" b[2] b[3] \"\\t\" \$2 \"\\t\" \$3 \"\\t\" \$4 \"\\t\" \$5 \"\\t\" \$6 \"\\t\" \$7 \"\\t\" \$8}" | tail -n+2 >> binned_taxonomy/combined_sheet.tsv' sh {} \;

# Split this sheet into separate files per barcode 
cat binned_taxonomy/combined_sheet.tsv | awk -F"\t" "NR==1{for(i=1;i<=NF;i++)printf(\"%s\t\", \$i)} NR>0{print \$0 >> (\"binned_taxonomy/per_barcode_temp/\" \$1 \".tsv\")}"

# Remove the first column and add '/' character for the split files from the step above
find binned_taxonomy/per_barcode_temp/ -name "*.tsv" -type f -exec sh -c 'cat ${1} | cut -f2,3,4,5,6,7,8,9 | sed "s/\t/\/\t/" > binned_taxonomy/per_barcode/$(basename ${1})' sh {} \;

# Merge the taxonomy tables so we have one table per sample that includes both binned (bins) and unbinned (contigs)

mkdir -p taxonomy

find unbinned_taxonomy -mindepth 1 -maxdepth 1 -type d -exec sh -c 'cp ${1}/taxonomy_sheet.tsv taxonomy/$(basename ${1}) && cat binned_taxonomy/per_barcode/$(basename ${1}).tsv >> taxonomy/$(basename ${1})' sh {} \;


# Then eukaryote taxonomy
cd ../PAW59641_PAW59566_eukarya

mkdir -p unbinned_taxonomy binned_taxonomy

# Unbinned
find unbinned_contigs/ -type f,l -exec sh -c 'mkdir -p unbinned_taxonomy/$(basename ${1%.fasta}) && CAT_pack contigs -c ${1} -d ${catpack_db} -t ${catpack_tax} -n "${threads}" --out_prefix unbinned_taxonomy/$(basename ${1%.fasta})/out.CAT' sh {} \;

# Binned
mkdir -p binned_taxonomy/
find binned_contigs/ -mindepth 1 -maxdepth 1 -type d -exec sh -c 'mkdir -p binned_taxonomy/$(basename ${1}) && CAT_pack bins -b ${1} -d ${catpack_db} -t ${catpack_tax} --bin_suffix ".fasta" -n "${threads}" --out_prefix binned_taxonomy/$(basename ${1})/out.BAT' sh {} \;

# Add taxa names
## unbinned
find unbinned_taxonomy -name "*contig2classification.txt" -type f -exec sh -c 'CAT_pack add_names -i ${1} -o ${1%.txt}.names.txt -t ${catpack_tax} --only_official' sh {} \;
## binned
find binned_taxonomy -name "*bin2classification.txt" -type f -exec sh -c 'CAT_pack add_names -i ${1} -o ${1%.txt}.names.txt -t ${catpack_tax} --only_official' sh {} \;

Parse named taxonomy files into taxonomy format for bigslice
# unbinned
find unbinned_taxonomy -name "*contig2classification.names.txt" -type f -exec sh -c 'cat ${1} | cut -f1,6,7,8,9,10,11,12 | perl -pe "s/: \d+.\d+//g" | perl -pe "s/(contig_\d+)/\1\//g" | sed "s/# contig	superkingdom	phylum	class	order	family	genus	species/# Genome folder	Kingdom	Phylum	Class	Order	Family	Genus	Species	Organism/" > $(dirname ${1})/taxonomy_sheet.tsv' sh {} \;

## binned
mkdir -p binned_taxonomy/per_barcode binned_taxonomy/per_barcode_temp

# Gather all info in one sheet
find binned_taxonomy -name "*bin2classification.names.txt" -type f -exec sh -c 'cat ${1} | cut -f1,6,7,8,9,10,11,12 | perl -pe "s/: \d+.\d+//g" | sed "s/\./_/g" | sed "s/.fasta//" | awk "BEGIN{FS=\"\\t\"} {split(\$1,p,\"_barcode\"); split(p[2],b,\"_\"); print p[1] \"_barcode\" b[1] \"\\t\" b[2] b[3] \"\\t\" \$2 \"\\t\" \$3 \"\\t\" \$4 \"\\t\" \$5 \"\\t\" \$6 \"\\t\" \$7 \"\\t\" \$8}" | tail -n+2 >> binned_taxonomy/combined_sheet.tsv' sh {} \;

# Split this sheet into separate files per barcode 
cat binned_taxonomy/combined_sheet.tsv | awk -F"\t" "NR==1{for(i=1;i<=NF;i++)printf(\"%s\t\", \$i)} NR>0{print \$0 >> (\"binned_taxonomy/per_barcode_temp/\" \$1 \".tsv\")}"

# Remove the first column and add '/' character for the split files from the step above
find binned_taxonomy/per_barcode_temp/ -name "*.tsv" -type f -exec sh -c 'cat ${1} | cut -f2,3,4,5,6,7,8,9 | sed "s/\t/\/\t/" > binned_taxonomy/per_barcode/$(basename ${1})' sh {} \;

# Merge the taxonomy tables so we have one table per sample that includes both binned (bins) and unbinned (contigs)

mkdir -p taxonomy

find unbinned_taxonomy -mindepth 1 -maxdepth 1 -type d -exec sh -c 'cp ${1}/taxonomy_sheet.tsv taxonomy/$(basename ${1}) && cat binned_taxonomy/per_barcode/$(basename ${1}).tsv >> taxonomy/$(basename ${1})' sh {} \;
