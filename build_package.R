# Quick Start Script for Building healthEconDeflate Package
# Run this script from within the healthEconDeflate directory

# Install required packages if needed
if (!require("devtools")) install.packages("devtools")
if (!require("roxygen2")) install.packages("roxygen2")
if (!require("usethis")) install.packages("usethis")
if (!require("data.table")) install.packages("data.table")
if (!require("readxl")) install.packages("readxl")
if (!require("stats")) install.packages("stats")

library(devtools)

# Step 1: Prepare your deflator data
cat("Step 1: Preparing deflator data...\n")

# Uncomment this line after editing prepare_deflators.R:
source("data-raw/prepare_deflators.R")

# Step 2: Generate documentation
cat("Step 2: Generating documentation...\n")
devtools::document()

# Step 3: Check package
cat("Step 3: Checking package...\n")
check_results <- devtools::check()

# Step 4: Install package
cat("Step 4: Installing package...\n")
devtools::install()

cat("\n=== Package built successfully! ===\n")
cat("Now you can use: library(ppmlcosts)\n")
cat("Get help with: ?deflate_costs\n")
