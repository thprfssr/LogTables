#!/bin/bash

logarithms_script='logarithms.py'
logarithm_sanitize='logarithm_sanitize.sed'

# args: base
function generate_logarithms
{
	base=$1
	tmp=/tmp/$(printf "%x%x" $RANDOM $RANDOM).txt
	python <<EOF > $tmp
from $(basename $logarithms_script .py) import *
x = get_log($base)
x = convert_to_base(x, $base)
x = sanitize_numeric_string(x, 4)
print_table(x, $base)
EOF
	str=$(tr -d "\n" < $tmp) # get rid of all newlines
	echo $str | sed -f $logarithm_sanitize
}
