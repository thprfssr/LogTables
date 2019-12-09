#!/bin/zsh

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
	elif [[ "$mode" == "antilogarithms" ]]; then
		func=get_antilog
		n=4
	elif [[ "$mode" == "log_interpolations" ]]; then
		func=get_log_interpolation
		n=1
	elif [[ "$mode" == "antilog_interpolations" ]]; then
		func=get_antilog_interpolations
		n=1
	elif [[ "$mode" == "digits" ]]; then
		func=get_main_row
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
	str=$(echo $str | tr -d "\n" | sed -f $sanitize)

	if [[ "$mode" == "log_interpolations" ]]; then
		str=$(echo $str | sed "s/\$0\$ \& //1")
	fi

	echo $str
}

# args: base
function print_main_column
{
	base=$1
	python <<EOF
from $(basename $logarithms_script .py) import *
print_main_column($base)
EOF
}

# Merge the log table and interpolation tables into one
# args: base
function generate_latex_table
{
	base=$1
	logarithms=$(generate logarithms $base)
	interpolations=$(generate log_interpolations $base)
	main=$(print_main_column $base)
	n=$(echo $logarithms | wc -l)
	echo '\\begin{tabular}'
	printf '{| c | '
	printf 'c %.0s' {1..$base}
	printf '|| '
	printf 'c %.0s' {2..$base}
	printf "|}\n"
	echo '\\hline'
	echo "\\multicolumn{$((2 * $base))}{|c|}{Base $base Logarithms}" '\\\\'
	echo '\\hline'
	echo "~ & $(generate digits $base) & $(generate digits $base | cut -d' ' -f3-)" '\\\\'
	echo "\\hline"
	for i in {1..$n}; do
		# get the i-th lines
		L=$(echo $logarithms | sed "${i}q;d")
		I=$(echo $interpolations | sed "${i}q;d")
		M=$(echo $main | sed "${i}q;d")
		echo '\t'\$$M\$ \& $L \& $I '\\\\'
		if (( $i % $base == 0 )); then
			echo '\\hline'
		fi
	done
	echo '\\end{tabular}'
}

# args: base
function generate_latex_document
{
	base=$1
	cat <<EOF
\\documentclass[border=1pt]{standalone}
\\usepackage{multirow}
\\everymath{\\mathtt{\\xdef\\tmp{\\fam\\the\\fam\\relax}\\aftergroup\\tmp}}
\\begin{document}

$(generate_latex_table $base)

\end{document}
EOF
}

generate_latex_document $1
