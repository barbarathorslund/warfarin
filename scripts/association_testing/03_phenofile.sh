#!/bin/sh
### set error and output files
#PBS -e /home/projects/cu_10039/people/bartho/warfarin/sh/log/03_filter_qc.e
#PBS -o /home/projects/cu_10039/people/bartho/warfarin/sh/log/03_filter_qc.o
### set name of the job
#PBS -N 03_filter_qc
### set number of nodes, cores, memory and time
#PBS -l nodes=1:ppn=2,mem=10gb,walltime=00:30:00

module load tools
module load ngs
module load gcc
module load intel/perflibs
module load R/4.0.3

export DEFINED_PHENOTYPE=$1
export QC_FILTERED=$2
export FINAL_PHENOFILE=$3
export FINAL_SUBSAMPLE=$4

cd /home/projects/cu_10039/people/bartho/warfarin/scripts/association_testing
Rscript "phenofile.R"