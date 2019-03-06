.. _analysis:

************************************
Main model estimations / simulations
************************************

Documentation of the code in *src.analysis*. This is the core of the project. 
The folder *src/analysis* contains the three files *estimate_crf.R*, *estimate_knn.R* and *stack_data.R*. The first two are also executed for all combinations of the values in "list_of_setups", "d_list" and all numbers up to "rep_number" from *model_specs/simulation_parameters.json*. They load the data snippet created in the data management step corresponding to these three values from *bld/out/data/[setup_name]* and each save out a new data snippet in *bld/out/analysis/[method_name]* named *[method_name]_datta_[setup_name]_d=[d]_rep_[rep_number].json*. The *estimate_crf.R* file in addition creates a dataset containing the values of the first feature, the true and the estimated treatment effect as well as a coverage indicator and a value for the width of the estimated confidence interval for each observation of the test dataset predicted with the results from the first simulation repetition as *bld/out/analysis/crf/crf_data_setup_d=[d]_micro_data.json*.
*stack_data.R* then stacks all the data snippets together into *bld/out/analysis/full_analysis_data.csv*. This stacking is done in a separate step because in contrast to the analysis step itself, it is not computationally expensive. New datasnippets can be created for example for new setups while keeping the old snippets for the already existing setups in place. All the data can than simply be stacked together to one large dataset saving a tremendous amount of execution time compared to a situation where the analysis files all have the same target and would thus for any modification of any setup have to run the whole analysis again.
More details of the individual modules are given below.


Estimate Causal Random Forests
==============================

The file "estimate_crf.R" estimates treatment effects by causal forests 
and confidence intervals for them using the causalForest functions 
written by Wager & Athey (2018) and saves out data snippets with the analysis
results as well as a dataset containing per-observation analysis data for the 
first repetition of the simulation.

The file expects to be given a setup_name, a value for d and a number
for the simulation repetition currently at from the wscript. It takes
the simulated dataset corresponding to these values from PATH_OUT_DATA 
and saves out a one-line json-datafile containing aggregate information on 
the mse and the coverage frequency for the causal random forest estimator and 
the corresponding confidence intervals, as well as further information on 
the dataset processed to PATH_OUT_ANALYSIS_CRF. For the first repetition number
it also creates there a data file containing the values of the first feature, 
the true and the estimated treatment effect as well as a coverage indicator and 
the width of the estimated confidence interval for each observation.

It uses information the parameters given in ``[setup_name]_analysis.json`` in the
PATH_IN_MODEL_SPECS. It needs the following values from there: 
 * A specification of the foresttype
 * A specification of a number for n_tree or a function name for which the 
   corresponding function will then be loaded form *PATH_IN_MODEL_CODE/n_tree_functions.R* 
 * A specification of a number for sample_size or a function name for which the 
   corresponding will then be loaded form *PATH_IN_MODEL_CODE/sample_size_functions.R*
 * A value for node_size
 * A value for the confidence level alpha


Estimate k Nearest Neighbor
===========================

The file "estimate_knn.R" estimates treatment effects by k - Nearest
Neighbor matching and saves out data snippets with the analysis results.

The file expects to be given a setup_name, a value for d and a number
for the simulation repetition currently at from the wscript. It takes
a simulated dataset from PATH_OUT_DATA and saves out a one-line dataset
containing aggregate information on the mse and the coverage frequency for 
the k nearest neighbor estimator and the corresponding confidence intervals, 
as well as further information on the dataset processed to PATH_OUT_ANALYSIS_KNN.
It does so for all values given in k_list.json in PATH_IN_MODEL_SPECS and 
uses value in "alpha" from the ``[setup_name]_analysis.json`` file that is also 
taken from PATH_IN_MODEL_SPECS.

Stack Data
==========

The file "stack_data.R" loads all data snippets produced by the 
``estimate_[method_name].R`` files and stacks them together into one 
csv dataframe calles ``full_analysis_data.csv`` in PATH_OUT_ANALYSIS.

