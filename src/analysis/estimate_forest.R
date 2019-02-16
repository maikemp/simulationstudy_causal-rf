packages = c("R.utils","pracma","Matrix","dplyr","RJSONIO","devtools","randomForestCI","causalForest", "mgcv", "Hmisc")

package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }
})

source("project_paths.r")

source(paste(PATH_IN_MODEL_CODE,'/sample_size_functions.R',sep=""))
source(paste(PATH_IN_MODEL_CODE,'/n_tree_functions.R',sep=""))


predict_forest <- function(dataframe, testset, setup){
  X <- dplyr::select(dataframe, starts_with('X_'))
  X_test <- dplyr::select(testset, starts_with('X_'))
  Y <- dataframe$Y
  W <- dataframe$W
  true_effect <- testset$true_te
  n <- length(Y)
  d <- ncol(X)
  
  n_tree_function = get(setup$n_tree_function)
  n_tree <- n_tree_function(n)
  
  sample_size_function <- get(setup$sample_size_function)
  sample_size <- sample_size_function(n)
  
  if (setup$foresttype == 'double_sample'){
    forest = causalForest(X, Y, W, n_tree, sample_size, setup$node_size)
  }
  if (setup$foresttype == 'propensity'){
    propensityForest(X, Y, W, n_tree, sample_size, setup$node_size)
  }
  
  predictions = predict(forest, X_test)
  forest_ci = randomForestInfJack(forest, X_test, calibrate = TRUE)
  se_hat = sqrt(forest_ci$var.hat)
  
  up_lim = predictions + 1.96 * se_hat
  down_lim = predictions - 1.96 * se_hat
  
  rf_tau = forest_ci$y.hat
  rf_se = sqrt(forest_ci$var.hat)
  rf_cov = abs(rf_tau - true_effect) <= 1.96 * rf_se
  rf_covered = mean(rf_cov)
  rf_mse = mean((rf_tau - true_effect)^2)
  return (cbind(n, d, rf_covered, rf_mse, n_tree, sample_size))
}


sR <- function(x, n=1){
  substr(x, nchar(x)-n+1, nchar(x))
}


write_data <- function(setup, setup_name, analysis){
  
  if (setup$x_distr == "normal"){
    cov <- do.call("cbind",setup$x_cov)
    n_corr = nnzero((1*upper.tri(cov))*cov)}
  
  if (setup$x_distr == "uniform"){n_corr = 0}
  
  x_distr = setup$x_distr
  sigma = setup$sigma
  prop_funct = sR(setup$propensity_function)
  te_funct = sR(setup$treatment_effect_function)
  foresttype = setup$foresttype
  
  return(data.frame(analysis,  n_corr, x_distr, sigma, prop_funct, te_funct, foresttype))
}


run_and_write <- function(n_test, setup_name, n, rep_number){
  
  path_data <<-paste(PATH_OUT_DATA,"/", setup_name,"/sample_",setup_name,"_n=",n,"_rep_", rep_number, ".json", sep="")
  path_test_data <<- paste(PATH_OUT_DATA,"/", setup_name, "/sample_", setup_name, "_n=", n_test, "_rep_test.json", sep="")
  path_model_specs <<-paste(PATH_IN_MODEL_SPECS,"/", setup_name,".json", sep="")
  path_out <<- paste(PATH_OUT_ANALYSIS_FOREST, '/analysis_data_',setup_name,'_n=', n, '_rep_', rep_number,'.json', sep="")
  #path_out <<- paste(PATH_OUT_ANALYSIS, '/analysis_data.json', sep="")
  
  setup <- fromJSON(path_model_specs)
  data <- as.data.frame(do.call("cbind", fromJSON(path_data)))
  test_data <- as.data.frame(do.call("cbind", fromJSON(path_test_data)))
  
  analysis <- predict_forest(data, test_data, setup)
  data <- write_data(setup, setup_name, analysis)
  data$id <- paste(setup_name, '_n=', n, '_rep_', rep_number)
  
  dir.create(PATH_OUT_ANALYSIS, showWarnings = FALSE)
  
  export_json <- toJSON(data)
  write(export_json, path_out)
}

args = commandArgs(trailingOnly = TRUE)
n_test = args[1]
setup_name = args[2]
n = args[3]
rep_number = args[4]

run_and_write(n_test, setup_name, n, rep_number)

