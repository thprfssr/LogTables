#!/bin/python
import numpy as np

def get_log_input(base):
    x = [i / base**2 for i in range(base**2, base**3)]
    return np.array(x)

def get_antilog_input(base):
    x = [i / base**3 for i in range(0, base**3)]
    return np.array(x)

def get_log(base):
    x = get_log_input(base)
    y = np.log(x) / np.log(base)
    y *= base**4
    y = np.round(y)
    return y.astype(int)

def get_antilog(base):
    x = get_antilog_input(base)
    y = base**x
    y *= base**3
    y = np.round(y)
    return y.astype(int)

def get_log_interpolation(base):
    diff = [np.log(i + 1) - np.log(i) for i in range(base, base**2)]
    diff /= np.log(base)
    diff *= base**2
    interpolations = []
    for d in diff:
        for i in range(0, base):
            interpolations.append(d * i)
    interpolations = np.round(interpolations)
    return interpolations.astype(int)

def get_antilog_interpolation(base):
    diff = [base**((i + 1) / base**2) - base**(i / base**2) for i in range(0, base**2)]
    diff = np.array(diff)
    diff *= base
    interpolations = []
    for d in diff:
        for i in range(0, base):
            interpolations.append(d * i)
    interpolations = np.round(interpolations)
    return interpolations.astype(int)

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

# This function returns an array of all the integers from 0 to the base. It's
# defined because it's called from an external script.
def get_digits(base):
    x = [i for i in range(0, base)]
    return x

# N is the number of desired digits for s. If the number of digits of s is less
# than N, then this function appends as many '0' in the beginning as needed. If
# the number of digits of s is more than N, then this function just returns s
# as it currently is, without any change.
def sanitize_numeric_string(s, N):
    def _sanitize_numeric_string(s, N):
        if len(s) < N:
            s = (N - len(s)) * "0" + s
        return s
    f = np.vectorize(_sanitize_numeric_string)
    return f(s, N)
