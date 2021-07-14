#!/bin/sh
### set error and output files
#PBS -e /home/projects/cu_10039/people/bartho/warfarin/sh/log/ANN_extract.e
#PBS -o /home/projects/cu_10039/people/bartho/warfarin/sh/log/ANN_extract.o
### set name of the job
#PBS -N ANN_extract
### set number of nodes, cores, memory and time
#PBS -l nodes=1:ppn=10,mem=32gb,walltime=48:00:00
### Send an email when the job is done
### PBS -m ae -M barbarathorslund@hotmail.com

#Prepare files using plink
module load tools
module load ngs
module load plink2/2.00alpha20180331

path=/home/projects/cu_10039/people/bartho/warfarin/data/ukb/ANN/pics_causal
extract_snplist=pics_rs.snplist

cd $path

# Extract relevant SNPs of typed data
plink2 \
    --bfile ../../genotype/modelSNP \
    --make-bed \
    --out extract_typed \
    --extract $extract_snplist

# Extract individuals from imputed data
plink2 \
  --bgen /home/projects/cu_10039/data/UKBB/downloadDump/EGAD00010001474/ukb_imp_chr10_v3.bgen \
  --sample /home/projects/cu_10039/data/UKBB/Imputed/ukb43247_imp_chr1_v3_s487320.sample  \
  --keep ../sample_ids.txt \
  --extract $extract_snplist \
  --make-bed \
  --out extract_imp_chr10

plink2 \
  --bgen /home/projects/cu_10039/data/UKBB/downloadDump/EGAD00010001474/ukb_imp_chr16_v3.bgen \
  --sample /home/projects/cu_10039/data/UKBB/Imputed/ukb43247_imp_chr1_v3_s487320.sample  \
  --keep ../sample_ids.txt \
  --extract $extract_snplist \
  --make-bed \
  --out extract_imp_chr16

plink2 \
  --bgen /home/projects/cu_10039/data/UKBB/downloadDump/EGAD00010001474/ukb_imp_chr19_v3.bgen \
  --keep ../sample_ids.txt \
  --sample /home/projects/cu_10039/data/UKBB/Imputed/ukb43247_imp_chr1_v3_s487320.sample  \
  --extract $extract_snplist \
  --make-bed \
  --out extract_imp_chr19
 
