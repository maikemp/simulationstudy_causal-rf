packages = c("dplyr","RJSONIO","devtools","randomForestCI","causalForest", "mgcv","FNN", "Hmisc", "xtable", "ggplot2")

package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }
})

source(src.model_code.sample_size_functions)
source(src.model_code.n_tree_functions)
source(bld.project_paths.r)
PATH_OUT_FINAL

jsdf<-paste(PATH_OUT_FINAL,'/', 'setup.json', sep="")
path <- paste(PATH_OUT_DATA,"_",toupper(setup_name),"/sample_",setup_name,"_n=",n,"_rep_", rep_number, ".json", sep="")

n<-5
rep_number<-0
setup_name <- 'setup_1'

load_data <- function(path)
  as.data.frame(do.call("cbind", fromJSON(path)))

predict_forest <- function(dataframe, testset, n_tree, sample_size, nodesize, foresttype = double_sample){
  X <- select(dataframe, starts_with('X_'))
  X_test <- select(testset, starts_with('X_'))
  Y <- dataframe$Y
  W <- dataframe$W
  true_effect <- testset$true_te
  
  if (foresttype == 'double_sample'){
    forest = causalForest(X, Y, W, n_tree, sample_size, nodesize)
  }
  if (foresttype == 'propensity'){
    propensityForest(X, Y, W, n_tree, sample_size, nodesize)
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
  return (c(rf_covered, rf_mse))
}

write_data <- function()

if (__name__ == "__main__"){
  args = commandArgs()
  setup_name = args[1]
  n = args[2]
  rep_number=args[3]
  
  path_data <-paste(PATH_OUT_DATA,"_",toupper(setup_name),"/sample_",setup_name,"_n=",n,"_rep_", rep_number, ".json", sep="")
  path_model_specs <-paste(PATH_IN_MODEL_SPECS,"/", setup_name,".json",sep="")
  
  
  setup <- fromJSON(path_model_specs)
}


x=predict_forest(data_1, test_data_1, 30, 10, 1, 'double_sample')

pp <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/bld/project_paths.r'
path <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/bld/out/data/setup_1/sample_setup_1_n=50_rep_0.json'
path_test <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/bld/out/data/setup_1/sample_setup_1_n=50_rep_test.json'
path_specs <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/src/model_specs/setup_1.json'

forest = causalForest(x_test, y_test, w_test, 30, 20, 1)
X_test <- select(test_data_1, starts_with('X_'))
forest_ci = randomForestInfJack(forest, X_test, calibrate = TRUE)

setup <- fromJSON(path_specs)
data_1 <- as.data.frame(do.call("cbind", fromJSON(path)))
test_data_1 <- as.data.frame(do.call("cbind", fromJSON(path_test)))
x_test <- select(data_1,starts_with('X_'))
y_test <- data_1$Y
w_test <- data_1$W
data_1$X_0

