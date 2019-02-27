from scipy.stats import beta


def propensity_function_1(X):
    propensity = (1/4)*(1+beta.pdf(X[0],2,4))
    return propensity
