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

function bubble_sort() {
    local l=0
    local list=()
    readarray -t "list" < <(printf "%s\n" "${@}")
    if (( ${#list[*]} == 0 )); then
        printf "%s\n" ""
        return
    fi

    local flip_flag="true"
    local temp=""

    while [[ "${flip_flag}" == "true" ]]; do
        flip_flag="false"
        for ((l=0; l<${#list[*]}-1; l++)) do
            if [[ "${list[l]}" > "${list[l+1]}" ]]; then
                temp="${list[l]}"
                list[l]=${list[l+1]}
                list[l+1]=${temp}
                flip_flag="true"
            fi
        done
    done
    printf "%s\n" "${list[@]}"
    return
}

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
		printf "%b\n" "${value_array[i]}"
	done
	return
}

function get_index_of() {
	local output=()
	local case=""; case="false"; # default setting for case sensitivity
	local index=""; index="multi"; # default setting for index return
	for ((i=1; i<=$#; i++)) do
		case "${!i,,}" in
			"--case-sensitive") case="true" ;;
			"--case-insensitive") case="false" ;;
			"--first-index") index="first" ;;
			"--last-index") index="last" ;;
			"--multi-index") index="multi" ;;
		esac
	done

	local value=""; value="${1}"; shift
	local list=()
	local item=""
	for item in "$@"; do
		list+=("${item}")
	done

	for ((i=0; i<${#list[*]}; i++)) do
		if [[ "${case}" == "true" ]]; then
			if [[ "${value}" == "${item}" ]]; then
				output+=("${i}")
			fi
		else
			if [[ "${value,,}" == "${item,,}" ]]; then
				output+=("${i}")
			fi
		fi
	done

	case "${index}" in
		"first") printf "%s\n" "${output[0]}" ;;
		"last") printf "%s\n" "${output[${#output[*]}]}" ;;
		"multi") printf "%s\n" "${output[@]}" ;;
	esac
}

function lpad() {
	local i=0
	local -a value_array=()
	local max_len=0
	local arg=""
	for ((i=1; i<=$#; i++)) do
		arg="${*:i:1}"
		value_array+=("$arg")
		if (( ${#arg} > max_len )); then
			max_len=${#arg}
		fi
	done
	local space=""
	for ((i=0; i<${#value_array[*]}; i++)) do
		space="$(repeat "$(( max_len - ${#value_array[i]} ))" " ")"
		if (( ${#space} + ${#value_array[i]} < max_len )); then
			space+=" "
		fi
		value_array[i]="${space}${value_array[i]}"
	done
	printf "%s" "\"${value_array[*]}\""
}

# -----------------------------------------------------------------
# LTRIM returns a string with the leading spaces removed.
# Usage: var=$(ltrim "string")
# -----------------------------------------------------------------
function ltrim() {
    # remove leading whitespace characters
    printf "%s\n" "${*#"${*%%[![:space:]]*}"}";
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# REPEAT ... repreats, the pattern count number of times.
# usage: varname=$(repeat "40" "_|\_/|_");
# -----------------------------------------------------------------
function repeat() {
	local count=0
	count="${1-"1"}"
	if (( count == 0 )); then count=0; fi
	if (( count < 0 )); then count=$((count*-1)); fi

    local pattern="${2-" "}";
    local filled="";
	local i=0
    for ((i=0; i<count; i++)) do
        filled+="${pattern}";
    done
    printf "%s" "${filled}"
}
# -----------------------------------------------------------------

function rpad() {
	local i=0
	local -a value_array=()
	local max_len=0
	local arg=""
	for ((i=1; i<=$#; i++)) do
		arg="${*:i:1}"
		value_array+=("$arg")
		if (( ${#arg} > max_len )); then
			max_len=${#arg}
		fi
	done
	local space=""
	for ((i=0; i<${#value_array[*]}; i++)) do
		space="$(repeat "$(( max_len - ${#value_array[i]} ))" " ")"
		if (( ${#space} + ${#value_array[i]} < max_len )); then
			space+=" "
		fi
		value_array[i]="${value_array[i]}${space}"
	done
	printf "%s" "\"${value_array[*]}\""
}

# -----------------------------------------------------------------
# RTRIM returns a string with the trailing spaces removed.
# Usage: var=$(ltrim "string")
# -----------------------------------------------------------------
function rtrim() {
    # remove trailing whitespace characters
    printf "%s" "${*%"${*##*[![:space:]]}"}";
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
	printf "%s" "$(repeat "$length" " ")"
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
		printf "%b\n" "Error: \"Search\" was not sent."
		return
	elif [[ -z "$string" ]]; then
		printf "%b\n" "Error: \"String\" was not sent."
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
