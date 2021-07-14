#!/bin/sh
### set error and output files
###PBS -e /home/projects/cu_10039/people/bartho/warfarin/sh/log/10_covarfile.e
###PBS -o /home/projects/cu_10039/people/bartho/warfarin/sh/log/10_covarfile.o
### set name of the job
#PBS -N 10_covarfile
### set number of nodes, cores, memory and time
#PBS -l nodes=1:ppn=2,mem=10gb,walltime=00:30:00

module load tools
module load ngs
module load gcc
module load intel/perflibs
module load R/4.0.3

export META_QC_SAMPLES=$1
export UNRELATED_PC=$2
export RELATED_PC=$3
export COVARFILE=$4

cd /home/projects/cu_10039/people/bartho/warfarin/R
Rscript "Rscripts/10_covarfile.R"