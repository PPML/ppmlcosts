# ==============================================================================
# COST INPUT PREPARATION SCRIPT - FOR DOCUMENTATION ONLY
# ==============================================================================
# This script handles version updates to cost parameters.
# It should ONLY be run by cost data maintainers when updating parameters.
# End users do NOT need to run this - the data is already included in the package.
#
# Last updated: January 19, 2026
# ==============================================================================

# ==============================================================================
# VERSIONING APPROACH
# ==============================================================================
# We maintain multiple cost parameter sheets so users can:
# 1. Use the most recent data by default
# 2. Access older versions for reproducibility
#
# Naming convention: costs_MM_YYYY.csv where MM_YYYY month and year the cost parameters were modified.
# ==============================================================================

df <- data.table::fread(file.path("data-raw", "cost_parameters.csv"))

write.csv(df, file.path("data-raw", paste0("costs_", format(Sys.Date(), "%m"), "_", format(Sys.Date(), "%Y"), ".csv")), na = "", row.names = FALSE)

# List all available deflator CSV files
cost_files <- list.files("data-raw", pattern = "^costs_.*\\.csv$", full.names = TRUE)

if (length(cost_files) == 0) {
  stop("No cost CSV files found in data-raw/")
}

cat("Found", length(cost_files), "cost file(s):\n")
print(basename(cost_files))

# Function to load and validate a deflator file
load_costs <- function(file_path) {
  df <- read.csv(file_path)

  # Validation
  stopifnot(
    "parameter column missing" = "parameter" %in% names(df),
    "value column missing" = "value" %in% names(df),
    "timestep column missing" = "timestep" %in% names(df),
    "year column missing" = "year" %in% names(df),
    "source column missing" = "source" %in% names(df),
    "description column missing" = "description" %in% names(df),
    "documentation column missing" = "documentation" %in% names(df),
    "parameter should be character" = is.character(df$parameter),
    "value should be numeric" = is.numeric(df$value),
    "year should be integer" = is.integer(df$year),
    "timestep should be character" = is.character(df$timestep),
    "source should be character" = is.character(df$source)
  )

  return(df)
}

# Load all deflator versions
cost_list <- list()

for (file in cost_files) {
  # Extract version name from filename (e.g., "01_2026" from "deflators_01_2026.csv")
  version_name <- sub("^costs_", "", sub("\\.csv$", "", basename(file)))

  cat("\nLoading", version_name, "version...\n")
  cost_list[[version_name]] <- load_costs(file)
}

# ==============================================================================
# CREATE DEFAULT DATASET
# ==============================================================================
# The default dataset (cost_params) uses the most recent version
# Users can access older versions via deflators_MM_YYYY

# Find the most recent version (by filename)
latest_version <- names(cost_list)[length(cost_list)]
cost_params <- cost_list[[latest_version]]

cat("\n==> Default dataset uses:", latest_version, "version\n")

# Save the default dataset
usethis::use_data(cost_params, overwrite = TRUE)

# ==============================================================================
# CREATE VERSIONED DATASETS
# ==============================================================================
# Save each version with its specific name so users can access them

for (version in names(cost_list)) {
  # Create variable name like "deflators_MM_YYYY"
  dataset_name <- paste0("costs_", version)

  # Assign the data to that variable name
  assign(dataset_name, cost_list[[version]])

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
cat("Cost data prepared successfully!\n")
cat("========================================\n")
cat("Default dataset: costs (", latest_version, " version)\n", sep = "")
cat("Versioned datasets:\n")
for (version in names(cost_list)) {
  cat("  - costs_", version, "\n", sep = "")
}
cat("\nUsers can access older versions with:\n")
cat("  data(costs_MM_YYYY)\n")
cat("========================================\n")

