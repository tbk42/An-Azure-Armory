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
# Usage: X ["30"]
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
