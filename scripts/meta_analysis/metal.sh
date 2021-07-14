module load tools
module load ngs
module load metal/20180828

cd /home/projects/cu_10039/people/bartho/warfarin/results/meta

metal << EOT

CUSTOMVARIABLE N
LABEL N as N

# Input columns:
MARKER RS
ALLELE EFFECT_ALLELE OTHER_ALLELE
EFFECT BETA
STDERR SE
FREQLABEL EAF
PVAL PVAL
WEIGHT N

# Metal Options:
SCHEME STDERR
WEIGHT N
USESTRAND OFF
AVERAGEFREQ ON
MINMAXFREQ ON
VERBOSE OFF

GENOMICCONTROL OFF

PROCESS /home/projects/cu_10039/people/bartho/warfarin/data/ukb/ukb_warf_sumstat_mergedPVAL.txt
PROCESS /home/projects/cu_10039/people/bartho/warfarin/data/chb/chb_warf_sumstat_mergedPVAL.txt


ANALYZE HETEROGENEITY

QUIT
