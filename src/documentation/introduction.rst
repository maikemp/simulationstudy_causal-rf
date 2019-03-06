.. _introduction:


************
Introduction
************

Documentation on the rationale, Waf, and more background is at http://hmgaudecker.github.io/econ-project-templates/.

This is a simulation study on the method for the estimation and inference of heterogeneous treatment effects using so called causal random forests introduced by :cite:`wa18`.
The method uses subsampling and is therefore computationally very expensive. In such a situation, a well-designed use of Waf can save tremendous amounts of computation time, as it is possible to try new data-generating processes or even compare it to new methods, without having to generate all the before calculated results again. Furthermore, I can keep a very low number of simulation repetitions when programming the project and only after defining all investigated data generating processes, analysis parameters and methods, after making sure that everything works fine, increase the number of simulation runs to get more reliable results and nicer graphs.  

So while not all steps of my project may seem intuitively efficient at first sight, they do serve the goal of being able to keep as much of the already-calculated data as possible, sometimes at the expense of using up more memory capacity than strictly necessary. There are three main setps of this project: first, samples ares simulated that the analysis will be performed on later on, then in the second step, the analysis is run with (two) different methods and last, the results from the analysis are processed and visualized. In the following chapters, I will explain the details of my implementation approach step by step.

.. _project_structure:

Project Structure
=================

* The folder *src/model_specs* contains four different types of json files that are required for different tasks:

	* First, there is the file *simulation_parameters.json*. It contains  information on all the items that is iterated over in the *wscript*s. First, a number in "rep_number" indicates how many repetitions the simulation includes. It is chosen very low (2) here, but it can simply be increased causing only the simulations for the additional repetitions to be run.
	Second, it contains a "list_of_setups" that has to be extended if a new setup is defined (corresponding to two other json files in this folder (*[setup_name]_dgp.json* and *[setup_name]_analysis.json*) as described below). Next, the list "te_only_by_X_0" is defined, where all the setups should be listed where the treatment effect is a function only of the first feature. Only for those setups, it makes sense to plot the treatment effect data, as described below. Next, there is "d_list", containing all the different values for the number of features in the dataset. This list can simply be edited here, leading to the additional samples to be simulated and processed. Last, there is a "list_of_methods" that contains all methods that correspond to a file in *src/analysis/estimate_[file_name].R*. This list should only be edited after making sure the only the values in *[setup_name]_analysis.json* are required for the new method or after adding a new json file for the method specific parameters and adding it to the method specific dependencies in *src/analysis/wscript*.

	For the computationally expensive parts, that are simulating the samples in the data management step and then estimating and predicting with the different methods of the analysis step, the file *simulation_parameters.json* will not be included in the dependencies because that would mean that each time the file is edited, all data would be computed again. The values are simply loaded into the *wscript*s for these steps to iterate over them. Only for the less costly parts, such as stacking together the results and making tables and graphs out of them, the information from the file is directly needed in the files (*src/analysis/stack_data.R*, *src/final/coverage_tables.R* and *src/final/plot_micro_data.py*) and thus included as a dependency. 


	The reason why k_list is part of the estimate_knn.R is that this method is not as computationally expensive, so I decided to rather recreate the knn data when editing this list over having to create an even larger number of data snippets to stack together later on. 


a number of json files, that define different data generating processes and are named after these processes. They contain specify the distribution and the number of independent variables, the names of the functions defining the propensity of treatment, the name of the treatment effect function used and the function for the main effect. These functions that are required for the data generating process are programmed in Python and the lie in the py files named after the functions in *src/model_code*.

* In *src/data_management* a file 


* The folder *src/data_management* contains
