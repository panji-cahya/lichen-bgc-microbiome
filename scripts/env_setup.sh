#!/usr/bin/env -S bash -l

# Create conda environments for this workflow
find lichen_bgc_pipeline/workflow/envs -name "*.yml" -exec conda env create -f {} --yes \;

# Install additional software in some conda environments
eval "$(conda shell.bash hook)"

## multismash
conda activate antismash7
git clone https://github.com/zreitz/multismash.git
cd multismash
pip install .
cd ..

# Fix URL that is sometimes not reachable but is needed to download antismash databases
sed -i 's/PFAM_LATEST_URL = f"https/PFAM_LATEST_URL = f"http/' ~/.conda/envs/antismash7/lib/python3.11/site-packages/antismash/download_databases.py
download-antismash-databases

## bigslice
conda activate bigslice
pip install bigslice
download_bigslice_hmmdb
