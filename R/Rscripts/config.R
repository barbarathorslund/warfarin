add_config <- function(name, value) {
  #' Defines a config variable by environmental variables or default value
  #'
  #' Provides the name of the config variable
  #' @param name The name of the variable
  #' @param value The value for the config variable
  assign(name, Sys.getenv(name, unset = value), envir = .GlobalEnv)
}

# Main paths
add_config("DATA_DIR", "../data/ukb")
add_config("KING_DATA_DIR", "../data/ukb/king")
add_config("RAW_DATA_DIR", "../data/ukb/raw")
add_config("RINTER_DIR", "../data/ukb/Rinter")
add_config("PRS_DATA_DIR", "../data/ukb/prs")
add_config("RESULTS_DIR", "../results")
add_config("PLOTS_DIR", "../results/plots")
add_config("BOLT_OUT_DATA_DIR", "../data/ukb/bolt_out")
add_config("EASYQC_OUT_DATA_DIR", "../data/ukb/easyQC_out")

# Files

## UKB files

# define_phenotype.R
add_config("ISSUE_FILE_RAW", paste(RAW_DATA_DIR ,"ukb_gp_scripts.txt", sep= "/"))
add_config("DEFINED_PHENOTYPE", paste(RINTER_DIR, "defined_phenotype.txt", sep = "/"))

# QC_filter.R
add_config("SQC_FILE_RAW", paste(RAW_DATA_DIR ,"ukb_sqc_v2.txt.gz", sep= "/"))
add_config("HDR_FILE_RAW", paste(RAW_DATA_DIR ,"ukb_sqc_v2.header.txt.gz", sep= "/"))
add_config("FAM_FILE_RAW", paste(RAW_DATA_DIR ,"ukb_43247_cal_chr1_v2_s488282.fam", sep= "/"))
add_config("GQC_FILE_RAW", paste(RAW_DATA_DIR, "ukb_geneticSampleLevel_QCs_190527.tsv.gz", sep="/"))
add_config("QC_FILTERED", paste(RINTER_DIR, "qc_filtered.txt", sep = "/"))
add_config("QC_FILTER_INFO", paste(RESULTS_DIR, "qc_filter_info.txt", sep = "/"))

# phenofile.R
add_config("FINAL_PHENOFILE", paste(RINTER_DIR, "pheno.txt", sep = "/"))
add_config("FINAL_SUBSAMPLE", paste(RINTER_DIR, "subsample_id.txt", sep = "/"))

# king_relatedpairs.R
add_config("KING_KIN_FILE", paste(KING_DATA_DIR, "king.kin", sep = "/"))
add_config("KING_KIN0_FILE", paste(KING_DATA_DIR, "king.kin0", sep = "/"))
add_config("EXCLUDE_RELATED", paste(KING_DATA_DIR, "excluderelated.txt", sep = "/"))

# covarfile.R
add_config("METADATA_FILE_RAW", paste(RAW_DATA_DIR,"ukb45051.all_fields.h5", sep = '/'))
add_config("UNRELATED_PC", paste(DATA_DIR, "flashpca/pcs.txt", sep ="/"))
add_config("RELATED_PC", paste(DATA_DIR, "flashpca/projections.txt", sep = "/"))
add_config("COVARFILE", paste(RINTER_DIR, "cov.txt", sep = "/"))

# 12_merge_bolt.R

##----------------------------------------------------------------------------------------
## metaanalysis

# easyQC.R
add_config("COMBINED_BOLT", paste(BOLT_OUT_DATA_DIR, "ukb_combined_bolt_out.txt",  sep = "/"))
add_config("COMBINED_BOLT_V2", paste(BOLT_OUT_DATA_DIR, "ukb_combined_bolt_v2.tsv", sep = "/"))
add_config("RSMID_FILE", paste(RAW_DATA_DIR, "rsmid_machsvs_mapb37.1000G_p3v5.merged_mach_impute.v3.corrpos.gz", sep = "/"))
add_config("SUM_STAT_PRE_RSANN", paste(EASYQC_OUT_DATA_DIR, "CLEANED.warf.txt", sep = "/"))
add_config("SUM_STAT_POST_RSANN", paste(DATA_DIR, "ukb_warf_sumstat.txt", sep = "/"))

##----------------------------------------------------------------------------------------
## PRS

# prs_stroke_event.R
add_config("PRS_STROKE_SUBSAMPLE_ID", paste(PRS_DATA_DIR,"prs_stroke_idsubset.txt", sep= "/"))
add_config("PRS_STROKE_PHENO", paste(PRS_DATA_DIR, "prs_stroke_pheno.txt",  sep = "/"))

# prs_stroke_covar.R
add_config("PRS_STROKE_PC", paste(PRS_DATA_DIR, "flashpca_stroke/pcs.txt",  sep = "/"))
add_config("PRS_STROKE_COVAR", paste(PRS_DATA_DIR, "prs_stroke_covar.txt",  sep = "/"))

# prs_bleed_event.R
add_config("PRS_BLEED_SUBSAMPLE_ID", paste(PRS_DATA_DIR,"prs_bleed_idsubset.txt", sep= "/"))
add_config("PRS_BLEED_PHENO", paste(PRS_DATA_DIR, "prs_bleed_pheno.txt",  sep = "/"))

# prs_bleed_covar.R
add_config("PRS_BLEED_PC", paste(PRS_DATA_DIR, "flashpca_bleed/pcs.txt",  sep = "/"))
add_config("PRS_BLEED_COVAR", paste(PRS_DATA_DIR, "prs_bleed_covar.txt",  sep = "/"))

# prs_model.R
add_config("PRS_STROKE_PROFILE", "../data/prs/plink_stroke/prs.5e-08.profile")
add_config("PRS_BLEED_PROFILE", "../data/prs/plink_bleed/prs.5e-08.profile")

# PICS2.R
add_config("PICS2_CHR10", "../results/PICS2/PICS2_chr10_results.txt")
add_config("PICS2_CHR16", "../results/PICS2/PICS2_chr16_results.txt")
add_config("PICS2_CHR19", "../results/PICS2/PICS2_chr19_results.txt")
