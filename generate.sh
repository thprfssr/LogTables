#!/bin/zsh

logarithms_script='logarithms.py'
sanitize='sanitize.sed'


# This function makes all the necessary calculations to generate log and antilog
# tables. The purpose of this function is to print the columns of the table,
# formatted for LaTeX's tabular environment. This means that each column is
# separated by the '&' character, and each column entry is enclosed between two
# matching '$' characters.
#
# Disclaimer: It is not the task of this function to generate a fully-formatted
# LaTeX table.
#
# For the sake of code brevity, this function accepts three variables: mode,
# base, and part. The base must be an integer strictly greater than 1. The mode
# can be either 'log', 'antilog', or 'digits'.
#
# If the mode is 'log' or 'antilog', then the function takes a look at the value
# at the variable called part. The part can be either 'principal' or
# 'interpolation'. This tells the function whether to print the principal
# columns of the table (i.e. the ones containing the logarithms or
# antilogarithms), or to print the columns containing the interpolations.
#
# It the mode variable is set to 'digits', then the function prints all the
# digits for the given base. In this case, the part variable is ignored.
#
# NOTE: This function does not check if mode, base, and part are all within
# their allowed ranges.
#
# args: mode base part
# mode: 'log' or 'antilog'
# base: integer strictly greater than 1
# part: 'principal' or 'interpolation'
function generate
{
	mode=$1
	base=$2
	part=$3
	n=1 # This is the default number of desired digits for each entry to have
	if [[ "$mode" == "digits" ]]; then
		func=get_digits
	elif [[ "$part" == "principal" ]]; then
		func=get_$mode
		n=4 # Notice that n is changed in this case
	elif [[ "$part" == "interpolation" ]]; then
		func=get_${mode}_interpolation
	fi

	str=$(python <<EOF
from $(basename $logarithms_script .py) import *
x = $func($base)
x = convert_to_base(x, $base)
x = sanitize_numeric_string(x, $n)
print_table(x, $base)
EOF
)
	# We run the raw output of the Python script through a sed script which
	# formats it for LaTeX's tabular environment.
	str=$(echo $str | tr -d "\n" | sed -f $sanitize)

	# If the part variable is set to 'interpolation', then the first column
	# is all zeroes, so we delete it.
	if [[ "$part" == "interpolation" ]]; then
		str=$(echo $str | sed "s/\$0\$ \& //1")
	fi

	echo $str
}

# This function prints a newline-separated list of integers from base to base^2,
# if the mode is 'log', or from 0 to base^2, if the mode is 'antilog'.
#
# NOTE: The output of this function is not wrapped around '$' characters for
# LaTeX's math mode. This must be done by whoever calls the function.
# NOTE: This function does not check that the given arguments fall within their
# allowed ranges.
#
# args: mode base
# mode: 'log' or 'antilog'
# base: integer strictly greater than 1
function print_main_column
{
	mode=$1
	base=$2
	if [[ "$mode" == "log" ]]; then
		lower_limit=$base
	elif [[ "$mode" == "antilog" ]]; then
		lower_limit=0
	else
		echo "Unrecognized mode $mode. Exiting..."
		exit -1
	fi
	python <<EOF
from $(basename $logarithms_script .py) import *
x = [i for i in range($lower_limit, $base**2)]
x = convert_to_base(x, $base)
for s in x:
    print(s)
EOF
}

# Get the 'table spec' option for the LaTeX tabular environment.
# 
# NOTE: This function does not check whether the given arguments fall within
# their allowed ranges.
#
# args: base
# base: integer strictly greater than 1
function get_table_spec
{
	if (( $base == 6 )); then
		echo '{|c|ccc|ccc||ccccc|}'
	elif (( $base == 8 )); then
		echo '{|c|cccc|cccc||cc|ccc|cc|}'
	elif (( $base == 10 )); then
		echo '{|c|ccccc|ccccc||ccc|ccc|ccc|}'
	elif (( $base == 12 )); then
		echo '{|c|cccc|cccc|cccc||cccc|ccc|cccc|}'
	elif (( $base == 16 )); then
		echo '{|c|cccc|cccc|cccc|cccc||ccccc|ccccc|ccccc|}'
	else
		printf "{|c|"
		printf "c%.0s" {1..$base}
		printf "||"
		printf "c%.0s" {2..$base}
		printf "|}\n"
	fi
}

# Fill out the main body of the LaTeX tabular object with the input column
# (which contains the number whose logarithm or antilogarithm is taken), the
# principal columns (either logarithms or antilogarithms), and the interpolation
# columns.
#
# NOTE: This function does not check whether the given arguments fall within
# their allowed ranges.
#
# args: mode base
# mode: 'log' or 'antilog'
# base: integer strictly greater than 1
function get_tabular_body
{
	mode=$1
	base=$2

	principals=$(generate $mode $base principal)
	interpolations=$(generate $mode $base interpolation)
	main=$(print_main_column $mode $base)
	n=$(echo $main | wc -l)

	for i in {1..$n}; do
		# get the i-th lines
		L=$(echo $principals | sed "${i}q;d")
		I=$(echo $interpolations | sed "${i}q;d")
		M=$(echo $main | sed "${i}q;d")

		echo "\t\$$M\$ & $L & $I" '\\\\'
		if (( $i % $base == 0 )); then
			echo "\\hline"
		fi
	done
}

# This function generates a fully-formatted LaTeX tabular object.
#
# NOTE: This function does not check whether the passed arguments fall within
# their allowed ranges.
#
# args: mode base
# mode: 'log' or 'antilog'
# base: positive integer strictly greater than 1
function generate_latex_table
{
	mode=$1
	base=$2

	echo '\\begin{tabular}'
	get_table_spec $base
	echo '\\hline'
	echo "\\multicolumn{$((2 * $base))}{|c|}{Base $base Logarithms}" '\\\\'
	echo '\\hline'
	echo "~ & $(generate digits $base) & $(generate digits $base | cut -d' ' -f3-)" '\\\\'
	echo "\\hline"
	get_tabular_body $mode $base
	echo '\\end{tabular}'
}

# This function generates a complete LaTeX document which can be compiled.
#
# NOTE: This function does not check whether the given arguments fall within
# their allowed ranges.
#
# args: mode base
# mode: 'log' or 'antilog'
# base: integer strictly greater than 1
function generate_latex_document
{
	mode=$1
	base=$2

	cat <<EOF
\\documentclass[border=1pt]{standalone}
\\usepackage{multirow}
\\everymath{\\mathtt{\\xdef\\tmp{\\fam\\the\\fam\\relax}\\aftergroup\\tmp}}
\\begin{document}

$(generate_latex_table $mode $base)

\end{document}
EOF
}

#generate_latex_document $1
