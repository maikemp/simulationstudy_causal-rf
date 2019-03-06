.. _model_code:

**********
Model code
**********


The directory *src.model_code* contains Python source files that are used in the :ref:`data_management` step and R scripts that are used in the Causal Random Forest estimation in the :ref:`analysis` step.


The functions used for the data generation
===========================================
As described in  :cite:`wa18`, the data generating process requires three functions: 

* The different treatment effect functions are contained in the python files named *treatment\_effect\_function\_[i].py*. 

* The different propensity functions are contained in the python files named *propensity\_function\_[i].py*. 

* The different base effect functions are contained in the python files named *base\_effect\_function\_[i].py*. It corresponds to the main effect function used in :cite:`wa18` in such a way that from all three functions, the main effect function can easily be calculated

*[i]* is simply a counter for the different files. Which file exactly is required in the current execution of *src/data_management/get_simulated_samples.py* depends on the process defined in the different *src/model_specs/[setup_name]_dgp.json* files. Each function is stored in its own file so that it is easier to add new functions for new setups without waf computing all data from new.

The functions used for the Causal Random Forest estimation
===========================================================

* The different values specifying the number of trees used in a forest are in the R module named *n_tree_functions.R*.

* The different values specifying the subsample size used in the Causal Random Forest estimation are in the R module named *sample_size_functions.R*.

As described in detail in :ref:`model_specs`, these files may be or may not be used to derive the required values in *src/analysis/estimate_crf.R*, depending on the values given in *src/model_specs/[setup_name]_analysis.json*. If there is only given numeric values instead of a strings corresponding to functions in these files, the numeric value will be used directly instead.
