.. _model_code:

**********
Model code
**********


The directory *src.model_code* contains source files that might differ by model and that are potentially used at various steps of the analysis.

For example, you may have a class that is used both in the :ref:`analysis` and the :ref:`final` steps. Additionally, maybe you have different utility functions in the baseline version and for your robustness check. You can just inherit from the baseline class and override the utility function then.


The functions used for the data generation
===========================================
As described in  :cite:`wa18`, the data generating process requires three functions: 

* The different treatment effect functions are contained in the python files named *treatment\_effect\_function\_?.py*. 

* The different propensity functions are contained in the python files named *propensity\_function\_?.py*. 

* The different base effect functions are contained in the python files named *base\_effect\_function\_?.py*. It corresponds to the main effect function used :cite:`wa18` in such a way that it from all three functions, the main effect function can easily be calculated

