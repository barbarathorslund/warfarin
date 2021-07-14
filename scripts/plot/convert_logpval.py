import pandas as pd
from bigfloat import *
from bigfloat import log10
import numpy as np

# Convert p values to -log10(p), and write file
def log_pvalue():
    df = pd.read_csv('meta_warf_sumstat.txt', delimiter = " ", dtype=str)

    pval = df['P-value'].values
    pval = np.array([BigFloat.exact(val, precision=4) for val in pval])

    for i in range(len(pval)):
        pval[i] = -log10(pval[i])

    df['P-value'] = pval

    df.to_csv('meta_warf_sumstat_log.txt', sep = " ")

log_pvalue()
