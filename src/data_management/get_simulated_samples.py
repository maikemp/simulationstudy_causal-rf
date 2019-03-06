"""Draw simulated dataset using model specifications specified in
IN_MODEL_SPECS and store in a json file in OUT_DATA.

Module requires to be given a setup_name corresponding to a json file called 
``[setup_name]_dgp.json`` in IN_MODEL_SPECS, the number of features d as well 
as a rep_number indicating the repetition currently at for the simulation. It 
loads the required functions for the base effect, the treatment effect and the 
propensity score from the repective modules in IN_MODEL_CODE.

"""

import sys
import json
import numpy as np
import pandas as pd
import importlib
from bld.project_paths import project_paths_join as ppj


def _get_covariance_matrix(d, n_corr):
    """Create a covariance matrix where the number of correlated variables 
    means that those variabels are mutually correlated. Uncorrelated variabels
    are uncorrelated to all other variables.

    """

    if n_corr > d:
        raise ValueError(
            'Nr of corr. variables must not be larger than nr of variables'
        )
    A = np.tril(np.random.uniform(-1, 1, (d, d)))

    # Set rows of A to zero to make variables uncorrelated to other variables.
    diag = d
    for i in range(d-n_corr):
        diag = diag-1
        A[-(i+1):, :diag] = 0
    cov = A.T.dot(A)
    return cov


def get_simulated_sample(setup, d):
    """Draw a simulated sample according to a set of parameter values.

    """

    if setup['x_distr'] == 'normal':
        if setup['x_ncorr'] == 'd':
            cov = _get_covariance_matrix(d, d)
        else:
            cov = _get_covariance_matrix(d, setup['x_ncorr'])

        X = np.random.multivariate_normal(np.zeros(d), cov, setup['n'])
    if setup['x_distr'] == 'uniform':
        X = np.random.uniform(setup['x_low'], setup['x_high'], (setup['n'], d))

    prop_function = getattr(pf, setup['propensity_function'])
    propensity = np.apply_along_axis(prop_function, 1, X)

    W = np.random.binomial(1, propensity, setup['n'])

    treat_function = getattr(tef, setup['treatment_effect_function'])
    true_treat_effect = np.apply_along_axis(treat_function, 1, X)

    base_function = getattr(bef, setup['base_effect_function'])
    epsilon = np.random.normal(0, setup['sigma'], setup['n'])

    Y_0 = np.zeros(len(X))
    for i in range(len(X)):
        Y_0[i] = base_function(X[i], true_treat_effect[i])

    Y = Y_0 + W * true_treat_effect + epsilon
    stack = np.column_stack((X, W, Y, true_treat_effect))

    # Name the columns so they can be identified easily.
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
    setup = json.load(
        open(
            ppj("IN_MODEL_SPECS", setup_name + "_dgp.json"),
            encoding="utf-8"
        )
    )

    # Import the required functions that are defined as a string in the setup.
    bef = importlib.import_module(
        'src.model_code.' + setup['base_effect_function']
    )
    tef = importlib.import_module(
        'src.model_code.' + setup['treatment_effect_function'])
    pf = importlib.import_module(
        'src.model_code.' + setup['propensity_function'])

    # Set the seedgenerating number to a number that will not be reached for a
    # method this computationally expensive.
    seed_rep = rep_number
    if seed_rep == 'test':
        seed_rep = '999'

    # Generate a seed depending on input parameters since fixed seed would
    # lead to producing the same data for each simulation repetition.
    seed = int(setup_name[-1]+seed_rep+d +
               str(len(setup_name))+str(len(seed_rep))+str(len(d)))
    np.random.seed(seed)
    data = get_simulated_sample(setup, int(d))

    data.to_json(
        ppj(
            "OUT_DATA_" + setup_name.upper(),
            "sample_{}_d={}_rep_{}.json".format(setup_name, d, rep_number)
        )
    )
