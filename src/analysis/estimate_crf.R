'

The file "estimate_crf.R" estimates treatment effects by causal forests 
and confidence intervals for them using the causalForest functions 
written by Wager & Athey (2018) and saves out data snippets with the analysis
results.

'
packages = c("R.utils","pracma","Matrix","dplyr","RJSONIO","devtools","randomForestCI","causalForest", "mgcv", "Hmisc")
# packages = c("randomForestCI","causalForest")

package.check <- lapply(packages, FUN = function(x) {
  suppressWarnings(suppressPackageStartupMessages(
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }))
})

source("project_paths.r")


predict_forest <- function(dataframe, testset, setup) {
  '
  Run analysis with causal random forests on the given dataset
  with parameters as defined in the setup, define bounds of the 
  confidence intervals, predict outcomes for a testset and return
  average mean squared error and coverage rate of the intervals.
  '
  
  # Put together data as required and name accordingly.
  X <- dplyr::select(dataframe, starts_with('X_'))
  X_test <- dplyr::select(testset, starts_with('X_'))
  Y <- dataframe$Y
  W <- dataframe$W
  true_effect <- testset$true_te
  n <- length(Y)
  d <- ncol(X)
  
  # Get number of trees as numeric value or from the respecitve function depending on the value in the setup.
  if (is.numeric(setup$n_tree_function)) {
    n_tree = setup$n_tree_function
  } else {
    source(paste0(PATH_IN_MODEL_CODE,'/n_tree_functions.R'))
    n_tree_function = get(setup$n_tree_function)
    n_tree <- n_tree_function(n)
  }
  
  # Get sample size as numeric value or from the respecitve function depending on the value in the setup.
  if(is.numeric(setup$sample_size_function)) {
    sample_size = setup$sample_size_function
  } else {
    source(paste0(PATH_IN_MODEL_CODE, '/sample_size_functions.R'))
    sample_size_function <- get(setup$sample_size_function)
    sample_size <- sample_size_function(n)
    
  }
  
  # Build the forest either by the double sample or the propensity algorithm.
  if (setup$foresttype == 'double_sample') {
    forest = invisible(causalForest(X, Y, W, n_tree, sample_size, setup$node_size))
  }
  if (setup$foresttype == 'propensity') {
    forest = invisible(propensityForest(X, Y, W, n_tree, sample_size, setup$node_size))
  }
  
  # Use the fitted model to predict treatment effects for the test sample. 
  crf_tau = predict(forest, X_test)
  # Obtain the infinitesimal jackknife for random forests for an estimate of the variance.
  forest_ci = randomForestInfJack(forest, X_test, calibrate = TRUE)
  crf_se_hat = sqrt(forest_ci$var.hat)

  # Obtain the limits of the confidence intervals for significance level alpha.
  alpha <- setup$alpha
  qt <- qt(p = 1-alpha/2, df = n-d)
  half_ci_width = qt * crf_se_hat 

  # Compute share of test points covered by the corresponding confidence interval.
  crf_cov = abs(crf_tau - true_effect) <= qt * crf_se_hat
  crf_covered = mean(crf_cov)
  crf_mse = mean((crf_tau - true_effect)^2)
  
  micro_data = cbind(X_test[1], true_effect, crf_tau, crf_cov, half_ci_width)
  
  return (list("results" = cbind(n, d, crf_covered, crf_mse, n_tree, sample_size), "micro_data" = micro_data))
}

run_and_write_forest <- function(setup_name, d, rep_number){
  # Import the required data, execute the analysis, tie together the 
  # data of interest and export to a single json file. 
  
  path_data <<-paste0(PATH_OUT_DATA,"/", setup_name,"/sample_",setup_name,"_d=",d,"_rep_", rep_number, ".json")
  path_test_data <<- paste0(PATH_OUT_DATA,"/", setup_name, "/sample_", setup_name, "_d=", d, "_rep_test.json")
  path_model_specs <<-paste0(PATH_IN_MODEL_SPECS,"/", setup_name,"_analysis.json")
  path_out <<- paste0(PATH_OUT_ANALYSIS_CRF, '/crf_data_',setup_name,'_d=', d, '_rep_', rep_number,'.json')
  path_trash <<- paste0(PATH_OUT_ANALYSIS_CRF, '/trash.txt')

  setup <- fromJSON(path_model_specs)
  data <- as.data.frame(do.call("cbind", fromJSON(path_data)))
  test_data <- as.data.frame(do.call("cbind", fromJSON(path_test_data)))
  
  # Make a sink for the print messages from the forest estimation to keep terminal clean.
  sink(file=paste0(path_trash))
  
  # Run analysis and extract aggregated data and micro data.
  analysis <- invisible(predict_forest(data, test_data, setup))
  results <- analysis$results
  sink()
  
  # Create result data frame and save out to json file.
  foresttype <- setup$foresttype
  id <- paste(setup_name, '_d=', d, '_rep_', rep_number,sep="")
  data <- data.frame(id, setup_name, results, foresttype)
  export_json <- toJSON(data)
  write(export_json, path_out)
  
  # Create micro data only for the first repetition of any setup.
  if (rep_number == 0){
    path_out_micro <- paste0(PATH_OUT_ANALYSIS_CRF,'/crf_data_',setup_name,'_d=',d,'_micro_data.json')
    micro_data <- analysis$micro_data
    export_json <- toJSON(micro_data)
    write(export_json, path_out_micro)
  }
}


args = commandArgs(trailingOnly = TRUE)
setup_name = args[1]
d = args[2]
rep_number = args[3]

run_and_write_forest(setup_name, d, rep_number)
