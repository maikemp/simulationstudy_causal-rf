"""Define all functions describing the treatment effect.

"""

import numpy as np


def treatment_effect_function_2(X):
    treatment_effect = _treatment_factor_1(X[0])*_treatment_factor_1(X[1])
    return treatment_effect


def _treatment_factor_1(x):
    factor = 2/(1+np.exp(-12*(x-0.5)))
    return factor
