
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from project_paths import project_paths_join as ppj
"""
Created on Wed Feb  6 11:32:38 2019

@author: maike-mp
"""
import pandas as pd
import numpy as np
import json
import os
import importlib
from scipy.stats import beta

def treatment_effect_function_2(X):
    treatment_effect = _treatment_factor_2(X[0])*_treatment_factor_2(X[1])
    return treatment_effect


def _treatment_factor_2(x):
    factor = 1+1/(1+np.exp(-20*(x-(1/3))))
    return factor

treatment_effect_function_2(np.array([0.5,-0.9]))


x_0=np.linspace(-1,1,201)
x_1=np.linspace(-1,1,201)

x = pd.DataFrame(np.array(range(201)))
data = pd.DataFrame(x,x_0,x_1)
data.columns = [['x_0','x_1']]

y=treatment_effect_function_2([x_0, x_1])

y = np.apply_along_axis(treatment_effect_function_2,1,x)


def test(x):
    p=(1/4)*(1+beta.pdf(x,2,4))
    return p
test(0.8)
y = np.apply_along_axis(test,1,x)
data['y']=test(data['x'])
import matplotlib
import matplotlib.pyplot as plt
plt.plot(x_0,y)

y=test(x)
test(0.5)
    
x = list(range(-1,1,0.1))
beta(2,4,)

path = r'/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/src/model_specs/simulation_parameters.json'
path_1 = r'/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/src/model_specs/setup_1.json'
setup = json.load(open(path_1), encoding='utf-8')

path_2 = r'/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/bld/project_paths.py'
import path_2






repetitions = [str(par) for par in range(sim_param['rep_number'])]
n_list = [str(par) for par in sim_param['n_list']]
n_test = str(sim_param["n_test_points"])
ctxs = 5

str(ctxs).isnumeric()


deps = [
    print(ctxs, 'IN_MODEL_CODE', 'sample_size_functions.R'),
    print(ctxs, 'IN_MODEL_CODE', 'n_tree_functions.R'),

    for setup in sim_param["list_of_setups"]:
    print(ctxs, 'IN_MODEL_SPECS', '{}.json'.format(setup)),
    print(ctxs, 'OUT_DATA_' + setup.upper(),
          'sample_{}_n={}_rep_test.json'.format(setup, n_test)),

    for n in n_list:
        for rep_number in repetitions:
            print(ctxs, / 'OUT_DATA_/' + setup.upper(), 'sample_{}_n={}_rep_{}.json'.format(setup, n, rep_number)),
]


def test_function(x="fix_x", n="fix_n", d="fix_d"):
    print(x, n, d)


test_function("new_x")
X = ['first_x', 'second_x', 'third_x']
N = ['first_n', 'second_n', 'third_n']
D = ['first_d', 'second_d', 'third_d']

test_function()
string = [
    [[[for x in X:
        test_function(x)],
        for n in N:
            test_function(x, n)],
     for d in D:
     test_function(x, n, d), ]]


sim_param = json.load(open(path), encoding='utf-8')
str(sim_param['n_test_points'])
n_list = [str(par) for par in sim_param['n_list']]
n_list = [str(sim_param['n_test_points'])]
repetitions = [str(par) for par in range(sim_param['rep_number'])]
repetitions[2]
repetitions = [str(par) for par in range(sim_param['rep_number'])]
rep_1 = repetitions+['test']
repetitions

a = list()
for rep_number in repetitions:
    if rep_number == 'test':
        n_list = [str(sim_param['n_test_points'])]
    else:
        n_list = [str(par) for par in sim_param['n_list']]
    a.append(n_list)


dep_string = "OUT_DATA_"+"setups_1".upper()
n = "3"
m = int(n)
m*2
n = [1, 2, 3]
[str(par) for par in n]


f"/out/data/{dep_string}"

test = {}
test["bla"+dep_string] = f"some_string_{dep_string}"

df = pd.DataFrame(np.array([[0.03, 2, 3], [0.2, 5, 6], [1, 3, 7]]))
path = a r'/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/bld/out/data/'


a = ['test', [str(par) for par in (sim_param['rep_number'])]]


a = [str(par) for par in range(3)]
a.extend(['test'])
repetitions = [str(par) for par in range(sim_param['rep_number'])]
repetitions.extend(['test'])
