#!/bin/sh
### set erorr and ouput files
###PBS -e king.e
###PBS -o king.o
###set name of the job
#PBS -N plink_flashPCA
###set number of nodes, cores memory and time
#PBS -l nodes=l:pnn=16,mem:=75gb,walltime=10:00:00
###send an email when the job is doen
### PBS -m ae -M your.email

module load plink2/1.90beta5.4
module load flashpca/2.0

cd ../data

## Plink on individuals to be included
plink --bfile king/unimputed_king --maf 0.05 --hwe 0.001 --geno 0.02 --make-bed --out flashpca/unimputed_king_hwe0.001_maf0.05_geno0.02

plink --bfile flashpca/unimputed_king_hwe0.001_maf0.05_geno0.02 --exclude /home/projects/cu_10039/people/jongho/warfarin/gendata/excludeRegions.txt  --indep-pairwise 200 100 0.2 --out flashpca/indepSNP

plink --bfile flashpca/unimputed_king_hwe0.001_maf0.05_geno0.02 --extract flashpca/indepSNP.prune.in --make-bed --out flashpca/unimputed_king_hwe0.001_maf0.05_geno0.02_pruned

## Remove related individuals
plink --bfile flashpca/unimputed_king_hwe0.001_maf0.05_geno0.02_pruned --remove excluderelated.txt --make-bed --out flashpca/kingunrelated

## Keep related only
plink --bfile flashpca/unimputed_king_hwe0.001_maf0.05_geno0.02_pruned --keep excluderelated.txt --make-bed --out flashpca/kingrelated

## Run flash PCA on unrelated samples and save the SNP loadings, their means and sd
flashpca --bfile flashpca/kingunrelated --outload loadings.txt --outmeansd flashpca/meansd.txt

## Project new samples (unrelated) onto existing PCs (for related)
flashpca --bfile flashpca/kingrelated --project --inmeansd flashpca/meansd.txt --outproj projections.txt --inload loadings.txt -v

# Keep only autosome
plink --bfile flashpca/unimputed_king_hwe0.001_maf0.05_geno0.02_pruned  --autosome --make-bed --out modelSNP

