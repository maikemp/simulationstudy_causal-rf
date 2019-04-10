# Simulation study on coverage probabilities of confidence intervals for heterogeneous treatment effects estimated using causal random forests

This repository contains a Waf implementation of a simulation study on the method on "Estimation and Inference for Heterogeneous Treatment Effects Using Random Forests" developed by Wager and Athey (2018). Some details on the method and the experimental setups used in this study are described in the paper_ci_crf.pdf that Waf will compile using the tex files in src/paper and the corresponding tables and graphs.

Details on the exact structure of this implementation can be found in the project_documentation.pdf that Waf compiles using the material in src/data_management and the corresponding information from the other script files. For the initial project structure and Waf configuration, I used a template from https://github.com/hmgaudecker/econ-project-templates. There can also be found further information on how to use Waf.

This implementation using primarily Python and R is my final project for the course "Effective Programming Practices for Economists" and will also be used to compute results for my master thesis. 
However, the repository does not contain the full simulation study for my master thesis but rather a computationally less expensive minimal example that demonstrates the functionality of the Waf implementation. This implementation is not specific to the causal random forest method, and could easily be extended to other (computationally expensive) prediction methods for treatment effect estimation. 

