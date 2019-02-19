"""Draw simulated dataset using model specifications specified in
IN_MODEL_SPECS and store in a numpy array.

Module requires to be given a setup corresponding to a json file and a 
repetition number indicating the repetition currently at for the simulation. 

"""


import sys
import json
import numpy as np
import pandas as pd
from bld.project_paths import project_paths_join as ppj

import src.model_code.main_effect_functions as mef
import src.model_code.treatment_effect_functions as tef
import src.model_code.propensity_functions as pf


def _get_covariance_matrix(d, n_corr):
    """Create a covariance matrix where the number of correlated variables 
    means that those variabels are mutually correlated. Uncorrelated variabels
    are uncorrelated to all other variables.
    
    """
    if n_corr > d:
        raise ValueError('Number of mutually correlated variables must not be larger than number of variables')
    A = np.tril(np.random.uniform(-1,1,(d,d)))
    
    # Set rows of A to zero to make variables uncorrelated to the other variables
    diag = d
    for i in range(d-n_corr):
        diag = diag-1
        A[-(i+1):,:diag]=0
    cov = A.T.dot(A)
    return cov

def get_simulated_sample(setup, d):
    """Simulate a sample ..."""
    
    if setup['x_distr'] == 'normal':
        if setup['x_ncorr'] == '0':
            cov = _get_covariance_matrix(d, 0)
        if setup['x_ncorr'] == 'd':
            cov = _get_covariance_matrix(d, d)        
        else:
            raise ValueError('No defined value for number of corr. variables.')
        X = np.random.multivariate_normal(np.zeros(d),cov, setup['n'])
    if setup['x_distr'] == 'uniform':
        X = np.random.uniform(setup['x_low'], setup['x_high'],(setup['n'], d))
        
    prop_function = getattr(pf, setup['propensity_function'])
    propensity = np.apply_along_axis(prop_function, 1, X)
    
    W = np.random.binomial(1, propensity, setup['n'])
    
    treat_function = getattr(tef, setup['treatment_effect_function'])
    true_treat_effect = np.apply_along_axis(treat_function, 1, X)
    
    main_function = getattr(mef, setup['main_effect_function'])
    epsilon = np.random.normal(0, setup['sigma'], setup['n'])
    Y = np.apply_along_axis(main_function, 1, X) + W * true_treat_effect + epsilon
    
    stack = np.column_stack((X, W, Y, true_treat_effect))
    
    columns = list()
    for i in range(d):
        columns.append('X_{}'.format(i))
    columns.extend(['W', 'Y', 'true_te'])
    
    data = pd.DataFrame(stack, columns=columns)
    return data

    
if __name__ == "__main__":
    setup_name = sys.argv[1]
    d = sys.argv[2]
    rep_number = sys.argv[3]
    
    setup = json.load(open(ppj("IN_MODEL_SPECS", setup_name + ".json"), encoding="utf-8"))
    sim_param = json.load(open(ppj("IN_MODEL_SPECS", "simulation_parameters.json"), encoding="utf-8"))

    data = get_simulated_sample(setup, int(d))

    data.to_json(ppj("OUT_DATA_" + setup_name.upper(), "sample_{}_d={}_rep_{}.json".format(setup_name, d, rep_number)))    

