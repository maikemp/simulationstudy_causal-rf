"""Define all functions describing the treatment effect.

"""

import numpy as np


def _treatment_factor_1(x):
    factor = 2/(1+np.exp(-12*(x-0.5)))
    return factor


def treatment_effect_function_1(X):
    treatment_effect = _treatment_factor_1(X[0])*_treatment_factor_1(X[1])
    return treatment_effect
