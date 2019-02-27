import numpy as np


def treatment_effect_function_2(X):
    treatment_effect = _treatment_factor_2(X[0])*_treatment_factor_2(X[1])
    return treatment_effect


def _treatment_factor_2(x):
    factor = (1+1/(1+np.exp(-20*(x-(1/3)))))
    return factor
