# Convert the string "][" into newlines, since all the newlines have been
# previously eradicated.
s/\]\[/\n/g

# Delete undesired characters
s/'//g
s/\[//g
s/\]//g

# Normalize the spaces
s/ +/ /g

# Produce a LaTeX table
s/ /\$ \& \$/g
s/^/\$/g
s/\n/\$\n\$/g
s/$/\$/g
