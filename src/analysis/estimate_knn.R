'

The file "estimate_knn.R" estimates treatment effects by k - Nearest
Neighbor matching and saves out data snippets with the analysis results.

The file expects to be given a setup_name, a value for d and a number
for the simulation repetition currently at from the wscript. It takes
a simulated dataset from PATH_OUT_DATA and saves out a one-line dataset
containing aggregate information on the mse and the coverage frequency for 
the k nearest neighbor estimator and the corresponding confidence intervals, 
as well as further information on the dataset processed to PATH_OUT_ANALYSIS_KNN.
It does so for all values given in k_list.json in PATH_IN_MODEL_SPECS and 
uses value in "alpha" from the ``[setup_name]_analysis.json`` file that is also 
taken from PATH_IN_MODEL_SPECS.

'


packages <- c("RJSONIO", "dplyr", "FNN")

package.check <- lapply(packages, FUN = function(x) {
  suppressWarnings(suppressPackageStartupMessages(
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  ))
})


source("project_paths.r")


predict_knn <- function(dataframe, testset, alpha, k) {
  "
  Run analysis with k-Nearest Neighbor matching on the given dataset 
  with parameters as defined in the setup, define bounds of the 
  confidence intervals, predict outcomes for a testset and return 
  average mean squared error and coverage rate of the intervals.
  
  "

  X <- dplyr::select(dataframe, starts_with("X_"))
  X_test <- dplyr::select(testset, starts_with("X_"))
  Y <- dataframe$Y
  W <- dataframe$W
  W_test <- testset$W
  true_effect <- testset$true_te
  n <- length(Y)
  d <- ncol(X)

  # knn.reg directly provides possibility to estimate and predict in one step.
  predict_w0 <- knn.reg(X[W == 0, ], X_test, Y[W == 0], k = k)$pred
  predict_w1 <- knn.reg(X[W == 1, ], X_test, Y[W == 1], k = k)$pred

  # Estimate the Treatment effect and derive the MSE.
  estimated_te <- predict_w1 - predict_w0
  knn_mse <- mean((estimated_te - true_effect)^2)

  # Derive the standard error.
  predict_w0_2 <- knn.reg(X[W == 0, ], X_test, Y[W == 0]^2, k = k)$pred
  predict_w1_2 <- knn.reg(X[W == 1, ], X_test, Y[W == 1]^2, k = k)$pred
  predict_w0_var <- (predict_w0_2 - predict_w0^2) / (k - 1)
  predict_w1_var <- (predict_w1_2 - predict_w1^2) / (k - 1)
  std_err <- sqrt(predict_w0_var + predict_w1_var)

  qt <- qt(p = 1 - alpha / 2, df = n - d)
  half_ci_width <- qt * std_err

  # Derive coverage rate of confidence intervals.
  knn_cov <- abs(estimated_te - true_effect) <= qt * std_err
  knn_covered <- mean(knn_cov)
  
  micro_data <- cbind(X_test[1], true_effect, estimated_te, knn_cov, half_ci_width)

  return(
    list(
      "results" = cbind(knn_covered, knn_mse),
      "micro_data" = micro_data
    )
  )
}

run_and_write_knn <- function(setup_name, d, rep_number) {
  # Import the required data, execute the analysis, tie together the
  # data of interest and export to a single json file.

  path_data <<- paste0(
    PATH_OUT_DATA,
    "/", setup_name, "/sample_", setup_name, "_d=", d, "_rep_", rep_number, ".json"
  )
  path_test_data <<- paste0(
    PATH_OUT_DATA,
    "/", setup_name, "/sample_", setup_name, "_d=", d, "_rep_test.json"
  )
  path_out <<- paste0(
    PATH_OUT_ANALYSIS_KNN,
    "/knn_data_", setup_name, "_d=", d, "_rep_", rep_number, ".json"
  )
  path_out_micro <<- paste0(
    PATH_OUT_ANALYSIS_KNN,
    "/knn_data_", setup_name, "_d=", d,"_rep_", rep_number, "_micro_data.json"
  )

  # Load required information and data.
  data <- as.data.frame(do.call("cbind", fromJSON(path_data)))
  test_data <- as.data.frame(do.call("cbind", fromJSON(path_test_data)))

  k_list <<- fromJSON(paste0(PATH_IN_MODEL_SPECS, "/k_list.json"))

  # Run extra analysis for each k value in_param$k_list
  # and attach the results to the exported data frame.
  results <- list()
  alpha <- k_list$alpha
  for (k in k_list$k_list) {
    analysis_k <- predict_knn(data, test_data, alpha, k)
    results_k <- analysis_k$results
    colnames(results_k) <- c(
      paste0("knn_covered_", k),
      paste0("knn_mse_", k)
    )
    results <- cbind(results, results_k)
    
    # Create micro data set.
    if (k == k_list$k_list[1]){
      micro_data <- analysis_k$micro_data
      colnames(micro_data) <- c("X_1", "true_effect", paste0("tau_k=", k), paste0("cov_k=", k),paste0("half_ci_width_k=", k))
    } else {
      micro_data_app <- analysis_k$micro_data[3:5]
      colnames(micro_data_app) <- c(paste0("tau_k=", k), paste0("cov_k=", k),paste0("half_ci_width_k=", k))
      micro_data <- cbind(micro_data, micro_data_app)
    }
    
  }
  
  # Write out micro data.
  export_json <- toJSON(micro_data)
  write(export_json, path_out_micro)
  
  # Create an id that identifies the processed dataset.
  id <- paste0(setup_name, "_d=", d, "_rep_", rep_number)
  out_data <- cbind(id, results)
  
  # Write out aggregated result data.
  export_json <- toJSON(as.data.frame(out_data))
  write(export_json, path_out)
}

# Define values from command line and execute the functions.
args <- commandArgs(trailingOnly = TRUE)
setup_name <- args[1]
d <- args[2]
rep_number <- args[3]

run_and_write_knn(setup_name, d, rep_number)
