## Shared Functions for Handling Costs in Health Economic Models

### Installation
`devtools::install_github("https://github.com/PPML/ppmlcosts")`

### Use
`cost_params` is a data frame with current PPML cost parameters. Adjust cost values to present USD using `deflate_costs` function.

##### For example:
```
# Adjust costs to 2024 USD
cost_params <- cost_params[!is.na(value), cost_2024:=mapply(FUN = deflate_costs, costs = value, from_year = year, to_year = 2024)]
# Export costs parameters as environment objects
list2env(setNames(as.list(df$cost_2024[!is.na(df$cost_2024)]), df$parameter[!is.na(df$cost_2024)]), globalenv())
```

