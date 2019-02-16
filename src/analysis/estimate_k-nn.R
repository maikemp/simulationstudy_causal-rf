packages = c("RJSONIO","dplyr","FNN")

package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }
})

source("project_paths.r")


setup_name = "setup_3"
n = "50"
rep_number="2"
n_test = "100"
k=20
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
predict_k-nn <- function(dataframe, testset, setup, k){
  
  X <- dplyr::select(dataframe, starts_with('X_'))
  X_test <- dplyr::select(testset, starts_with('X_'))
  Y <- dataframe$Y
  W <- dataframe$W
  W_test <- testset$W
  true_effect <- testset$true_te
  n <- length(Y)
  d <- ncol(X)
  k <- setup$k
  
  #knn.reg directly provides possibility to estimate and predict in one step
  pred_w0 <- knn.reg(X[W==0,], X_test, Y[W==0], k = k)$pred
  pred_w1 <- knn.reg(X[W==1,], X_test, Y[W==1], k = k)$pred 
  

}


# run_and_write()
# analysis <- predict_forest(data_1, test_data_1, setup)
# y=write_data(setup, analysis)
# path_out= paste(PATH_OUT_ANALYSIS, '/Data.csv', sep="")
# write.table(y, path_out , sep = ",", append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)



