# Create coverage tables with stargazer<3

packages = c("stargazer","RJSONIO")

package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }
})
source("project_paths.r")

# pp <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/bld/project_paths.r'
# source(pp)
# path_sim <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/src/model_specs/simulation_parameters.json'
# sim_param = fromJSON(path_sim)

k_list = sim_param$k_list
list_of_methods = sim_param$list_of_methods
d_list = sim_param$d_list
setup_name='setup_1'

create_output_table <- function(setup_name){
  
  sim_param <<- fromJSON(paste(PATH_IN_MODEL_SPECS,"/simulation_parameters.json", sep=""))
  
  n_col <- 1 + 2 * (length(k_list) + length(list_of_methods) -1)

  analysis_data <- read.csv(paste(PATH_OUT_ANALYSIS,"/full_analysis_data.csv",sep=''))
  setup_data <- analysis_data[analysis_data$setup==setup_name,]
  
  for (method in sim_param$list_of_methods){
    
    
  }
  
  d = d_list
  data_table = data.frame(d)
  
  
}