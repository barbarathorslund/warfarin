#!/bin/sh
### set error and output files
###PBS -e /home/projects/cu_10039/people/bartho/warfarin/sh/log/02_metadata.e
###PBS -o /home/projects/cu_10039/people/bartho/warfarin/sh/log/02_metadata.o
### set name of the job
#PBS -N 02_metadata
### set number of nodes, cores, memory and time
#PBS -l nodes=1:ppn=2,mem=10gb,walltime=00:30:00

module load tools
module load ngs
module load gcc
module load intel/perflibs
module load R/4.0.3

export METADATA_FILE=$1
export METADATA_OUTPUT=$2

cd /home/projects/cu_10039/people/bartho/warfarin/R
Rscript "Rscripts/02_metadata.R"

