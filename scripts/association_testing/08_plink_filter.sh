#!/bin/sh
### set erorr and ouput files
###PBS -e /home/projects/cu_10039/people/bartho/warfarin/sh/log/08_plink_filter.e
###PBS -o /home/projects/cu_10039/people/bartho/warfarin/sh/log/08_plink_filter.o
###set name of the job
#PBS -N plink_flashPCA
###set number of nodes, cores memory and time
#PBS -l nodes=l:pnn=16,mem:=75gb,walltime=10:00:00
###send an email when the job is doen
### PBS -m ae -M your.email

module load tools
module load ngs
module load plink2/1.90beta5.4

GENOTYPE_OUTPUT_PATH=$1
GENOTYPE_SUBSAMPLE=$2
EXCLUDE_REGIONS=$3
#/home/projects/cu_10039/people/jongho/warfarin/gendata/excludeRegions.txt
GENOTYPE_SUBSAMPLE_FILTERED_PRUNED=$4
MODEL_SNP=$5

cd "${GENOTYPE_OUTPUT_PATH}"

## Plink on individuals to be included. Filtering on maf, hwe, geno and pruning to keep independent SNPs
plink --bfile "${GENOTYPE_SUBSAMPLE}" --maf 0.05 --hwe 0.001 --geno 0.02 --make-bed --out genotype_subsample_filtered

plink --bfile genotype_subsample_filtered --exclude "${EXCLUDE_REGIONS}" --indep-pairwise 200 100 0.2 --out indepSNP

plink --bfile genotype_subsample_filtered --extract indepSNP.prune.in --make-bed --out "${GENOTYPE_SUBSAMPLE_FILTERED_PRUNED}"

# Keep only autosome
plink --bfile "${GENOTYPE_SUBSAMPLE_FILTERED_PRUNED}" --autosome --make-bed --out "${MODEL_SNP}"

