#!/bin/bash
# -----------------------------------------------------------------
# An Azure Armory
# String Functions
# -----------------------------------------------------------------
# bubble_sort
# center
# get_index_of
# lpad
# ltrim
# rpad
# repeat
# rtrim
# space
# substring
# trim
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# BUBBLE_SORT sorts the given list of strings alphabetically using
#   the bubble sort algorithm.
# 
# Usage: sorted=$(bubble_sort "item1" "item2" ...)
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

# -----------------------------------------------------------------
# CENTER pads each argument with leading and trailing spaces so
#   that every output string has the same visual width (the max
#   length of all arguments).
# 
# Usage: center "str1" "str2" ...
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
		printf "%s\n" "${value_array[i]}"
	done
	return
}

# -----------------------------------------------------------------
# GET_INDEX_OF returns the index(es) of a value within a list.
#   Supports case-sensitive/insensitive and first/last/multi modes.
# 
# Usage: get_index_of [--case-sensitive|--case-insensitive]
#                     [--first-index|--last-index|--multi-index]
#                     <search_value> <list_items...>
# -----------------------------------------------------------------
function get_index_of() {
	local output=()
	local case=""; case="false"; # default setting for case sensitivity
	local index=""; index="multi"; # default setting for index return
	local value=""
	local list=()
	local item=""

	while [[ $# -gt 0 ]]; do
		case "${1,,}" in
			"--case-sensitive") case="true"; shift ;;
			"--case-insensitive") case="false"; shift ;;
			"--first-index") index="first"; shift ;;
			"--last-index") index="last"; shift ;;
			"--multi-index") index="multi"; shift ;;
			*) break ;;
		esac
	done

	value="${1}"; shift
	for item in "$@"; do
		list+=("${item}")
	done

	for ((i=0; i<${#list[*]}; i++)) do
		if [[ "${case}" == "true" ]]; then
			if [[ "${value}" == "${list[i]}" ]]; then
				output+=("${i}")
			fi
		else
			if [[ "${value,,}" == "${list[i],,}" ]]; then
				output+=("${i}")
			fi
		fi
	done

	case "${index}" in
		"first") printf "%s\n" "${output[0]}" ;;
		"last") printf "%s\n" "${output[$(( ${#output[*]} - 1 ))]}" ;;
		"multi") printf "%s\n" "${output[@]}" ;;
	esac
}

# -----------------------------------------------------------------
# LPAD left-pads each argument with spaces so all outputs share
#   the same length (the max length of all arguments).
# 
# Usage: lpad "str1" "str2" ...
# -----------------------------------------------------------------
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
	printf "%s\n" "${value_array[*]}"
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
# LINE returns a dash line (or custom pattern) that fills the
#   terminal width, with an optional leader offset.
#
# Usage: line=$(line ["-"] ["80"] ["10"])
#   $1: character (default: "-")
#   $2: width (default: terminal width)
#   $3: leader width offset (subtracted from width)
# -----------------------------------------------------------------
function line() {
    local line_character=""
    line_character="${1:--}"

    local line_width="${2:-0}"
    local cols="0"
    cols="$(tput cols 2>/dev/null || printf "80")"
    if (( line_width > cols )) || (( line_width == 0 )); then
        line_width="${cols}"
    fi

    local leader_width="${3:-0}"
    line_width="$(( line_width - leader_width ))"
    if (( line_width < 0 )); then
        line_width="0"
    fi

    local line=""
    line="$(repeat "${line_width}" "${line_character}")"
    printf "%s\n" "${line}"
}

# -----------------------------------------------------------------
# REPEAT ... repeats the pattern count number of times.
# usage: varname=$(repeat "40" "_|\_/|_");
# -----------------------------------------------------------------
function repeat() {
	local count=0
	count="${1-"1"}"
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

# -----------------------------------------------------------------
# RPAD right-pads each argument with spaces so all outputs share
#   the same length (the max length of all arguments).
# 
# Usage: rpad "str1" "str2" ...
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
	printf "%s\n" "${value_array[*]}"
}

# -----------------------------------------------------------------
# RTRIM returns a string with the trailing spaces removed.
# Usage: var=$(rtrim "string")
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
