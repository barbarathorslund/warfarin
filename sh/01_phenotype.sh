#!/bin/sh
### set error and output files
#PBS -e /home/projects/cu_10039/people/bartho/warfarin/sh/log/01_phenotype.e
#PBS -o /home/projects/cu_10039/people/bartho/warfarin/sh/log/01_phenotype.o
### set name of the job
#PBS -N 01_phenotype
### set number of nodes, cores, memory and time
#PBS -l nodes=1:ppn=2,mem=10gb,walltime=00:30:00

module load tools
module load ngs
module load gcc
module load intel/perflibs
module load R/4.0.3

export ISSUE_FILE_RAW=$1
export DEFINED_PHENOTYPE=$2

cd /home/projects/cu_10039/people/bartho/warfarin/R
Rscript "Rscripts/define_phenotype.R"
