# Create coverage tables with stargazer<3

packages = c("stargazer")

package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }
})

# pp <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/bld/project_paths.r'
# source(pp)
# path_specs <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/src/model_specs/setup_1.json'


create_output_table <- function(d_list, list_of_methods, k_list){
  
  ncol <- 1 + 2 * (length(k_list) +length(list_of_methods)
  
}