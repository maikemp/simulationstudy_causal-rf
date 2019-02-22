"""Define here all functions describing how outcome is generated if there was 
no treatment.

"""


def main_effect_function_1(x):
    main_effect = 2 * (x[1] - 0.5)
    return main_effect
