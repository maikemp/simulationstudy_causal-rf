packages = c("RJSONIO","dplyr","FNN")

package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }
})

source("project_paths.r")


# setup_name = "setup_1"
# n = "50"
# rep_number="0"
# n_test = "100"
# k=15
# pp <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/bld/project_paths.r'
# source(pp)
# path <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/bld/out/data/setup_1/sample_setup_1_n=50_rep_0.json'
# path_test <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/bld/out/data/setup_1/sample_setup_1_n=100_rep_test.json'
# path_specs <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/src/model_specs/setup_1.json'
# setup <- fromJSON(path_specs)
# data <- as.data.frame(do.call("cbind", fromJSON(path)))
# dataframe=data
# test_data <- as.data.frame(do.call("cbind", fromJSON(path_test)))
# testset=test_data

predict_knn <- function(dataframe, testset, setup, k){
  
  X <- dplyr::select(dataframe, starts_with('X_'))
  X_test <- dplyr::select(testset, starts_with('X_'))
  Y <- dataframe$Y
  W <- dataframe$W
  W_test <- testset$W
  true_effect <- testset$true_te
  n <- length(Y)
  d <- ncol(X)

  #knn.reg directly provides possibility to estimate and predict in one step
  predict_w0 <- knn.reg(X[W==0,], X_test, Y[W==0], k = k)$pred
  predict_w1 <- knn.reg(X[W==1,], X_test, Y[W==1], k = k)$pred 
  
  estimated_te <- predict_w1 - predict_w0
  knn_mse <- mean((estimated_te - true_effect)^2)
  
  predict_w0_2 = knn.reg(X[W==0,], X_test, Y[W==0]^2, k = k)$pred
  predict_w1_2 = knn.reg(X[W==1,], X_test, Y[W==1]^2, k = k)$pred
  
  predict_w0_var = (predict_w0_2 - predict_w0^2) / (k - 1)
  predict_w1_var = (predict_w1_2 - predict_w1^2) / (k - 1)
  std_err = sqrt(predict_w0_var + predict_w1_var)
  
  covered_indicator = abs(estimated_te - true_effect) <= 1.96 * std_err
  knn_covered = mean(covered_indicator)
  
  return(cbind(knn_covered, knn_mse))
}

run_and_write_knn <- function(n_test, setup_name, n, rep_number){
  
  path_data <<-paste(PATH_OUT_DATA,"/", setup_name,"/sample_",setup_name,"_n=",n,"_rep_", rep_number, ".json", sep="")
  path_test_data <<- paste(PATH_OUT_DATA,"/", setup_name, "/sample_", setup_name, "_n=", n_test, "_rep_test.json", sep="")
  path_model_specs <<-paste(PATH_IN_MODEL_SPECS,"/", setup_name,".json", sep="")
  # path_out <<- paste(PATH_OUT_ANALYSIS, '/analysis_data.json', sep="")
  path_out <<- paste(PATH_OUT_ANALYSIS_KNN, '/knn_data_',setup_name,'_n=', n, '_rep_', rep_number,'.json', sep="")
  
  setup <- fromJSON(path_model_specs)
  data <- as.data.frame(do.call("cbind", fromJSON(path_data)))
  test_data <- as.data.frame(do.call("cbind", fromJSON(path_test_data)))
  
  sim_param <<- fromJSON(paste(PATH_IN_MODEL_SPECS,"/simulation_parameters.json", sep=""))
  
  analysis = list()
  for (k in sim_param$k_list){
    analysis_k <- predict_knn(data, test_data, setup, k)
    colnames(analysis_k)<- c(paste('covered_k=', k, sep=""),paste('mse_k=', k, sep=""))
    analysis <- cbind(analysis, analysis_k)
  }

  id <- paste(setup_name, '_n=', n, '_rep_', rep_number, sep="")
  out_data <- cbind(id, analysis)
  
  dir.create(PATH_OUT_ANALYSIS_KNN, showWarnings = FALSE)
  
  export_json <- toJSON(as.data.frame(out_data))
  write(export_json, path_out)
}


args = commandArgs(trailingOnly = TRUE)
n_test = args[1]
setup_name = args[2]
n = args[3]
rep_number = args[4]


run_and_write_knn(n_test, setup_name, n, rep_number)



# analysis <- predict_forest(data_1, test_data_1, setup)
# y=write_data(setup, analysis)
# path_out= paste(PATH_OUT_ANALYSIS, '/Data.csv', sep="")
# write.table(y, path_out , sep = ",", append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)



