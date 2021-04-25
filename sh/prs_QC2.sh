#Set error and output files
#PBS -e /home/projects/cu_10039/people/bartho/warfarin/sh/log/easyQC.e
#PBS -o /home/projects/cu_10039/people/bartho/warfarin/sh/log/easyQC.o
### set name of the job
#PBS -N easyQC
### set number of nodes, cores, memory and time
#PBS -l nodes=1:ppn=10,mem=10gb,walltime=4:00:00

module load tools
module load ngs
module load gcc
module load intel/perflibs
module load R/4.0.3

cd /home/projects/cu_10039/people/bartho/warfarin/R
Rscript "Rscripts/prs_QC2.R"
