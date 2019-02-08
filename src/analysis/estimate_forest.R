packages = c("dplyr","RJSONIO","devtools","randomForestCI","causalForest", "mgcv","FNN", "Hmisc", "xtable", "ggplot2")

package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }
})



path <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/bld/out/data/setup_1/sample_setup_1_n=50_rep_0.json'
path_test <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/bld/out/data/setup_1/sample_setup_1_n=50_rep_test.json'

data_1 <- as.data.frame(do.call("cbind", fromJSON(path)))
test_data_1 <- as.data.frame(do.call("cbind", fromJSON(path_test)))
x_test <- select(data_1,starts_with('X_'))
y_test <- data_1$Y
w_test <- data_1$W
data_1$X_0

forest = causalForest(x_test, y_test, w_test, 50, 15, 1)


predict_forest <- function (dataframe, testset, n_tree, sample_size, nodesize, foresttype){
  X <- select(dataframe, starts_with('X_'))
  X_test <- select(testset, starts_with('X_'))
  Y <- dataframe$Y
  W <- dataframe$W
  true_effect <- testset$true_te
  
  if (foresttype == double_sample){
    forest = causalForest(X, Y, W, n_tree, sample_size, nodesize)
  }
  else {forest = propensityForest(X, Y, W, n_tree, sample_size, nodesize)}
  predictions = predict(forest, X_test)
  forest_ci = randomForestInfJack(forest, X_test, calibrate = TRUE)
  se_hat = sqrt(forest.ci$var.hat)
  
  up_lim = predictions + 1.96 * se_hat
  down_lim = predictions - 1.96 * se_hat
  
  rf_tau = forest_ci$y.hat
  rf_se = sqrt(forest_ci$var.hat)
  rf_cov = abs(rf_tau - true_effect) <= 1.96 * rf_se
  rf_covered = mean(rf_cov)
  rf_mse = mean((rf_tau - true_effect)^2)
  return (c(rf_covered, rf_mse))
}

forest = propensityForest(x, y, w, 100, 10, 1)
x=predict_forest(data_1, test_data_1, 30, 10, 1)

forest = causalForest(X, Y, W, num.trees = ntree, sample.size = n / 4, nodesize = 1)
predictions = predict(forest, X.test)
forest.ci = randomForestInfJack(forest, X.test, calibrate = TRUE)


