import json
import sys
import pandas as pd

import matplotlib.pyplot as plt

from bld.project_paths import project_paths_join as ppj


def plot_tau_ci(micro_data, setup_name, d):
    
    # Subset data by covering and non covering confidence intervals. 
    ci_covers =  micro_data.loc[micro_data['crf_cov']==True]
    ci_fails =  micro_data.loc[micro_data['crf_cov']==False]
    
    plt.plot(
        micro_data['X_0'],micro_data['true_effect'], linewidth=2, label="True Treatment Effect"
    )
    plt.errorbar(
        ci_covers['X_0'], ci_covers['crf_tau'], yerr=ci_covers['half_ci_width'], 
        fmt="o", c='g', label = "Estimated TE: CI covering true TE"
        )
    plt.errorbar(
        ci_fails['X_0'], ci_fails['crf_tau'], yerr=ci_fails['half_ci_width'], 
        fmt="o", c='r', label = "Estimated TE: CI missing true TE"
        )
    plt.legend()
    plt.savefig(ppj("OUT_FIGURES", "micro_plot_{}_d={}.png".format(setup_name, d)), bbox_inches='tight')
    
    
    
if __name__ == "__main__":
    setup_name = sys.argv[1]
    d = sys.argv[2]
    micro_data = pd.DataFrame(json.load(open(ppj("OUT_ANALYSIS_CRF", 'crf_data_{}_d={}_micro_data.json'.format(setup_name,d)), encoding="utf-8")))
    micro_data.sort_values('X_0', inplace = True)

    plot_tau_ci(micro_data, setup_name, d)
