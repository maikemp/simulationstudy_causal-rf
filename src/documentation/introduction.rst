.. _introduction:


************
Introduction
************

Documentation on the rationale, Waf, and more background is at http://hmgaudecker.github.io/econ-project-templates/.

This is a simulation study on the method for the estimation and inference of heterogeneous treatment effects using so called Causal Random Forests introduced by :cite:`wa18`.
The method uses subsampling and is therefore computationally very expensive. In such a situation, a well-designed use of Waf can save tremendous amounts of computation time, as it is possible to try new data-generating processes or even compare it to new methods, without having to generate all the before calculated results again. Furthermore, I can keep a very low number of simulation repetitions when programming the project and only after defining all investigated data generating processes, analysis parameters and methods, after making sure that everything works fine, increase the number of simulation runs to get more reliable results and nicer graphs.  

So while not all steps of my project may seem intuitively efficient at first sight, they do serve the goal of being able to keep as much of the already-calculated data as possible, sometimes at the expense of using up more memory capacity than strictly necessary. There are three main setps of this project: first, samples ares simulated that the analysis will be performed on later on, then in the second step, the analysis is run with (two) different methods and last, the results from the analysis are processed and visualized. In the following chapters, I will explain the details of my implementation approach step by step.

.. _project_structure:

Project Structure
=================

* The folder *src/model_specs* contains four types of Json files that are used throughout the project for different tasks. First there is the file *simulation_parameters.json* that contains all values Waf uses to iterate on and to parallelize the tasks. Second, the file *k_list.json* contains all values required for the k - Nearest Neighbor estimation and predictions. The files *[setup_name]_dgp.json* contain parameters defining the data generating process of a given setup and the files *[setup_name]_analysis.json* contain the the parameters needed for the Causal Random Forest estimation and prediction. How exactly these files are used and which values the files contain is described below. 

* In *src/model_code* are all modules containing functions required for the data generating process (all Python modules) and all functions needed to derive parameters for the Causal Random Forest estimation (all R scripts). How exactly they are used is described in detail in :ref:`model_specs`.

* In *src/data_management* is contained the file *get_simulated_samples.py* that is used to simulate datasets according to the parameters given in *model_specs/[setup_name]_dgp.json*. As descirbed in the *wscript* in *src/data_management*, this file is executed for all combinations of the names in "list_of_setups", values for number of features in "d_list", and all repetitions defined in "rep_number" that are defined in *model_specs/simulation_parameters.json* and it each time saves out one dataset to *bld/out/data/[setup_name]*. 

*




