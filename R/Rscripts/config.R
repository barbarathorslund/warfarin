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
add_config("PLOTS_DIR", "../results/plots")

# Files

## UKB files

# 01_phenotype.R
add_config("ISSUE_FILE_INPUT", paste(RAW_DATA_DIR ,"ukb_gp_scripts.txt", sep= "/"))
add_config("WARF_PHENOTYPE_OUTPUT", paste(TEMP_DIR, "01_warf_df.txt", sep = "/"))

# 02_metadata.R
add_config("UKB_SQC_FILE", paste(RAW_DATA_DIR ,"ukb_sqc_v2.txt.gz", sep= "/"))
add_config("UKB_HDR_FILE", paste(RAW_DATA_DIR ,"ukb_sqc_v2.header.txt.gz", sep= "/"))

add_config("UKB_FAM_FILE", paste(RAW_DATA_DIR ,"ukb_43247_cal_chr1_v2_s488282.fam", sep= "/"))
add_config("UKB_GQC_FILE", paste(RAW_DATA_DIR, "ukb_geneticSampleLevel_QCs_190527.tsv.gz", sep="/"))
add_config("UKB_METADATA_FILE", paste(RAW_DATA_DIR,"ukb_27581.all_fields.h5", sep = '/'))