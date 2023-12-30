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
    local count=0;
    local pattern="";
    local filled="";

    if [[ -n "$1" ]]; then
    	  count="$1";
    	  if [[ -n "$2" ]]; then
    	  	  pattern="$2";
    	  else
    	      pattern=" ";
    	  fi
    else
    	  count="10";
    	  pattern=" ";
    fi

    for ((i=0; i<count; i++)) do
        filled+="$pattern";
    done
    echo "$filled"
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# RTRIM returns a string with the trailing spaces removed.
# Usage: var=$(ltrim "string")
# -----------------------------------------------------------------
function rtrim() {
    # remove trailing whitespace characters
    echo "${*%"${*##*[![:space:]]}"}";
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# SPACE returns X spaces.
# Usage: var=$(space 5)
# -----------------------------------------------------------------
function space() {
	local spaces="";
	local length=0;
	local i=0;
	if [[ -n "$1" ]]; then
		length="$1";
	fi
	for ((i=0; i<length; i++)) do
		spaces+=" ";
	done
	echo "$spaces";
	return;
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# SUBSTRING splits strings using internal bash functions rather
#   than relying on external programs like sed, awk, or grep.
# Usage: substring "search" "string"
#   this is a subroutine that fills a global array called substring
#   with 4 strings. Caution must be used when calling the subroutine
#   a second time as it will overwrite the first result.
#   0 = the index of search in string.
#   1 = the portion of string to the left of search.
#   2 = the "middle" of string, which is equal to search.
#   3 = the remainder of the string to the right of search.
# -----------------------------------------------------------------
substring=();
substring() {
	local search="";
	local string="";
	if [[ -n "$1" ]]; then
		search="$1";
		if [[ -n "$2" ]]; then
			string="$2";
		else
			substring=("0" "Error: " "\"String\"" "was not sent.");
			return;
		fi
	else
		substring=("0" "Error: " "\"Search\"" "was not sent.");
		return;
	fi

	local index=0;
	local left="";
	local middle="";
	local right="";

	left="${string%%"$search"*}";
	index=$((${#left}))
	right=${string:$index+${#search}}
	middle=${string:$index:${#search}}

	substring=("$index" "$left" "$middle" "$right");
	return
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
