.. _final:

************************************
Visualisation and results formatting
************************************


Documentation of the code in *src.final*.


Create coverage tables
======================

The file "coverage_tables.R" uses the compact analysis data, averages 
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
