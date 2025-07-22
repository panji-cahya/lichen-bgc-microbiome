# lichen-bgc-microbiome pipeline

## Getting started
This repository contains a pipeline for a merged flowcell [PAW59641 (without adaptive sequencing) and PAW59566 (with adaptive sequencing)] to mine biosynethetic gene clusters from Evernia prunastri genome + metagenome

## Folder Description

1. `sample_sheet` contains `.tsv` files specifying folder paths for taxonomy and antiSMASH used in Big-SLiCE analyses, as well as the taxonomy table of *Evernia prunastri*.
2. `config` contains `.yml` files used to run MultiSMASH analyses for the *Evernia* genome, bacterial MAGs, eukaryotic MAGs, bacterial contigs, and eukaryotic contigs.
3. `envs` contains `.yml` files for installing the required Conda environments.
4. `scripts` includes all scripts from quality control to Big-SLiCE analyses, following the numbering from `0_data_prep.sh` to `16_bigliche_evernia.sh`.

You should set up the scripts and environments as follows:
(Make sure your conda environment is already set up with `conda init`)

```bash
chmod +x ./lichen_bgc_pipeline/workflow/scripts*

./lichen_bgc_pipeline/workflow/scripts/env_setup.sh

```

Then run the scripts from the current directory via sbatch (on slurm)

```bash
sbatch ./lichen_bgc_pipeline/workflow/scripts/0_data_prep.sh
```

and etc for the other steps.
