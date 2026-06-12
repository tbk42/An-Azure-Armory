#!/bin/bash
# -----------------------------------------------------------------
# An Azure Armory
# Math Functions
# -----------------------------------------------------------------
# floating_point_division
# human_number
# isnumeric
# -----------------------------------------------------------------

# ---------------------------------------------------------------------------------
# FLOATING_POINT_DIVISION returns a floating point "number" in a string with the
#	result of diving the numerator by the denominator & rounding any result to
#	the specified number of $precision decimal places.
# 
#	Usage: string=$(floating_point_division "numerator" "denominator" "precision")
# ---------------------------------------------------------------------------------
function floating_point_division() {
	# Input variables
	local numerator=1;
	local denominator=1;
	local precision=2;

	# Internal variables
	local error="";
	local intermediate=0;
	local quotient=0;
	local quotient_integer_part=0;
	local quotient_decimal_part=0;
	local rounding_factor=0;

	# Check that input is provided.
	if [[ -z "${1}" ]]; then error="Numerator was not supplied."; fi
	if [[ -z "${2}" ]]; then error="Denominator was not supplied."; fi
	if (( ${2} == 0 )); then error="Denominator cannot be zero."; fi

	# Provide feedback on input errors.
	if [[ -n "$error" ]]; then
		printf "%s\n" "$error"
		return
	fi

	numerator="$(($1*1))";
	denominator="$(($2*1))";
	if [[ -n "${3}" ]]; then precision="$(($3*1))"; fi


	# Perform division
	numerator=$((numerator * ( 10**(precision + 1) ) ));
	intermediate=$(( numerator / denominator ));

	# Split result — pad with leading zeros when intermediate has fewer
	# digits than precision + 1 (result < 1)
	intermediate_padded="$(printf "%0$((precision + 1))d" "$intermediate")"
	int_digits=$(( ${#intermediate} - (precision + 1) ))
	if (( int_digits <= 0 )); then
		quotient_integer_part="0"
		quotient_decimal_part="${intermediate_padded:0:precision}"
	else
		quotient_integer_part="${intermediate_padded:0:int_digits}"
		quotient_decimal_part="${intermediate_padded:int_digits:precision}"
	fi
	rounding_factor="${intermediate_padded: -1:1}"

	# Strip leading zeros from decimal part (keep at least precision digits)
	while (( ${#quotient_decimal_part} > precision )) && [[ "${quotient_decimal_part:0:1}" == "0" ]]; do
		quotient_decimal_part="${quotient_decimal_part:1}"
	done

	# Perform rounding
	if (( 10#${rounding_factor:-0} >= 5 )); then
		quotient_decimal_part=$(( 10#${quotient_decimal_part:-0} + 1 ));
		if (( quotient_decimal_part >= 10**precision )); then
			quotient_decimal_part=$(( quotient_decimal_part - 10**precision ))
			quotient_integer_part=$(( quotient_integer_part + 1 ))
		fi
	fi

	# Attach decimal part
	quotient="${quotient_integer_part}"
	if [[ -n "${quotient_decimal_part}" ]]; then
		quotient+=".${quotient_decimal_part}";
	fi
	if [[ -z "$quotient" ]]; then
		quotient="0";
	fi

	# Return quotient
	printf "%s\n" "$quotient"
	return;
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# HUMAN_NUMBER returns a human-readable string version of the
#	provided large integer, rounded to the nearest magnitude. It
#	returns the appropriate short abbreviation, B for Bytes, K for
#	Kilobytes, M for Megabytes, G for Gigabytes, or T for Terabytes.
# 
# Usage: string=$(human_number "large_integer")
# -----------------------------------------------------------------
function human_number() {
	local long_number=0;
	local error="";
	[[ -n "$1" ]] && long_number="$1" || error="No value was passed to the function";
	[[ -n "$error" ]] && printf "%s\n" "$error" && return

	local sizes=();
	sizes+=("0" "B"     "Bytes");
	sizes+=("1" "B"     "Bytes");
	sizes+=("2" "K" "Kilobytes");
	sizes+=("3" "M" "Megabytes");
	sizes+=("4" "G" "Gigabytes");
	sizes+=("5" "T" "Terabytes");

	local base=1024;
	local s=0;
	local steps="3";
	local precision="2";
	local short_number="0B";
	local magnitude=0;

	# Even if a larger precision is requested, round Bytes to integers,
	# and Kilobytes to 1 decimal place.
	for ((s=0; s<${#sizes[*]}; s=$((s+steps)))) do
		magnitude="${sizes[s]}";
		if (( magnitude == 0 )); then
			if (( long_number >= base * magnitude )) && (( long_number < base**magnitude )); then
				precision=0;
				break;
			fi
		elif (( magnitude == 1 )); then
			if (( long_number >= 1 )) && (( long_number < 1024 )); then
				precision=0;
				break;
			fi
		elif (( magnitude == 2 )); then
			if (( long_number >= 1024 )) && (( long_number < 1048576 )); then
				precision=1;
				break;
			fi
		else
			if (( long_number >= base**(magnitude - 1) )) && (( long_number < base**magnitude )); then
				break;
			fi
		fi
	done

	# Catch magnitude zero, and use a slightly different formula as
	# bash does not handle imaginary numbers. (i = sq root of -1)
	if (( magnitude == 0 )); then
		short_number=$(floating_point_division "$long_number" "$(( base**(magnitude) ))" "$precision")
	else
		short_number=$(floating_point_division "$long_number" "$(( base**(magnitude - 1) ))" "$precision")
	fi

	# look up the appropriate abbreviation
	magnitude_abbriviation="${sizes[s+1]}"

	# return the rounded floating point (or integer) and the
#	abbreviated magnitude.
	printf "%s\n" "${short_number}${magnitude_abbriviation}"
	return;
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# The isnumeric() function returns either true or false. This
#	function runs the value through a small series of tests. First
#	ensuring the value is a number, then optionally testing vs a
#	minimum and maximum value. You must test for a minimum in order
#	to test for a maximum.
# 
# Usage: test=$(isnumeric "$value" ["-7" "14"]);
# -----------------------------------------------------------------
function isnumeric() {
	local answer=true;
	local value="";
	local min="";
	local max="";
	local i=0;

	[[ -n "$1" ]] && value="$1";
	[[ -n "$2" ]] && min="$2";
	[[ -n "$3" ]] && max="$3";

	[[ -z "$value" ]] && answer=false;

	if [[ "$answer" == "true" ]]; then
		# Loop through the string, character by character
		for ((i=0; i<${#value}; i++)) do
			case "${value:i:1}" in
				+|-) # Sign is only valid as the very first character
					 if (( i > 0 )); then answer=false; fi
					 ;;
				0|1|2|3|4|5|6|7|8|9) true; ;;
				*) answer=false; ;;
			esac
		done
	fi

	if [[ "$answer" == "true" ]]; then
		# Only perform numeric comparisons if the string is confirmed to be a valid number format
		[[ -n "$min" && $((value < min)) ]] && answer=false;
		[[ -n "$max" && $((value > max)) ]] && answer=false;
	fi

    local result_var_name="$4"
    if [[ -n "${result_var_name}" ]]; then
        printf -v "${result_var_name}" '%s' "${answer}"
    else
        printf "%s\n" "$answer"
    fi
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# ROUND returns the input number rounded to the specified decimal
#   precision using floating_point_division with a denominator of 1.
# 
# Usage: result=$(round "number" "precision")
# -----------------------------------------------------------------
function round() {
	local input=0
	local precision=2
	local error=""

	if [[ -n "${1}" ]]; then
		input="$((${1}*1))"
	else
		error="No value was passed to the function"
	fi
	if [[ -n "${2}" ]]; then
		precision="$((${2}*1))"
	fi
	if [[ -n "${error}" ]]; then
		printf "%s\n" "$error"
		return;
	fi
	floating_point_division "${input}" "1" "${precision}"
	return
}
# -----------------------------------------------------------------
