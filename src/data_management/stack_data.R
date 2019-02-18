library("RJSONIO")
source("project_paths.r")
pp <<- '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/bld/project_paths.r'
source(pp)

sim_param <<- fromJSON(paste(PATH_IN_MODEL_SPECS,"/simulation_parameters.json", sep=""))
n_test=sim_param['n_test']
method = 'forest'
method_1 = 'knn'
setup_name = 'setup_1'
setup_name_1 = 'setup_2'
n=50
n_1=100
rep_number = 0
rep_number_1 = 1

path_data_row_1_front = paste(PATH_OUT_ANALYSIS,'/',method, "/", method,'_data_',setup_name,'_n=', n, '_rep_', rep_number,'.json', sep="")
path_data_row_1_back = paste(PATH_OUT_ANALYSIS,'/',method_1,"/", method_1, '_data_',setup_name,'_n=', n, '_rep_', rep_number,'.json', sep="")
path_data_row_2_front = paste(PATH_OUT_ANALYSIS,'/',method,"/", method, '_data_',setup_name_1,'_n=', n_1, '_rep_', rep_number_1,'.json', sep="")
path_data_row_2_back = paste(PATH_OUT_ANALYSIS,'/',method_1,"/", method_1, '_data_',setup_name_1,'_n=', n_1, '_rep_', rep_number_1,'.json', sep="")
row_1_front = as.array(do.call("cbind",fromJSON(path_data_row_1_front)))
row_1_back = t(do.call("cbind",fromJSON(path_data_row_1_back)))
row_2_front = as.array(do.call("cbind",fromJSON(path_data_row_2_front)))
row_2_back = as.array(do.call("cbind",fromJSON(path_data_row_2_back)))
dim(row_2_front)

if (dim(row_2_back)[1]>1)
  row_2_back =t(row_2_back)
dim(row_2_back)


row_2_front = do.call("cbind",fromJSON(path_data_row_2_front))
row_1_front = do.call("cbind",fromJSON(path_data_row_2_back))
row_1 = cbind(row_1_front, row_1_back)
row_2 = cbind(row_1_front, row_1_back)


create_dataset <- function() {
  sim_param <<- fromJSON(paste(PATH_IN_MODEL_SPECS,"/simulation_parameters.json", sep=""))
  
  for(method in sim_param['list_of_methods']){
    for (setup_name in sim_param['list_of_setups']){
      for (n in sim_param['n_list']){
        for (rep_number in repetitions){
          
          path <<- paste(PATH_OUT_ANALYSIS,'/',method, '_data_',setup_name,'_n=', n, '_rep_', rep_number,'.json', sep="")
          data <- as.data.frame(do.call("cbind", fromJSON(path)))
          
          
        }
      }
    }
  }
}
paste('path_forest', setup_name, n, rep_number, sep='') <<- paste(PATH_OUT_ANALYSIS_FOREST, '/forest_data_',setup_name,'_n=', n, '_rep_', rep_number,'.json', sep="")
paste('path_knn', setup_name, n, rep_number, sep='') <<- paste(PATH_OUT_ANALYSIS_KNN, '/knn_data_',setup_name,'_n=', n, '_rep_', rep_number,'.json', sep="")

paste('data_forest', setup_name, n, rep_number, sep='') <- fromJSON(paste('path_forest', setup_name, n, rep_number, sep=''))
setup <- fromJSON(path_forest)
data <- as.data.frame(do.call("cbind", fromJSON(path_data)))

