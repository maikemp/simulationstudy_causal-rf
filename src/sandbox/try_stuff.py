#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Feb  6 11:32:38 2019

@author: maike-mp
"""
import pandas as pd
import numpy as np
import pickle

df = pd.DataFrame(np.array([[0.03, 2, 3], [0.2, 5, 6], [1, 3, 7]]))
path = r'/Users/maike-mp/UniBonn/5.Semester/MasterThesis/simulationstudy_ci_causal_rf/bld/out/data/'

data_1 = pd.read_pickle(path + 'sample_setup_1_rep_1.pickle')
data_2 = pd.read_pickle(path + 'sample_setup_1_rep_2.pickle')
data_3 = pd.read_pickle(path + 'sample_setup_1_rep_3.pickle')
data_4 = pd.read_pickle(path + 'sample_setup_2_rep_1.pickle')
data_5 = pd.read_pickle(path + 'sample_setup_2_rep_2.pickle')
data_6 = pd.read_pickle(path + 'sample_setup_2_rep_3.pickle')

np.mean(data_1.X_0)
np.mean(data_2.X_0)
np.mean(data_3.X_0)
np.mean(data_4.X_0)
np.mean(data_5.X_0)
np.mean(data_6.X_0)



type(df)

y=(df[1]-0.5)*2
np.exp(y)


def treatment_factor_1(x):
    factor = 2/(1+np.exp(-12*(x-0.5)))
    return factor

def treatment_effect_1(X):
    treatment_effect = treatment_factor_1(X[0])*treatment_factor_1(X[1])
    return treatment_effect

treatment_effect_1(df)
y=treatment_factor_1(df[0])*treatment_factor_1(df[1])
z=treatment_factor_1(df[1])
y*z

df[1]*df[2]
df