#!/bin/sh
### set error and output files
###PBS -e Rscript.e
###PBS -o Rscript.o
### set name of the job
#PBS -N Rscript
### set number of nodes, cores, memory and time
#PBS -l nodes=1:ppn=2,mem=10gb,walltime=4:00:00

while [ "$1" != "" ]; do
    case $1 in
        -cp | --computerome ) computerome=1 ;;
    esac
    shift
done

if [ "$computerome" == "1" ]; then
  module load tools
  module load ngs
  module load gcc
  module load intel/perflibs
  module load R/4.0.3
cd $PBS_O_WORKDIR

else
  alias R="/Library/Frameworks/R.framework/Versions/4.0/Resources/bin/R"
fi

# Set working directory to R folder
cd "../R"


# Run scripts
echo "Running Rscript"

#R < "Rscripts/01_phenotype.R" --no-save
#R < "Rscripts/02_metadata.R" --no-save
#R < "Rscripts/03a_QCtable.R" --no-save
#R < "Rscripts/04_pheno_file.R" --no-save
#R < "Rscripts/05_king.R" --no-save
R < "Rscripts/easyQC.R" --no-save

echo "Finished without errors"
