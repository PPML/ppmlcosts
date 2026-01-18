#' Deflate Costs for Health Economic Models
#'
#' Converts costs from one year to another using inflation rates from a deflator series.
#' By default, uses the built-in deflator_series dataset, but custom deflator series
#' can be provided.
#'
#' @param costs Numeric vector of cost values to deflate
#' @param from_year Integer. The year the costs are currently in
#' @param to_year Integer. The year to deflate costs to
#' @param deflator_version Data frame with columns 'year', 'pce_health', and 'phce'.
#'   If NULL (default), uses the built-in deflator_series data (most recent version).
#'   To use a specific version, load it with \code{data(deflators_MM_YYYY)} and pass it here.
#'
#' @return Numeric vector of deflated costs
#'
#' @examples
#' # Deflate a single cost from 2020 to 2023
#' deflate_costs(10000, from_year = 2020, to_year = 2023)
#'
#' # Deflate multiple costs
#' costs <- c(10000, 15000, 20000)
#' deflate_costs(costs, from_year = 2021, to_year = 2024)
#'
#' # Use a specific version for reproducibility
#' data(deflators_01_2026)
#' deflate_costs(10000, 2020, 2022, deflators_01_2026)
#'
#' @export
deflate_costs <- function(costs, from_year, to_year, deflator_version = NULL) {

  # Use built-in data if not provided
  if (is.null(deflator_version)) {
    deflator_version <- deflator_series
  }

  # Validate inputs
  if (!is.numeric(costs)) {
    stop("costs must be numeric")
  }

  # If years are the same, return costs as-is
  if (from_year == to_year) {
    return(costs)
  }

  # Convert to named vector for easier lookup
  index <- stats::setNames(deflator_version$phce, deflator_version$year)

  # Calculate deflator
  if (!from_year %in% names(index)) {
      stop(paste("Missing inflation rate for year", from_year,
                 "in deflator series"))
  }
  if (!to_year %in% names(index)) {
    stop(paste("Missing inflation rate for year", to_year,
               "in deflator series"))
  }

  deflation_factor <- as.numeric(index[as.character(to_year)] / index[as.character(from_year)])

  return(costs * deflation_factor)
}
