packages = c("R.utils","pracma","Matrix","dplyr","RJSONIO","devtools","randomForestCI","causalForest", "mgcv","FNN", "Hmisc")
#"rstudioapi",
#, "xtable", "ggplot2"

package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }
})
print('loaded all packages')


source("project_paths.r")

source(paste(PATH_IN_MODEL_CODE,'/sample_size_functions.R',sep=""))
source(paste(PATH_IN_MODEL_CODE,'/n_tree_functions.R',sep=""))

print('loaded project paths')


#setwd(dirname(current_path ))
#source("Function_PowerCurves.R")

#source(src.model_code.sample_size_functions.R)
#source(src.model_code.n_tree_functions.R)
#source(bld.project_paths.r)
#pwd()

#path_ntf <<-paste(PATH_IN_MODEL_CODE,'/n_tree_functions.R', sep="")
#source(path_ntf)
#path_ssf <<-paste(PATH_IN_MODEL_CODE,'/sample_size_functions.R', sep="")
#source(path_ssf)

predict_forest <- function(dataframe, testset, setup){
  X <- select(dataframe, starts_with('X_'))
  X_test <- select(testset, starts_with('X_'))
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


write_data <- function(setup, analysis){
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

print('loaded first two functions')


run_and_write <- function(n_test, setup_name, n, rep_number){
  
  path_data <<-paste(PATH_OUT_DATA,"/", setup_name,"/sample_",setup_name,"_n=",n,"_rep_", rep_number, ".json", sep="")
  path_test_data <<- paste(PATH_OUT_DATA,"/", setup_name, "/sample_", setup_name, "_n=", n_test, "_rep_test.json", sep="")
  path_model_specs <<-paste(PATH_IN_MODEL_SPECS,"/", setup_name,".json", sep="")
  path_out <<- paste(PATH_OUT_ANALYSIS, '/analysis_data_',setup_name,'_',n,'_',rep_number,'.csv', sep="")
  #path_out <<- paste(PATH_OUT_ANALYSIS, '/analysis_data.csv', sep="")
  
  setup <- fromJSON(path_model_specs)
  data <- as.data.frame(do.call("cbind", fromJSON(path_data)))
  test_data <- as.data.frame(do.call("cbind", fromJSON(path_test_data)))
  
  analysis <- predict_forest(data, test_data, setup)
  data <- write_data(setup, analysis)
  
  dir.create(PATH_OUT_ANALYSIS, showWarnings = FALSE)
  
  write.table(data, path_out , sep = ",", append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
}
print('loaded all functions')

args = commandArgs(trailingOnly = TRUE)
n_test = args[1]
setup_name = args[2]
n = args[3]
rep_number = args[4]

print('defined command arguments')
print(args)


run_and_write(n_test, setup_name, n, rep_number)
print('ran script once')



#setup = "setup_1"
#n = "50"
#rep_number="1"
#n_test = "100"
#run_and_write(setup, n , rep_number, n_test)


#run_and_write()
#analysis <- predict_forest(data_1, test_data_1, setup)
#y=write_data(setup, analysis)
#path_out= paste(PATH_OUT_ANALYSIS, '/Data.csv', sep="")
#write.table(y, path_out , sep = ",", append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)

#pp <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/bld/project_paths.r'
#path <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/bld/out/data/setup_1/sample_setup_1_n=50_rep_0.json'
#path_specs <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/src/model_specs/setup_1.json'
#setup <- fromJSON(path_specs)
#data_1 <- as.data.frame(do.call("cbind", fromJSON(path)))
#test_data_1 <- as.data.frame(do.call("cbind", fromJSON(path_test)))
