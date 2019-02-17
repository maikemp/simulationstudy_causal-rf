packages = c("RJSONIO","dplyr","FNN")

package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }
})

source("project_paths.r")


# k.small = 10
# k.big = 100
# k.vals = c(2, 4, 6)
# d.vals = c(6, 12)

setup_name = "setup_3"
n = "50"
rep_number="2"
n_test = "100"
k=12
pp <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/bld/project_paths.r'
source(pp)
path <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/bld/out/data/setup_1/sample_setup_1_n=50_rep_0.json'
path_test <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/bld/out/data/setup_1/sample_setup_1_n=100_rep_test.json'
path_specs <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/src/model_specs/setup_1.json'
setup <- fromJSON(path_specs)
data_1 <- as.data.frame(do.call("cbind", fromJSON(path)))
dataframe=data_1
test_data_1 <- as.data.frame(do.call("cbind", fromJSON(path_test)))
testset=test_data_1

# LOOP ÜBER VERSCHIEDENE K WERTE?
predict_knn <- function(dataframe, testset, setup, k){
  
  X <- dplyr::select(dataframe, starts_with('X_'))
  X_test <- dplyr::select(testset, starts_with('X_'))
  Y <- dataframe$Y
  W <- dataframe$W
  W_test <- testset$W
  true_effect <- testset$true_te
  n <- length(Y)
  d <- ncol(X)
  k <- k

  #knn.reg directly provides possibility to estimate and predict in one step
  predict_w0 <- knn.reg(X[W==0,], X_test, Y[W==0], k = k)$pred
  predict_w1 <- knn.reg(X[W==1,], X_test, Y[W==1], k = k)$pred 
  
  estimated_te <- predict_w1 - predict_w0
  mse <- mean((estimated_te - true_effect)^2)
  
  predict_w0_2 = knn.reg(X[W==0,], X_test, Y[W==0]^2, k = k)$pred
  predict_w1_2 = knn.reg(X[W==1,], X_test, Y[W==1]^2, k = k)$pred
  
  predict_w0_var = (predict_w0_2 - predict_w0^2) / (k - 1)
  predict_w1_var = (predict_w1_2 - predict_w1^2) / (k - 1)
  std_err = sqrt(predict_w0_var + predict_w1_var)
  
  covered_indicator = abs(estimated_te - true_effect) <= 1.96 * std_err
  knn.covered = mean(covered_indicator)
}


# run_and_write()
# analysis <- predict_forest(data_1, test_data_1, setup)
# y=write_data(setup, analysis)
# path_out= paste(PATH_OUT_ANALYSIS, '/Data.csv', sep="")
# write.table(y, path_out , sep = ",", append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)



