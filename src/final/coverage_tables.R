'

The file "coverage_tables.R" uses the compact analysis data, averages 
over simulation runs and makes a latex table out of the results.

This file expects to be given the setup name through the command line
and it writes coverage_table_*setup_name*.tex to PATH_OUT_TABLES.

'


packages <- c("xtable", "RJSONIO")

package.check <- lapply(packages, FUN = function(x) {
  suppressWarnings(suppressPackageStartupMessages(
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  ))
})


source("project_paths.r")


create_output_table <- function(setup_name) {
  # Create table with the aggregate results.
  
  # Load all information and the dataset with all results.
  sim_param <<- fromJSON(paste0(PATH_IN_MODEL_SPECS, "/simulation_parameters.json"))
  k_list <<- fromJSON(paste0(PATH_IN_MODEL_SPECS, "/k_list.json"))
  analysis_data <- read.csv(paste0(PATH_OUT_ANALYSIS, "/full_analysis_data.csv"))
  
  # Define dataset that corresponds to the individual setup.
  setup_data <- analysis_data[analysis_data$setup == setup_name, ]
  
  # Initiate the data table.
  data_table <- data.frame(d = as.integer(sim_param$d_list))
  
  # For all included methods avergae results over simulation repetitions and stack
  # together the lines and columns, first for knn since it has different k-values, then 
  # for all othe methods.
  for (method in sim_param$list_of_methods) {
    if (method == "knn") {
      for (k in k_list$k_list) {
        knn_values <- data.frame()
        for (d in sim_param$d_list) {
          coverage <- mean(unlist(setup_data[paste0(method, "_covered_", k)][setup_data$d == d, ]))
          mse <- mean(unlist(setup_data[paste0(method, "_mse_", k)][setup_data$d == d, ]))
          line <- cbind(coverage, mse)
          colnames(line) <- c(paste0("Coverage ", k, "-NN"), paste0("MSE ", k, "-NN"))
          knn_values <- rbind(knn_values, line)
        }
        data_table <- cbind(data_table, knn_values)
      }
    } else {
      values <- data.frame()
      for (d in sim_param$d_list) {
        coverage <- mean(unlist(setup_data[paste0(method, "_covered")][setup_data$d == d, ]))
        mse <- mean(unlist(setup_data[paste0(method, "_mse")][setup_data$d == d, ]))
        line <- cbind(coverage, mse)
        colnames(line) <- c(paste("Coverage", toupper(method)), paste("MSE", toupper(method)))
        values <- rbind(values, line)
      }
      data_table <- cbind(data_table, values)
    }
  }
  
  # Sort the table alphabetically to put coverage rates and MSE together.
  data_table <- cbind(
    data_table["d"], 
    data_table[, (2:ncol(data_table))][, order(names(data_table[, (2:ncol(data_table))]))]
  )
  return(data_table)
}


write_to_latex <- function(output_table, setup_name) {
  # Use xtable to create latex output.
  
  # Replace underscores by spaces to name setup in the caption.
  xtab <- xtable(output_table, caption = paste("Simulation results for", gsub("_", " ", setup_name)))
  # Only take the method name from the column names.
  colnames(xtab) <- gsub("^.* ", "", colnames(output_table))

  addtorow <- list()
  addtorow$pos <- list(-1)
  
  # Create additional headline for the output table to denote coverage rates and MSE
  addtorow$command <- paste0(
    paste0("& \\multicolumn{",
      length(sim_param$list_of_methods) + length(k_list$k_list) - 1,
      "}{c}{",
      c("CI Coverage Rate", "Mean Squared Error"),
      "}",
      collapse = ""
    ), "\\\\"
  )
  
  # Write to latex output file.
  path <- paste0(PATH_OUT_TABLES, "/coverage_table_", setup_name, ".tex")
  print(xtab, add.to.row = addtorow, include.rownames = F, file = path)
}


args <- commandArgs(trailingOnly = TRUE)
setup_name <- args[1]

output_table <- create_output_table(setup_name)
write_to_latex(output_table, setup_name)
