#!/bin/sh
#
# Generate the x86_cap_flags[] array from include/asm/cpufeature.h
#

IN=$1
OUT=$2

(
	echo "#include <asm/cpufeature.h>"
	echo ""
	echo "const char * const x86_cap_flags[NCAPINTS*32] = {"

	# Iterate through any input lines starting with #define X86_FEATURE_
	sed -n -e 's/\t/ /g' -e 's/^ *# *define *X86_FEATURE_//p' $IN |
	while read i
	do
		# Name is everything up to the first whitespace
		NAME="$(echo "$i" | sed 's/ .*//')"

		# If the /* comment */ starts with a quote string, grab that.
		VALUE="$(echo "$i" | sed -n 's@.*/\* *\("[^"]*"\).*\*/@\1@p')"
		[ -z "$VALUE" ] && VALUE="\"$(echo "$NAME" | tr A-Z a-z)\""

		[ "$VALUE" != '""' ] && echo "	[X86_FEATURE_$NAME] = $VALUE,"
	done
	echo "};"
) > $OUT
