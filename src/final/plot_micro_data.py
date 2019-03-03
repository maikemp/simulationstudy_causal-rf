import json
import sys
import pandas as pd
import numpy as np

import matplotlib.pyplot as plt
from bld.project_paths import project_paths_join as ppj


def plot_tau_ci(setup_name, d_list):
    """Make a plot showing the true treatment effect as a function of X[0] and 
    the estimated treatment effects with whiskers representing the width of 
    the estimated confidence interval, in green if the interval covers the 
    true effect and in red if it doesn't.

    """

    nrows = int(np.ceil(len(d_list) / 2 - 0.01))
    figsize = (2 * 3, nrows * 3)
    fig, axes = plt.subplots(nrows=nrows, ncols=2, figsize=figsize)

    fig.subplots_adjust(
        left=0.1, right=0.95, bottom=0.2, top=0.9, wspace=0.25, hspace=0.4
    )

    for item, ax in np.ndenumerate(axes):

        i = item[0] * 2 + item[1]
        if i == len(d_list):
            # Remove last element if number of cycles is uneven.
            fig.delaxes(ax)
            break

        d = d_list[i]

        micro_data = pd.DataFrame(
            json.load(open(
                ppj("OUT_ANALYSIS_CRF",
                    'crf_data_{}_d={}_micro_data.json'.format(setup_name, d)
                    ),
                encoding="utf-8"))
        )
        micro_data.sort_values('X_0', inplace=True)

        # Subset data by covering and non covering confidence intervals.
        ci_covers = micro_data.loc[micro_data['crf_cov'] == True]
        ci_fails = micro_data.loc[micro_data['crf_cov'] == False]

        ax.set_title('d = {}'.format(d))
        ax.errorbar(
            ci_covers['X_0'],
            ci_covers['crf_tau'],
            yerr=ci_covers['half_ci_width'],
            fmt="o",
            c='g',
            label="Estimated TE: CI covering true TE"
        )
        ax.errorbar(
            ci_fails['X_0'],
            ci_fails['crf_tau'],
            yerr=ci_fails['half_ci_width'],
            fmt="o",
            c='r',
            label="Estimated TE: CI missing true TE"
        )
        ax.plot(
            micro_data['X_0'],
            micro_data['true_effect'],
            linewidth=2,
            label="True Treatment Effect",
            c="black",
            zorder=10
        )
        # Attach a legend below the last plot only.
        if d == d_list[-1]:
            box = ax.get_position()
            ax.set_position(
                [box.x0, box.y0 + box.height * 0.1, box.width, box.height * 0.9]
            )

            # Put a legend below last axis only.
            ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1), ncol=1)

    fig.savefig(ppj("OUT_FIGURES", "te_plot_{}.png".format(setup_name)))


if __name__ == "__main__":
    setup_name = sys.argv[1]

    sim_param = json.load(
        open(ppj("IN_MODEL_SPECS", "simulation_parameters.json")))
    d_list = sim_param['d_list']
    d_list = [str(par) for par in sim_param['d_list']]

    plot_tau_ci(setup_name, d_list)
