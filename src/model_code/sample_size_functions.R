'

In the file sample_size_functions.R, I define all functions descirbing how 
to choose the sample size used for the causal random forest estimation.

'


sample_size_function_1 <- function(n){
  s <- n/4
  return(s)
}
