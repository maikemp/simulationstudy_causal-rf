"""Define here all functions describing how outcome is generated if there was 
no treatment assignment.

"""


def base_effect_function_1(x):
    main_effect = 2 * (x[1] - 0.5)
    return main_effect


def base_effect_function_2(x):
    main_effect = 0
    return main_effect
