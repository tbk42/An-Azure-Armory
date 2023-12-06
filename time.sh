#!/bin/bash
# -----------------------------------------------------------------
# An Azure Armory
# Time Functions
# -----------------------------------------------------------------
# elapsed
# month2num
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# The elapsed() subroutine uses the start_timestamp global variable
#	& the last_timestamp global variable. It also generates an
#	end_timestamp local variable. It then calculates the time since
#	the start & last timestamps as since & total. It then echos out
#	a colored readout and finally updates the last_timestamp global
#	variable for use in a future readout.
# 
# Usage: elapsed;
# -----------------------------------------------------------------
elapsed() {
    if [[ -z "$start_timestamp" ]]; then
        start_timestamp=$(date +%s);
    fi
    if [[ -z "$last_timestamp" ]]; then
        last_timestamp=$(date +%s);
    fi
    local end_timestamp="";
    end_timestamp=$(date +%s);
    local since="";
    since=$(date --utc --date=@$(( end_timestamp - last_timestamp )) +%H:%M:%S);
    local total="";
    total=$(date --utc --date=@$(( end_timestamp - start_timestamp )) +%H:%M:%S);
    echo -en "$(color gray bg)$(color black)[$since | $total]$(color reset)  ";
    last_timestamp="$end_timestamp";
    return;
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# The month2num() function converts months by name to their number.
#	It handles both full length names such as "November" as well as
#	three letter code abbriviations like "Nov". It also handles
#	both upper and lower (and mixed) cases. It can output the month
#	number with an optional prepended zero as appropriate such as
#	"05" for months earlier than October.
# 
# Usage: month_num=$(month2num "$month_string" "--prepend_zero")
# -----------------------------------------------------------------
function month2num() {
  local month_input="";
  local month=0;
  local leading="";

  if [[ -n "$1" ]]; then
    month_input=$(echo "$1" | cut -b1-3 | tr "[:upper:]" "[:lower:]");

    case $month_input in
      "jan") month="1"; ;;
      "feb") month="2"; ;;
      "mar") month="3"; ;;
      "apr") month="4"; ;;
      "may") month="5"; ;;
      "jun") month="6"; ;;
      "jul") month="7"; ;;
      "aug") month="8"; ;;
      "sep") month="9"; ;;
      "oct") month="10"; ;;
      "nov") month="11"; ;;
      "dec") month="12"; ;;
    esac
  fi

  if [[ -n "$2" ]]; then
    if [[ "$2" == "--prepend_zero" ]]; then
      leading="0";
    fi
  fi

  if [[ $(( month < 10 )) == "1" ]]; then
    month="$leading""$month";
  fi

  if [[ "$__resultvar" ]]; then
      eval "$__resultvar"="'$month'";
  else
      echo "$month";
  fi
}
# -----------------------------------------------------------------
