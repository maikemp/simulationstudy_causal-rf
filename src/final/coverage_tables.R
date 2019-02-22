'

The file "coverage_tables.R" uses the compact analysis data, averages 
over simulation runs and makes a latex table out of the results.

'


packages = c("xtable", "RJSONIO")

package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }
})
source("project_paths.r")


create_output_table <- function(setup_name){
  
  sim_param <<- fromJSON(paste0(PATH_IN_MODEL_SPECS,"/simulation_parameters.json"))
  
  analysis_data <- read.csv(paste0(PATH_OUT_ANALYSIS,"/full_analysis_data.csv"))
  setup_data <- analysis_data[analysis_data$setup==setup_name,]
  
  data_table = data.frame(d = as.integer(sim_param$d_list))
  
  for (method in sim_param$list_of_methods){
    if (method == "knn"){
      
      for(k in sim_param$k_list){
        
        knn_values = data.frame()
        for (d in sim_param$d_list){
          coverage = mean(unlist(setup_data[paste0(method, "_covered_", k)][setup_data$d==d,]))
          mse = mean(unlist(setup_data[paste0(method, "_mse_", k)][setup_data$d==d,]))
          line = cbind(coverage, mse)
          colnames(line)<- c(paste0("Coverage ", k, "-NN"),paste0("MSE ", k ,"-NN"))
          knn_values = rbind(knn_values,line)
        }
        data_table = cbind(data_table, knn_values)
      }
    } else {
      values = data.frame()
      for (d in sim_param$d_list){
        coverage = mean(unlist(setup_data[paste0(method, "_covered")][setup_data$d==d,]))
        mse = mean(unlist(setup_data[paste0(method, "_mse")][setup_data$d==d,]))
        line = cbind(coverage, mse)
        colnames(line)<- c(paste('Coverage', toupper(method)),paste('MSE', toupper(method)))
        values = rbind(values,line)
      }
      data_table = cbind(data_table, values)
    }
  }
  data_table <-cbind(data_table['d'], data_table[,(2:ncol(data_table))][, order(names(data_table[,(2:ncol(data_table))]))])
  return(data_table)
}

write_to_latex <- function(output_table, setup_name){
  
  xtab <-  xtable(output_table, caption = paste('Simulation results for', gsub('_', " ", setup_name)))
  colnames(xtab) <- gsub('^.* ', "", colnames(output_table))
  
  addtorow <- list()
  addtorow$pos <- list(-1)
  addtorow$command <- paste0(paste0('& \\multicolumn{', length(sim_param$list_of_methods)+length(sim_param$k_list)-1,'}{c}{', c('CI Coverage Rate', 'Mean Squared Error'), '}', collapse=''), '\\\\')
  
  path = paste0(PATH_OUT_TABLES, '/coverage_table_', setup_name, '.tex')
  print(xtab, add.to.row=addtorow, include.rownames=F, file= path)
  
}
args = commandArgs(trailingOnly = TRUE)
setup_name = args[1]

output_table <- create_output_table(setup_name)
write_to_latex(output_table, setup_name)


