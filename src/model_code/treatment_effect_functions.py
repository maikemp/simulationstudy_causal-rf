import pandas as pd
import numpy as np

def treatment_factor_1(x):
    factor = 2/(1+np.exp(-12*(x-0.5)))
    return factor

def treatment_effect_1(X):
    treatment_effect = treatment_factor_1(X[0])*treatment_factor_1(X[1])
    return treatment_effect
