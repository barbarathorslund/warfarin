#!/bin/sh
### set erorr and ouput files
###PBS -e /home/projects/cu_10039/people/bartho/warfarin/sh/log/09_flashopca.e
###PBS -o /home/projects/cu_10039/people/bartho/warfarin/sh/log/09_flashopca.o
###set name of the job
#PBS -N 09_flashpca
###set number of nodes, cores memory and time
#PBS -l nodes=l:pnn=16,mem:=75gb,walltime=10:00:00
###send an email when the job is doen
### PBS -m ae -M your.email

module load tools
module load ngs
module load plink2/1.90beta5.4
module load flashpca/2.0

FLASHPCA_OUTPUT_PATH=$1
GENOTYPE_SUBSAMPLE_FILTERED_PRUNED=$2
EXCLUDE_RELATED=$3

cd "${FLASHPCA_OUTPUT_PATH}"

## Remove related individuals
plink --bfile "${GENOTYPE_SUBSAMPLE_FILTERED_PRUNED}" --remove "${EXCLUDE_RELATED}" --make-bed --out kingunrelated

## Keep related only
plink --bfile "${GENOTYPE_SUBSAMPLE_FILTERED_PRUNED}" --keep "${EXCLUDE_RELATED}" --make-bed --out kingrelated

## Run flash PCA on unrelated samples and save the SNP loadings, their means and sd
flashpca --bfile kingunrelated --outload loadings.txt --outmeansd meansd.txt

## Project new samples (unrelated) onto existing PCs (for related)
flashpca --bfile kingrelated --project --inmeansd meansd.txt --outproj projections.txt --inload loadings.txt -v
