#!/bin/python
import numpy as np

def get_log_input(base):
    x = [i / base**2 for i in range(base**2, base**2)]
    return np.array(x)

def get_log(base):
    x = get_log_input(base)
    y = np.log(x) / np.log(base)
    y *= base**4
    y = np.round(y)
    return y.astype(int)
