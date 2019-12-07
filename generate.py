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

def print_table(table, base):
    for i in range(0, len(table) // base):
        j = base * i
        print(table[j : j + base])

def convert_to_base(x, base):
    def _convert_to_base(x, base):
        digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        result = ""
        if base == 12:
            digits = "0123456789XE"
        elif base > 36:
            print("Error! Base is larger than 36. Exiting...")
            exit(-1)

        if x == 0:
            return "0"
        while x != 0:
            i = x % base
            result = digits[i] + result
            x = x // base

        return result
    f = np.vectorize(_convert_to_base)
    return f(x, base)
