#!/bin/bash

logarithms_script='logarithms.py'
logarithm_sanitize='logarithm_sanitize.sed'

# args: base
function generate_logarithms
{
	base=$1
	str=$(python <<EOF
from $(basename $logarithms_script .py) import *
x = get_log($base)
x = convert_to_base(x, $base)
x = sanitize_numeric_string(x, 4)
print_table(x, $base)
EOF
)
	echo $str | tr -d "\n" | sed -f $logarithm_sanitize
}
