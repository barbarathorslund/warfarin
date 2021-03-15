#!/bin/sh
### set error and output files
#PBS -e /home/projects/cu_10039/people/bartho/warfarin/sh/log/05_plink_subsample.e
#PBS -o /home/projects/cu_10039/people/bartho/warfarin/sh/log/05_plink_subsample.o
### set name of the job
#PBS -N plink
### set number of nodes, cores, memory and time
#PBS -l nodes=1:ppn=1,mem=10gb,walltime=4:00:00
### Send an email when the job is done
### PBS -m ae -M your.email@whatever.dk

#Prepare files using plink

module load tools
module load ngs
module load plink2/1.90beta5.4

GENOTYPE_RAW=$1
#/home/projects/cu_10039/data/UKBB/Genotype/EGAD00010001497/ukb
KEEP_SAMPLES=$2
GENOTYPE_SUBSAMPLE=$3

#keep individuals of interest
plink --bfile "${GENOTYPE_RAW}" --keep "${KEEP_SAMPLES}" --make-bed --out "${GENOTYPE_SUBSAMPLE}"

# Potentially: first part of King_2.R to modify the fam file