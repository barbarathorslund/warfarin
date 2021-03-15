add_config <- function(name, value) {
  #' Defines a config variable by enviromental variables or default value
  #'
  #' Provides the name of the config variable
  #' @param name The name of the variable
  #' @param value The value for the config variable
  assign(name, Sys.getenv(name, unset = value), envir = .GlobalEnv)
}

# Main paths
add_config("DATA_DIR", "../data")
add_config("KING_DATA_DIR", "../data/king")
add_config("RAW_DATA_DIR", "../data/raw")
add_config("TEMP_DIR", "../data/temp")
add_config("RESULTS_DIR", "../results/plots")
add_config("PLOTS_DIR", "../results/plots")

# Files

## UKB files

# 01_phenotype.R
add_config("ISSUE_FILE_RAW", paste(RAW_DATA_DIR ,"ukb_gp_scripts.txt", sep= "/"))
add_config("DEFINED_PHENOTYPE", paste(TEMP_DIR, "01_warf_phenotype.txt", sep = "/"))

# 02_metadata.R
add_config("METADATA_FILE_RAW", paste(RAW_DATA_DIR,"ukb_27581.all_fields.h5", sep = '/'))
add_config("METADATA_EXTRACTED", paste(TEMP_DIR, "02_extracted_metadata.txt", sep = "/"))

# 03a_QCtable.R
add_config("SQC_FILE_RAW", paste(RAW_DATA_DIR ,"ukb_sqc_v2.txt.gz", sep= "/"))
add_config("HDR_FILE_RAW", paste(RAW_DATA_DIR ,"ukb_sqc_v2.header.txt.gz", sep= "/"))
add_config("FAM_FILE_RAW", paste(RAW_DATA_DIR ,"ukb_43247_cal_chr1_v2_s488282.fam", sep= "/"))
add_config("GQC_FILE_RAW", paste(RAW_DATA_DIR, "ukb_geneticSampleLevel_QCs_190527.tsv.gz", sep="/"))
add_config("QC_FILTERED", paste(TEMP_DIR, "03_qc_filtered.txt", sep = "/"))
add_config("QC_FILTER_INFO", paste(RESULTS_DIR, "03_qc_filter_info.txt", sep = "/"))

# 04_phenofile.R
add_config("META_QC_SAMPLES", paste(TEMP_DIR, "04_meta_qc_samples.txt", sep = "/"))
add_config("FINAL_PHENOFILE", paste(DATA_DIR, "pheno.txt", sep = "/"))
add_config("FINAL_SUBSAMPLE", paste(DATA_DIR, "subsample_id.txt", sep = "/"))

# 07_king_relatedpairs.R
add_config("KING_KIN_FILE", paste(KING_DATA_DIR, "king.kin", sep = "/"))
add_config("KING_KIN0_FILE", paste(KING_DATA_DIR, "king.kin0", sep = "/"))
add_config("EXCLUDE_RELATED", paste(DATA_DIR, "excluderelated.txt", sep = "/"))

#10_covarfile.R
add_config("META_QC_SAMPLES", paste(TEMP_DIR, "04_meta_qc_samples_df.txt"))
add_config("UNRELATED_PC", paste(DATA_DIR, "pcs.txt", sep ="/"))
add_config("RELATED_PC", paste(DATA_DIR, "projections.txt", sep = "/"))
add_config("COVARFILE", paste(DATA_DIR, "cov.txt", sep = "/"))



