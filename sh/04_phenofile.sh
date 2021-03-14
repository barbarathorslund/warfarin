#!/bin/sh
### set error and output files
###PBS -e /home/projects/cu_10039/people/bartho/warfarin/sh/log/04_phenofile.e
###PBS -o /home/projects/cu_10039/people/bartho/warfarin/sh/log/04_phenofile.o
### set name of the job
#PBS -N 04_phenofile
### set number of nodes, cores, memory and time
#PBS -l nodes=1:ppn=2,mem=10gb,walltime=00:30:00

module load tools
module load ngs
module load gcc
module load intel/perflibs
module load R/4.0.3

export DEFINED_PHENOTYPE=$1
export METADATA_EXTRACTED=$2
export QC_FILTERED=$3
export META_QC_SAMPLES=$4
export FINAL_PHENOFILE=$5
export FINAL_SUBSAMPLE=$6

cd /home/projects/cu_10039/people/bartho/warfarin/R
Rscript "Rscripts/04_phenofile.R"