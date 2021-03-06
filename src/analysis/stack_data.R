'

The file "stack_data.R" loads all data snippets produced by the 
``estimate_[method_name].R`` files and stacks them together into one 
csv dataframe calles ``full_analysis_data.csv`` in PATH_OUT_ANALYSIS.

'


packages <- c("RJSONIO", "data.table")

package.check <- lapply(packages, FUN = function(x) {
  suppressWarnings(suppressPackageStartupMessages(
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  ))
})


source("project_paths.r")


create_dataset <- function() {
  # Load all created data snippets and stack them in a dataframe containing
  # aggregate information about the simulation results.

  sim_param <<- fromJSON(paste0(PATH_IN_MODEL_SPECS, "/simulation_parameters.json"))

  n_dt <- length(sim_param$d_list) *
    length(sim_param$list_of_setups) * length(seq(sim_param$rep_number))
  # Initiate the dataset that will be appended.
  all_data <- data.frame(const = rep(1, n_dt))

  # Loop over all the parameters iterated before on the command line to create
  # the different datasnippets and put them together into one data file.
  for (method in sim_param$list_of_methods) {
    
    method_data <- data.frame()
    
    for (setup_name in sim_param$list_of_setups) {
      for (d in sim_param$d_list) {
        for (rep_number in seq(sim_param$rep_number) - 1) {
          
          path <<- paste0(
            PATH_OUT_ANALYSIS,
            "/", method, "/", method, "_data_", setup_name,
            "_d=", d, "_rep_", rep_number, ".json"
          )
          
          new_line <- t(fromJSON(path))
          method_data <- rbind(method_data, new_line)
          
        }
      }
    }
    all_data <- cbind(all_data, method_data)
    
  }

  # Write to one single csv dataset.
  path_out <<- paste0(PATH_OUT_ANALYSIS, "/full_analysis_data.csv")
  fwrite(all_data, path_out)
}


create_dataset()
