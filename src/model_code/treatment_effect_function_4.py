import numpy as np
from scipy.stats import beta


def treatment_effect_function_4(X):
    treatment_effect = (1/2+(beta.pdf(X[0],2,2)+0.75*beta.pdf((X[0]+1.5),2,2)))
    return treatment_effect


