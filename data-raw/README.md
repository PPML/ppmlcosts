# data-raw Directory

This directory contains:

1. **Raw data files** - The source CSV files used to create the package datasets
2. **Data preparation scripts** - Code documenting how the data was processed

## Important Notes

- This folder is **NOT included** when users install the package
- Users automatically get the prepared data (in `data/health_deflators.rda`)
- This folder is for **transparency and reproducibility** - it documents how the data was created
- Only package **maintainers** should run these scripts (when updating data)

## Files

- `deflators_YYYY.csv` - Deflator series files (YYYY = version identifier, e.g., year of last data)
- `prepare_deflators.R` - Script to convert all CSVs to package data format
- `README.md` - This file

## Versioning Approach

To maintain reproducibility while updating data:

1. **Keep old versions**: Don't delete `deflators_2024.csv` when you add `deflators_2025.csv`
2. **Add new versions**: Create new files with updated data
3. **Automatic default**: The newest version (alphabetically last) becomes the default `health_deflators`
4. **Explicit access**: Users can still access `health_deflators_2024` for older analyses

Example file structure:
```
data-raw/
├── deflators_2023.csv  # Old version (still accessible)
├── deflators_2024.csv  # Previous version (still accessible)
└── deflators_2025.csv  # New version (becomes default)
```

This creates:
- `health_deflators` → points to 2025 data (default)
- `health_deflators_2023` → 2023 data (for reproducibility)
- `health_deflators_2024` → 2024 data (for reproducibility)
- `health_deflators_2025` → 2025 data (explicit access)

## For Package Maintainers

### Adding New Deflator Data

When new data becomes available:

1. Create a new CSV file: `deflators_YYYY.csv` (e.g., `deflators_2026.csv`)
2. **Keep the old files** - don't delete `deflators_2025.csv`, etc.
3. Open R in the package directory
4. Run: `source("data-raw/prepare_deflators.R")`
   - This will create datasets for ALL CSV files
   - The newest file becomes the default `health_deflators`
5. Increment the version in `DESCRIPTION` (e.g., 0.1.0 → 0.2.0)
6. Rebuild: `devtools::document()` and `devtools::install()`

### Version Naming Convention

Use a consistent naming scheme:
- `deflators_2024.csv` - if 2024 is the last year in the data
- `deflators_jan2025.csv` - if you update multiple times per year
- `deflators_v1.csv`, `deflators_v2.csv` - if using version numbers

The script will use the filename (minus "deflators_" and ".csv") as the version identifier.

## Data Format

Your `deflators.csv` must have exactly two columns:
- `year` - Integer year (e.g., 2020, 2021, 2022)
- `rate` - Annual inflation rate as decimal (e.g., 0.047 for 4.7%)

Example:
```
year,rate
2020,0.012
2021,0.047
2022,0.080
```

## Data Source Documentation

**Important:** Document your data source in `prepare_deflators.R` including:
- Where the data comes from
- Date retrieved
- Any transformations applied
- Known limitations or quirks
