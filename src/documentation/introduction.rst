.. _introduction:


************
Introduction
************

Documentation on the rationale, Waf, and more background is at http://hmgaudecker.github.io/econ-project-templates/

This is a simulation study on the method for the estimation and inference of heterogeneous treatment effects using so called causal random forests introduced by :cite:`wa18`.
The method uses subsampling as described in the research paper and is computationally very expensive. In such a situation, a well-designed use of Waf can save tremendous amounts of computation time, as it is possible to try new data-generating processes or even compare it to new methods, without having to generate all the before calculated results again. Furthermore, I can keep a very low number of simulation repetitions when programming the project and only after defining all investigated data generating processes, analysis parameters and methods, after making sure that everything works fine, successively increase the number of simulation runs to get more reliable results and nicer graphs.  

So while not all steps of my project may seem intuitively efficient at first sight, they do serve the goal of being able to keep as much of the already-calculated data as possible, sometimes at the expense of using up more memory capacity than strictly necessary. In the following chapters, I will explain the details of my implementation approach step by step.

.. _project_structure:

Project Structure
=================

* The folder *src/model_specs* contains a number of json files, that define different data generating processes and are named after these processes. They contain specify the distribution and the number of independent variables, the names of the functions defining the propensity of treatment, the name of the treatment effect function used and the function for the main effect. These functions that are required for the data generating process are programmed in Python and the lie in the py files named after the functions in *src/model_code*.


* The folder *src/data_management* contains
