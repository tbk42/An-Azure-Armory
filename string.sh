#!/bin/bash
# -----------------------------------------------------------------
# An Azure Armory
# String Functions
# -----------------------------------------------------------------
# ltrim
# repeat
# rtrim
# space
# substring
# trim
# -----------------------------------------------------------------

function center() {
	local a=0
	local i=0
	local value=""
	local -a value_array=()
	local max_len=0
	for ((i=1; i<=$#; i++)) do
		value="${*:i:1}"
		value_array+=("${value}")
		if (( ${#value} > max_len )); then
			max_len=${#value}
		fi
	done
	local space=" "
	local spaces=""
	local extra_space=""
	for ((a=0; a<${#value_array[*]}; a++)) do
		spaces=""
		extra_space=""
		this_len=${#value_array[a]}
		space_count=$(( (max_len - this_len) / 2 ))
		for ((i=0; i<space_count; i++)) do
			spaces+="${space}"
		done
		if (( ${#spaces} + ${#value_array[a]} + ${#spaces} < ${max_len} )); then
			extra_space="${space}"
		fi
		value_array[a]="${spaces}${value_array[a]}${spaces}${extra_space}"
	done
	for ((i=0; i<${#value_array[*]}; i++)) do
		echo -e "${value_array[i]}"
	done
	return
}

function lpad() {
	local i=0
	local value=""
	local -a value_array=()
	local max_len=0
	for ((i=1; i<=$#; i++)) do
		value_array+=("${*:i:1}")
		if (( ${# } > max_len )); then
			max_len=${#value}
		fi
	done
	local space=""
	local extra_space=""
	for ((i=0; i<${#value_array[*]}; i++)) do
		space="$(repeat "$(( max_len - ${#value_array[i]} ))" " ")"
		if (( ${#space} + ${#value_array[i]} < ${max_len} )); then
			space+=" "
		fi
		value_array[i]="${space}${value_array[i]}"
	done
	echo -n "\"${value[*]}\""
	return
}

# -----------------------------------------------------------------
# LTRIM returns a string with the leading spaces removed.
# Usage: var=$(ltrim "string")
# -----------------------------------------------------------------
function ltrim() {
    # remove leading whitespace characters
    echo "${*#"${*%%[![:space:]]*}"}";
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# REPEAT ... repreats, the pattern count number of times.
# usage: varname=$(repeat "40" "_|\_/|_");
# -----------------------------------------------------------------
function repeat() {
	local count=0
	count="${1-"1"}"
	if (( count == 0 )); then count="1"; fi
	if (( count < 0 )); then count=$((count*-1)); fi

    local pattern="${2-" "}";
    local filled="";
	local i=0
    for ((i=0; i<count; i++)) do
        filled+="${pattern}";
    done
    echo -n "${filled}"
}
# -----------------------------------------------------------------

function rpad() {
	local i=0
	local value=""
	local -a value_array=()
	local max_len=0
	for ((i=1; i<=$#; i++)) do
		value_array+=("${*:i:1}")
		if (( ${# } > max_len )); then
			max_len=${#value}
		fi
	done
	local space=""
	local extra_space=""
	for ((i=0; i<${#value_array[*]}; i++)) do
		space="$(repeat "$(( max_len - ${#value_array[i]} ))" " ")"
		if (( ${#space} + ${#value_array[i]} < ${max_len} )); then
			space+=" "
		fi
		value_array[i]="${value_array[i]}${space}"
	done
	echo -n "\"${value[*]}\""
	return
}

# -----------------------------------------------------------------
# RTRIM returns a string with the trailing spaces removed.
# Usage: var=$(ltrim "string")
# -----------------------------------------------------------------
function rtrim() {
    # remove trailing whitespace characters
    echo -n "${*%"${*##*[![:space:]]}"}";
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# SPACE returns X spaces.
# Usage: var=$(space 5)
# -----------------------------------------------------------------
function space() {
	local length=0
	length="${1-"1"}"
	if (( length == 0 )); then length="1"; fi
	if (( length < 0 )); then length=$((length*-1)); fi
	# shellcheck disable=SC2005
	echo -n "$(repeat "$length" " ")"
	return
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# SUBSTRING splits strings using internal bash functions rather
#   than relying on external programs like sed, awk, or grep.
# Usage: substring "search" "string" "return array name"
#   this is a subroutine that fills a global array called substring
#   with 4 strings. Caution must be used when calling the subroutine
#   a second time as it will overwrite the first result.
#   0 = the index of search in string.
#   1 = the portion of string to the left of search.
#   2 = the "middle" of string, which is equal to search.
#   3 = the remainder of the string to the right of search.
# -----------------------------------------------------------------
substring() {
	local search="";
	local string="";
	local array_name=""

	search="$1";
	string="$2";
	array_name="$3"

	if [[ -z "$search" ]]; then
		echo -e "Error: \"Search\" was not sent."
		return
	elif [[ -z "$string" ]]; then
		echo -e "Error: \"String\" was not sent."
		return
	fi
	if [[ -z "$array_name" ]]; then
		array_name="substring"
	fi

	local index=0;
	local left="";
	local middle="";
	local right="";

	left="${string%%"$search"*}";
	index=$((${#left}))
	if (( index < ${#string} )); then
		middle=${string:$index:${#search}}
		right=${string:$index+${#search}}
	else
		index=-1
		left=""
		middle=""
		right="${string}"
	fi

	declare -ag "${array_name}"="(\"${index}\" \"${left}\" \"${middle}\" \"${right}\")"
	return 0
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# TRIM returns a string with both leading and trailing spaces
# removed. Uses LTRIM and RTRIM to do this.
# Usage: var=$(trim "string")
# -----------------------------------------------------------------
function trim() {
    rtrim "$(ltrim "$*")";
}
# -----------------------------------------------------------------
