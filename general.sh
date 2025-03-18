#!/bin/bash
# -----------------------------------------------------------------
# An Azure Armory
# General Functions
# -----------------------------------------------------------------
# error_message
# error_report
# nap
# pause
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# The error_message() subroutine standardizes the error message
#   readout while providing an easy way to notify the user of an
#   error before exiting.
# 
# Usage: error_message "#" "message";
# -----------------------------------------------------------------
error_message() {
	local error_num="$1";
	shift
	local error_string="$*";

  # shellcheck disable=SC2154
	echo -e "${color_bad}Error ${error_num}${color_reset}: ${error_string}";
	usage;
	exit "$(echo "$error_num" | cut -d. -f1)"
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# The error_report() subroutine provides a stack trace type readout 
#   ennumerating the steps and functions involved in the error
#   along with line numbers to make trouble shooting easier.
# 
# Usage: error_report;
# -----------------------------------------------------------------
error_report() {
    echo -e "Error in script: ${BASH_SOURCE[0]}"
    echo -e "Error on line: ${BASH_LINENO[0]} in function ${FUNCNAME[1]}()"
#   echo -e "This is line: ${color_red}${LINENO}${color_reset} in: ${color_green}${FUNCNAME[0]}()${color_reset}";
    echo -e "Stack Trace:"
    for i in ${!BASH_LINENO[*]}; do
     if [[ "$i" == "0" ]]; then
       false;
     elif [[ "${BASH_LINENO[i]}" == "0" ]]; then
       false;
     else
       echo -e "  ${FUNCNAME[i]}() was called from line: ${BASH_LINENO[i]}";
     fi
    done
    echo "";
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# The nap() subroutine is a litle pause of X seconds, but unlike
#   sleep, this has a countdown.
# 
# Usage: nap "10"
# -----------------------------------------------------------------
nap() {
  local delay="1"
  local i=0;

  if [[ -n "$1" ]]; then
    delay="$1"
  fi

  # Echo this message first
  echo "Pausing to allow time to stop the script.";
  echo "(press ctrl-c to stop)";

  for ((i=delay; i>0; i=$((i - 1)) )); do
      echo -n "$i... "
      sleep 1
  done
  echo "";

  # echo a blank line after the countdown
  echo "";
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# The pause() subroutine waits for any input from the user before
#   proceeding with an optional timeout.
# 
# Usage: pause ["30"]
# -----------------------------------------------------------------
pause() {
	local timeout="";
	if [[ -n "$1" ]]; then
		timeout="-t $1";
	fi
	# shellcheck disable=SC2086
	# shellcheck disable=SC2034
	# shellcheck disable=SC2229
    read -n 1 ${timeout} -r -s -p "(press any key to continue)" "discard";
    echo "";
    return;

}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# Enhanced pause with optional timeout and optional prompt text.
# If a timeout is requested, a countdown timer runs next to the
# optional prompt. Order of parameters doesn't matter.
# 
# usage: pause2 ["30"] ["Press any key to continue..."]
# -----------------------------------------------------------------
pause2() {
  local clear_count=""
  local length=0
  local storage=""
  local d=0
  local delay="0"
  local prompt=""
  local default_prompt="Press any key to continue... "

  for ((i=1; i-1<$#; i++)) do
    case "${*:i:1}" in
      [0-9][0-9][0-9][0-9]|[0-9][0-9][0-9]|[0-9][0-9]|[0-9]) delay="${*:i:1}"; ;;
      *) prompt+="${*:i:1} "; ;;
    esac
  done

  if [[ -z "${prompt}" ]]; then prompt="${default_prompt}"; fi
  echo -en "${prompt}"

  if (( delay > 0 )); then
    for ((d=delay; d>0; d=$(( d - 1 )) )) do
      echo -en "${d}... "
      read -p "" -rs -n 1 -t 1 "storage"

      length=$(( ${#d} + 4 ))
      clear_count=""
      for ((l=0; l<length; l++)) do
        clear_count+="\b"
      done
      echo -en "${clear_count}      \b\b\b\b\b\b\b\b"

      case "${storage}" in
        "") ;;
        *) break; ;;
      esac
    done
  else
    read -rsn 1
  fi
  echo -e ""
}
# -----------------------------------------------------------------
