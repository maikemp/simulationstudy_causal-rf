'

The file "estimate_knn.R" estimates treatment effects by k - Nearest
Neighbor matching and saves out data snippets with the analysis results.

'


packages = c("RJSONIO","dplyr","FNN")

package.check <- lapply(packages, FUN = function(x) {
  suppressWarnings(suppressPackageStartupMessages(
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }))
})

source("project_paths.r")


predict_knn <- function(dataframe, testset, setup, k){
  '
  Run analysis with k-Nearest Neighbor matching on the given dataset
  with parameters as defined in the setup, define bounds of the 
  confidence intervals, predict outcomes for a testset and return
  average mean squared error and coverage rate of the intervals.
  '
  
  X <- dplyr::select(dataframe, starts_with('X_'))
  X_test <- dplyr::select(testset, starts_with('X_'))
  Y <- dataframe$Y
  W <- dataframe$W
  W_test <- testset$W
  true_effect <- testset$true_te
  n <- length(Y)
  d <- ncol(X)

  # knn.reg directly provides possibility to estimate and predict in one step.
  predict_w0 <- knn.reg(X[W==0,], X_test, Y[W==0], k = k)$pred
  predict_w1 <- knn.reg(X[W==1,], X_test, Y[W==1], k = k)$pred 
  
  # Estimate the Treatment effect and derive the MSE.
  estimated_te <- predict_w1 - predict_w0
  knn_mse <- mean((estimated_te - true_effect)^2)
  
  # Derive the standard error.
  predict_w0_2 = knn.reg(X[W==0,], X_test, Y[W==0]^2, k = k)$pred
  predict_w1_2 = knn.reg(X[W==1,], X_test, Y[W==1]^2, k = k)$pred
  predict_w0_var = (predict_w0_2 - predict_w0^2) / (k - 1)
  predict_w1_var = (predict_w1_2 - predict_w1^2) / (k - 1)
  std_err = sqrt(predict_w0_var + predict_w1_var)
  
  alpha <- setup$alpha
  qt <- qt(p = 1-alpha/2, df = n-d)
  
  # Derive coverage rate of confidence intervals. 
  knn_cov = abs(estimated_te - true_effect) <= qt * std_err
  knn_covered = mean(knn_cov)
  
  return(cbind(knn_covered, knn_mse))
}

run_and_write_knn <- function(setup_name, d, rep_number){
  # Import the required data, execute the analysis, tie together the 
  # data of interest and export to a single json file. 
  
  path_data <<-paste(PATH_OUT_DATA,"/", setup_name,"/sample_",setup_name,"_d=",d,"_rep_", rep_number, ".json", sep="")
  path_test_data <<- paste(PATH_OUT_DATA,"/", setup_name, "/sample_", setup_name, "_d=", d, "_rep_test.json", sep="")
  path_model_specs <<-paste(PATH_IN_MODEL_SPECS,"/", setup_name,"_analysis.json", sep="")
  path_out <<- paste(PATH_OUT_ANALYSIS_KNN, '/knn_data_',setup_name,'_d=', d, '_rep_', rep_number,'.json', sep="")
  
  setup <- fromJSON(path_model_specs)
  data <- as.data.frame(do.call("cbind", fromJSON(path_data)))
  test_data <- as.data.frame(do.call("cbind", fromJSON(path_test_data)))
  
  k_list <<- fromJSON(paste(PATH_IN_MODEL_SPECS,"/k_list.json", sep=""))
  
  # Run extra analysis for each k value in_param$k_list
  # and attach the results to the exported data frame.
  analysis = list()
  for (k in k_list$k_list){
    analysis_k <- predict_knn(data, test_data, setup, k)
    colnames(analysis_k)<- c(paste('knn_covered_', k, sep=""),paste('knn_mse_', k, sep=""))
    analysis <- cbind(analysis, analysis_k)
  }

  id <- paste(setup_name, '_d=', d, '_rep_', rep_number, sep="")
  out_data <- cbind(id, analysis)
  
  export_json <- toJSON(as.data.frame(out_data))
  write(export_json, path_out)
}


args = commandArgs(trailingOnly = TRUE)
setup_name = args[1]
d = args[2]
rep_number = args[3]


run_and_write_knn(setup_name, d, rep_number)


