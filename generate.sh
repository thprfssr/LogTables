#!/bin/bash

logarithms_script='logarithms.py'
sanitize='sanitize.sed'

# If the mode is "logarithm", then the function prints the columns of
# logarithms. If the mode is "interpolation", then the function prints the
# columns of the mean differences. Otherwise, the program dies.
# args: mode, base
# mode: "logarithm", "interpolation"
function generate
{
	mode=$1
	base=$2
	if [[ "$mode" == "logarithms" ]]; then
		func=get_log
		n=4
	elif [[ "$mode" == "interpolations" ]]; then
		func=get_interpolation
		n=1
	else
		echo Unrecognized mode \"$mode\". Exiting...
		exit -1
	fi

	str=$(python <<EOF
from $(basename $logarithms_script .py) import *
x = $func($base)
x = convert_to_base(x, $base)
x = sanitize_numeric_string(x, $n)
print_table(x, $base)
EOF
)
	echo $str | tr -d "\n" | sed -f $sanitize
}
