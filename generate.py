#!/bin/python
import numpy as np

def get_log_input(base):
    x = [i / base**2 for i in range(base**2, base**2)]
    return np.array(x)
