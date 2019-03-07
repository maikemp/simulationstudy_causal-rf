.. _final:

************************************
Visualisation and results formatting
************************************


In *src/final* there are two different files for two different tasks. `coverage_tables.R` takes the results for one given setup name from *bld/out/analysis/full_analysis_data.csv*, aggregates over all simulation repetitions and makes a latex table out of it in *bld/out/tables/coverage_table_[setup_name].tex*. It is iterated over by Waf for all names in "list_of_setups" of *src/model_specs/simulation_parameters.json*. The second file is `plot_micro_data.py`. It plots the true and the estimated treatment effect with the bounds of the confidence intervals in red or green color if the CI misses and coveres the true values, against the values of the first feature, for all values given in "d_list" of *src/model_specs/simulation_parameters.json" and makes one multiplot for all these d values. It is executed only for the setups listed in "te_only_by_X_0" of the before mentioned json file and only for the first repetition of the simulation. The resulting multiplots are saved as *bld/out/figures/te_plot_[setup_name].png*. 

The results of both modules are then used for `paper_ci_crf.pdf` and `presentation.pdf`.


Create coverage tables
======================

The file `coverage_tables.R` uses the compact analysis data, averages 
over simulation runs and makes a latex table out of the results.

This file expects to be given the setup_name through the command line.
It takes the corresponding data from *bld/out/analysis/full_analysis_data.csv*
and it writes ``coverage_table_[setup_name].tex`` to PATH_OUT_TABLES.
It therefore reuiqres information from simulation_parameters.json and 
the values for k in k_list.json in PATH_IN_MODEL_SPECS.


Plot micro data
===============

.. automodule:: src.final.plot_micro_data
    :members:
