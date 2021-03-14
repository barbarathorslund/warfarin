#!/bin/sh
### set error and output files
###PBS -e plink.e
###PBS -o plink.o
### set name of the job
#PBS -N plink
### set number of nodes, cores, memory and time
#PBS -l nodes=1:ppn=1,mem=10gb,walltime=4:00:00
### Send an email when the job is done
### PBS -m ae -M your.email@whatever.dk

#Prepare files using plink

module load plink2/1.90beta5.4

cd ../data

#keep individuals of interest

plink --bfile /home/projects/cu_10039/data/UKBB/Genotype/EGAD00010001497/ukb --keep ukb_warf_subsample.txt --make-bed --out king/unimputed_king

# Now open King_2.R and modify the fam file
