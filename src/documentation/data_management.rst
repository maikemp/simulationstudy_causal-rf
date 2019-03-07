.. _data_management:

***************
Data Management
***************


Documentation of the code in *src/data_management*. This folder only contains one relevant module named `get_simulated_samples.py` and it does the following things:

.. automodule:: src.data_management.get_simulated_samples
    :members:

As defined in *src/data_management/wscript*, this file is executed for all combinations of the values in "list_of_setups" and "d_list" in the *src/model_specs/simulation_parameters.json*, and that as many times as the number in "rep_number" indicates as well as for one test dataset. It then creates data snippets named `sample_[setup_name]_d=[d]_rep_[rep_number]` in *bld/out/data/[setup_name]*. The Json format is used here, because it will not be neccessary to look at these data snippets directly and they are smaller than csv data snippets would be.