# ==============================================================================
# DATA PREPARATION SCRIPT - FOR DOCUMENTATION ONLY
# ==============================================================================
# This script documents how the deflators data frames were created.
# It should ONLY be run by package maintainers when updating the data.
# End users do NOT need to run this - the data is already included in the package.
#
# Last updated: January 14, 2026
# Data sources: The PCE index comes from BEA Table 2.5.4 line 37.
# It is pulled using the BEA API below.
# The PHCE index comes from National Health Expenditure Accounts Table 23.
# These tables are downloaded from https://www.cms.gov/files/zip/nhe-tables.zip
# Table 23 is included in data-raw.
# ==============================================================================

# ==============================================================================
# VERSIONING APPROACH
# ==============================================================================
# We maintain multiple deflator series so users can:
# 1. Use the most recent data by default
# 2. Access older versions for reproducibility
#
# Naming convention: deflators_YYYY.csv where MM_YYYY month and year the index data were downloaded.
# ==============================================================================

# Download and clean raw files.
# PHCE downloaded from https://www.cms.gov/files/zip/nhe-tables.zip
# PHCE in Table 23
phce_colnames <- colnames(data.table::as.data.table(readxl::read_xlsx(file.path("data-raw", "Table 23 National Health Expenditures; Nominal, Real, Price Indexes.xlsx"), skip = 1)))
phce_colnames[1] <- "Index"
phce <- data.table::as.data.table(readxl::read_xlsx(file.path("data-raw", "Table 23 National Health Expenditures; Nominal, Real, Price Indexes.xlsx"), skip = 38, n_max = 17))
colnames(phce) <- phce_colnames
phce <- phce[Index == "Personal Health Care"]
phce <- data.table::melt(phce, id.vars = "Index", variable.name = "year", value.name = "phce")
phce <- phce[, lapply(.SD, as.character), by = "Index"]
phce <- phce[, lapply(.SD, as.numeric), by = "Index"]

## PCE - Health
## NIPA Table 2.5.4, Line 37
## api defined in .Renviron

beaSpecs <- list(
  'UserID' = Sys.getenv("api") ,
  'Method' = 'GetData',
  'datasetname' = 'NIPA',
  'TableName' = 'T20504',
  'Frequency' = 'A',
  'Year' = paste0(2000:2025, collapse = ", "),
  'ResultFormat' = 'json'
)

pce_health <- data.table::as.data.table(bea.R::beaGet(beaSpecs))
pce_health <- pce_health[LineNumber==37]
cols <- grepl("DataValue", names(pce_health))
pce_health <- data.table::melt(pce_health[, ..cols], variable.name = "year", value.name = "pce_health")
pce_health <- pce_health[, year:=as.numeric(gsub("DataValue_", "", year))]

df <- merge(phce[,.(year, phce)], pce_health, by = "year", all = T)

# PHCE data for 2001-2009 from https://meps.ahrq.gov/about_meps/Price_Index.shtml

df <- df[year == 2001, phce:=69.3]
df <- df[year == 2002, phce:=71.3]
df <- df[year == 2003, phce:=73.7]
df <- df[year == 2004, phce:=76.3]
df <- df[year == 2005, phce:=78.7]
df <- df[year == 2006, phce:=81.1]
df <- df[year == 2007, phce:=83.7]
df <- df[year == 2008, phce:=86.0]
df <- df[year == 2009, phce:=88.3]

df <- df[year>=2000]

write.csv(df, file.path("data-raw", paste0("deflators_", format(Sys.Date(), "%m"), "_", format(Sys.Date(), "%Y"), ".csv")), na = "", row.names = FALSE)

# List all available deflator CSV files
deflator_files <- list.files("data-raw", pattern = "^deflators_.*\\.csv$", full.names = TRUE)

if (length(deflator_files) == 0) {
  stop("No deflator CSV files found in data-raw/")
}

cat("Found", length(deflator_files), "deflator file(s):\n")
print(basename(deflator_files))

# Function to load and validate a deflator file
load_deflator <- function(file_path) {
  df <- read.csv(file_path)

  # Validation
  stopifnot(
    "year column missing" = "year" %in% names(df),
    "pce_health column missing" = "pce_health" %in% names(df),
    "phce column missing" = "phce" %in% names(df),
    "pce_health should be numeric" = is.numeric(df$pce_health),
    "phce should be numeric" = is.numeric(df$phce),
    "years should be integers" = is.numeric(df$year)
  )

  return(df)
}

# Load all deflator versions
deflator_list <- list()

for (file in deflator_files) {
  # Extract version name from filename (e.g., "01_2026" from "deflators_01_2026.csv")
  version_name <- sub("^deflators_", "", sub("\\.csv$", "", basename(file)))

  cat("\nLoading", version_name, "version...\n")
  deflator_list[[version_name]] <- load_deflator(file)

  cat("  Years covered:", min(deflator_list[[version_name]]$year),
      "to", max(deflator_list[[version_name]]$year), "\n")
  cat("  Number of years:", nrow(deflator_list[[version_name]]), "\n")
}

# ==============================================================================
# CREATE DEFAULT DATASET
# ==============================================================================
# The default dataset (deflator_series) uses the most recent version
# Users can access older versions via deflators_MM_YYYY

# Find the most recent version (by filename)
latest_version <- names(deflator_list)[length(deflator_list)]
deflator_series <- deflator_list[[latest_version]]

cat("\n==> Default dataset uses:", latest_version, "version\n")

# Save the default dataset
usethis::use_data(deflator_series, overwrite = TRUE)

# ==============================================================================
# CREATE VERSIONED DATASETS
# ==============================================================================
# Save each version with its specific name so users can access them

for (version in names(deflator_list)) {
  # Create variable name like "deflators_MM_YYYY"
  dataset_name <- paste0("deflators_", version)

  # Assign the data to that variable name
  assign(dataset_name, deflator_list[[version]])

  # Save to package data
  # Note: do.call is needed to pass the variable name dynamically
  do.call(usethis::use_data,
          list(as.name(dataset_name), overwrite = TRUE))

  cat("Created dataset:", dataset_name, "\n")
}

# ==============================================================================
# SUMMARY
# ==============================================================================
cat("\n========================================\n")
cat("Deflator data prepared successfully!\n")
cat("========================================\n")
cat("Default dataset: deflators (", latest_version, " version)\n", sep = "")
cat("Versioned datasets:\n")
for (version in names(deflator_list)) {
  cat("  - deflators_", version, "\n", sep = "")
}
cat("\nUsers can access older versions with:\n")
cat("  data(deflators_MM_YYYY)\n")
cat("========================================\n")

