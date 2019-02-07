"""Draw simulated dataset using model specifications specified in
IN_MODEL_SPECS and store in a numpy array.

...(explain more precisely what is happening here)...

"""



import sys
import json
import numpy as np
import pandas as pd
import pickle
from bld.project_paths import project_paths_join as ppj

import src.model_code.main_effect_functions
import src.model_code.treatment_effect_functions
import src.model_code.propensity_functions

##später wieder löschen: !!
path = '/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/src/model_code/propensity_functions.py'
import os
import sys
sys.path.append(os.path.dirname(os.path.expanduser(path)))
import propensity_functions as pf
import treatment_effect_functions as tef
import main_effect_functions as mef

model = json.load(
    open('/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/src/model_specs/setup_1.json'), encoding="utf-8"
)

model = json.load(open(ppj("IN_MODEL_SPECS", setup + ".json"), encoding="utf-8"))

def get_simulated_sample(setup):
    """Simulate a sample ..."""
    
    if model['x_distr'] == 'normal':
        X = np.random.multivariate_normal(model['x_mean'], model['x_cov'], model['n'])     
    if model['x_distr'] == 'uniform':
        X = np.random.uniform(model['x_low'], model['x_high'],(model['n'],model['d']))
        
    prop_function = getattr(pf, model['propensity_function'])
    propensity = np.apply_along_axis(prop_function, 1, X)
    
    W = np.random.binomial(1, propensity, model['n'])
    
    treat_function = getattr(tef, model['treatment_effect_function'])
    true_treat_effect = np.apply_along_axis(treat_function, 1, X)
    
    main_function = getattr(mef, model['main_effect_function'])
    epsilon = np.random.normal(0, model['sigma'], model['n'])
    Y = np.apply_along_axis(main_function, 1, X) + W * true_treat_effect + epsilon
    
    stack = np.column_stack((X, W, Y, true_treat_effect))
    
    columns = list()
    for i in range(model['d']):
        columns.append('X_{}'.format(i))
    columns.extend(['W', 'Y', 'true_te'])
    
    data = pd.DataFrame(stack, columns=columns)
    return data
 
test = get_simulated_sample(model)
 

