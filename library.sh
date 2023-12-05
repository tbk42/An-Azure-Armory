#!/bin/bash
# Repository for my function Library

# -----------------------------------------------------------------
# An Azure Armory
# -----------------------------------------------------------------
# build_cert_line
# elapsed
# error_message
# error_report
# file_check
# floating_point_division
# guess_digest_type
# hex2rgb
# human_number
# isnumeric
# ltrim
# month2num
# nap
# pause
# read_x509
# remove_from_array
# repeat
# rgb2hex
# rtrim
# space
# substring
# trim
# -----------------------------------------------------------------

# -----------------------------------------------------------------------------
# The build_cert_line() function generates a colorful readout making 
# certificate expiration date and status easy to identify. Pass the full path 
# and filename of the certificate to the function.
# 
# Useage: one_line=$(build_cert_line "$new_cert")
# -----------------------------------------------------------------------------
function build_cert_line() {
  if ! [ -z "$1" ]; then
    local secinday=86400;
    local one_cert="$1";

    local cert_info=$(read_x509 "$one_cert");

    local cert_name=`echo "$cert_info" | cut -d, -f1`;
    local cert_end=`echo "$cert_info" | cut -d, -f2`;
    local cert_will_expire=`echo "$cert_info" | cut -d, -f3`;
    local cert_ext_domains=`echo "$cert_info" | cut -d, -f4`;

    local cert_end_stripped=`echo "$cert_end" | cut -c5,8 --complement`;
    local cert_end_as_sec=`date +%s -d "$cert_end_stripped"`;

    local today=`date +%Y-%m-%d`;
    local today_stripped=`echo "$today" | cut -c5,8 --complement`;
    local today_as_sec=`date +%s -d "$today_stripped"`;

    local difference_as_days=$(( ($cert_end_as_sec - $today_as_sec) / $secinday ));

    local icon="$warning";
    local foreground_color="$bold_white";
    local background_color="$back_dkgray";
    local pri_color="$white";

    if [ $(( $difference_as_days > 6 )) == 1 ]; then
      icon="$good";
      foreground_color="$green";
      background_color="$back_green";
      pri_color="$white";
    elif [ $(( $difference_as_days > 0 )) == 1 ]; then
      icon="$warning";
      foreground_color="$yellow";
      background_color="$back_yellow";
      pri_color="$bold_black";
    else
      icon="$bad";
      foreground_color="$red";
      background_color="$back_red";
      pri_color="$white";
    fi

    local build="";
    build+="$foreground_color""$outter_left_end""$reset";
    build+="$background_color""$pri_color""$bold"" ""$icon"" ""$reset";
    build+="$foreground_color""$back_dkgray""$inner_right_end""$reset";

    build+="$back_dkgray""$white""  ""$cert_name""   ""$reset";

    build+="$foreground_color""$back_dkgray""$inner_left_end""$reset";
    build+="$background_color""$pri_color"" ""$cert_end"" ""$reset";
    build+="$foreground_color""$outter_right_end""$reset";
  fi

  if [[ "$__resultvar" ]]; then
      eval $__resultvar="'$build'";
  else
      echo "$build";
  fi
}

# --- Elapsed ------------------------------------------------------------------
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
# ------------------------------------------------------------------------------

error_message() {
	local error_num="$1";
	shift
	local error_string="$*";

	echo -e "${color_bad}Error ${error_num}${color_reset}: ${error_string}";
	usage;
	exit "$(echo "$error_num" | cut -d. -f1)"
}

error_report() {
    echo -e "Error in script: ${BASH_SOURCE}"
    echo -e "Error on line: ${BASH_LINENO[0]} in function ${FUNCNAME[1]}()"
#   echo -e "This is line: ${color_red}${LINENO}${color_reset} in: ${color_green}${FUNCNAME[0]}()${color_reset}";
    echo -e "Stack Trace:"
    for i in ${!BASH_LINENO[@]}; do
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

function file_check() {
    local file=$1
    local file_type="";
    [[ -e "$file" ]] && file_type+="e"
    [[ ! -e "$file" ]] && [[ -L "$file" ]] && file_type+="L?"
    if [[ -e "$file" ]] || [[ -L "$file" ]] ; then
        [[ -f "$file" ]] && file_type+="f"
        [[ -d "$file" ]] && file_type+="d"
        [[ -b "$file" ]] && file_type+="b"
        [[ -c "$file" ]] && file_type+="c"
        [[ -p "$file" ]] && file_type+="p"
        [[ -S "$file" ]] && file_type+="S"
        [[ -t "$file" ]] && file_type+="t"
        [[ -L "$file" ]] && file_type+="L"
        [[ -L "$file" ]] && [[ -e "$(readlink "$file")" ]] && file_type+="+"
    fi
    echo "$file_type"
}

# -----------------------------------------------------------------
# FLOATING_POINT_DIVISION returns a floating point "string" with
# the result of diving numerator by denominator and rounding any
# result to precision decimal places.
# Usage: string=$(floating_point_division "numerator" "denomiator"
# "precision")
# -----------------------------------------------------------------
function floating_point_division() {
	# Input variables
	local numerator=1;
	local denomiator=1;
	local precision=2;

	# Internal variables
	local error="";
	local intermediate=0;
	local quotient=0;
	local quotient_integer_part=0;
	local quotient_decimal_part=0;
	local rounding_factor=0;

	# Check that input is provided.
	[[ -n "$1" ]] && numerator="$(($1*1))" || error="Numerator was not supplied.";
	[[ -n "$2" ]] && denomiator="$(($2*1))" || error="Denomiator was not supplied.";
	[[ -n "$3" ]] && precision="$(($3*1))";
	
	# Provide feedback on input errors.
	if [[ -n "$error" ]]; then
		echo "$error";
		return;
	fi

	# Perform division
	numerator=$((numerator * ( 10**(precision + 1) ) ));
	intermediate=$(( numerator / denomiator ));

	# Split result
	quotient_integer_part=${intermediate:0:$(( ${#intermediate} - ( precision + 1 ) ))};
	quotient_decimal_part=${intermediate:$(( ${#intermediate} - ( precision + 1 ) )):$(( precision + 1 - 1))};
	rounding_factor=${intermediate:$(( ${#intermediate} - 1 )):1};

	while [[ "${quotient_decimal_part:0:1}" == "0" ]] && (( ${#quotient_decimal_part} > 1 )) do
		quotient_decimal_part="${quotient_decimal_part:1:${#quotient_decimal_part}-1}";
	done

	# perform rounding
	if (( rounding_factor >= 5 )); then
		quotient_decimal_part=$(( quotient_decimal_part + 1 ));
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
	echo "$quotient";
	return;
}
# -----------------------------------------------------------------

function guess_digest_type() {
	local answer="";
	local digest="";
	if [[ -n "$1" ]]; then
		digest="$1";
	fi

	case "${#digest}" in
		32) answer="md5"; ;;
		40) answer="sha1"; ;;
		56) answer="sha224"; ;;
		64) answer="sha256"; ;;
		96) answer="sha384"; ;;
		128) answer="sha512"; ;;
		*) ;;
	esac

	echo "$answer";
	return 0;
}

# -----------------------------------------------------------------
# HEX2RGB takes a web heax triplet and returns an rgb code sutable
# for this project.
# Usage: value=$(hex2rgb "#rrggbb")
# -----------------------------------------------------------------
function hex2rgb {
	local hex="$1";
	if [[ -z "$hex" ]]; then
		hex="#000000";
	fi
	local rgb="";
	rgb="$((16#${hex:1:2}))";
	rgb+=";";
	rgb+="$((16#${hex:3:2}))";
	rgb+=";";
	rgb+="$((16#${hex:5:2}))";
	echo "$rgb";
	return
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# HUMAN_NUMBER returns a human-readable string version of the
# provided large integer, rounded to the nearest magnitude. It
# returns the appropiate short abbriviation, B for Bytes, K for
# Kilobytes, M for Megabytes, G for Gigabytes, or T for Terabytes.
# Usage: string=$(human_readable "large_integer")
# -----------------------------------------------------------------
function human_number() {
	local long_number=0;
	[[ -n "$1" ]] && long_number="$1" || error="No value was passed to the function";
	[[ -n "$error" ]] && echo "$error" && return;

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
	local decimal_places="2";
	local short_number="0B";
	local magnitude=0;

	# Even if a larger precision is requested, round Bytes to integers,
	# and Kilobytes to 1 decimal place.
	for ((s=0; s<=${#sizes[*]}; s=$((s+steps)))) do
		magnitude="${sizes[s]}";
		if (( magnitude == 0 )); then
			if (( long_number >= base * magnitude )) && (( long_number < base**magnitude )); then
				decimal_places=0;
				break;
			fi
		elif (( magnitude == 1 )); then
			if (( long_number >= 1 )) && (( long_number < 1024 )); then
				decimal_places=0;
				break;
			fi
		elif (( magnitude == 2 )); then
			if (( long_number >= 1024 )) && (( long_number < 1048576 )); then
				decimal_places=1;
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
		short_number=$(floating_point_division "$long_number" "$(( base**(magnitude) ))" "$decimal_places")
	else
		short_number=$(floating_point_division "$long_number" "$(( base**(magnitude - 1) ))" "$decimal_places")
	fi

	# look up the appropriate abbriviation.
	magnitude_abbriviation="${sizes[s+1]}"

	# return the rounded floating point (or integer) and the
	# abbriviated magnitude.
	echo "${short_number}${magnitude_abbriviation}";
	return;
}

function isnumeric() {
	local answer=true;
	local sign="";
	local value="";
	local min="";
	local max="";
	# local isinteger=false;
	local i=0;
	# local isdecimal=false;

	if [[ -n "$1" ]]; then
		value="$1";
		if [[ -n "$2" ]]; then
			min="$2";
			if [[ -n "$3" ]]; then
				max="$3";
	# 			if ! [[ -z "$4" ]]; then
	# 				if [[ "$4" == "integer" ]] | [[ "$4" == "integer" ]]; then
	# 					isinteger=true;
	# 				fi
	# 			fi
			fi
		fi
	fi

	if [[ -z "$value" ]]; then
		answer=false;
	fi

	if [[ $answer == true ]]; then
		if [[ $(echo "$value" | cut -b1) == "+" ]]; then
			sign="+";
		fi
		if [[ $(echo "$value" | cut -b1) == "-" ]]; then
			sign="-";
		fi
		if [[ -n "$sign" ]]; then
			local temp="";
			for (( i=1; i<$(( ${#value} + 1 )); i++ )) do
				if (( i > 1 )); then
					temp+=$(echo "$value" | cut -b$i);
				fi
			done
			value="$temp";
		fi
	fi

	for (( i=1; i<$(( ${#value} + 1 )); i++ )) do
		case $(echo "$value" | cut -b$i) in
			"0"|"1"|"2"|"3"|"4"|"5"|"6"|"7"|"8"|"9") true; ;;
	# 		".") isdecimal=true; ;;
			*) answer=false; ;;
		esac
	done

    value="$sign$value"

	if [[ $answer == true ]]; then
		if [[ -n "$min" ]]; then
			if (( value < min )); then
				answer=false;
			fi
			if [[ $answer == true ]]; then
				if [[ -n "$max" ]]; then
					if (( value > max - 1 )); then
						answer=false;
					fi
				fi
			fi
		fi
	fi

	# if [[ $isinteger == true ]]; then
	# 	if [[ $isdecimal == true ]]; then
	# 		answer=false;
	# 	fi
	# fi

	if [[ "$__resultvar" ]]; then
		eval "$__resultvar"="'$answer'";
	else
		echo "$answer";
	fi
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

# -----------------------------------------------------------------------------
# The month2num() function converts months by name to their number. It handles
# both full length names such as "November" as well as three letter code 
# abbriviations like "Nov". It also handles both upper and lower (and mixed) 
# cases. It can output the month number with an optional prepended zero as 
# appropriate such as "05" for months earlier than October.
# 
# Usage: month_num=$(month2num "$month_string" "--prepend_zero")
# -----------------------------------------------------------------------------
function month2num() {
  local month_input="";
  local month=0;
  local leading="";

  if ! [[ -z "$1" ]]; then
    month_input=`echo "$1" | cut -b1-3 | tr "[:upper:]" "[:lower:]"`;

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

  if ! [[ -z "$2" ]]; then
    if [[ "$2" == "--prepend_zero" ]]; then
      leading="0";
    fi
  fi

  if [[ $(( month < 10 )) == "1" ]]; then
    month="$leading""$month";
  fi

  if [[ "$__resultvar" ]]; then
      eval $__resultvar="'$month'";
  else
      echo "$month";
  fi
}

nap() {
  local delay="1"

  if ! [ -z "$1" ]; then
    delay="$1"
  fi

  # Echo this message first
  echo "Pausing to allow time to stop the script.";
  echo "(press ctrl-c to stop)";

  local i=1
  for (( i="$delay"; i>0; i=$(( i - 1 )) )); do
      echo -n "$i... "
      sleep 1
  done
  echo "";

  # echo a blank line after the countdown
  echo "";
}

# --- Pause --------------------------------------------------------------------
pause() {
		local timeout="";
	  if [[ -n "$1" ]]; then
	  	timeout="-t $1";
	  fi
    read -n 1 $timeout -r -s -p "(press any key to continue)" "discard";
    echo "";
    return;
}
# ------------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# The read_x509() function reads and parses x509 certificate files. Pass the 
# full path and filename to the function. Output is a string list in the 
# following format.
# 
# $subject,$expiration_date,$will_expire_yes_no,$fqdn_list
# 
# Usage: cert_info=$(read_x509 "$cert")
# -----------------------------------------------------------------------------
function read_x509() {
  local secinday=86400;
  local cert_file="";
  local cert_data="";

  if ! [[ -z "$1" ]]; then
    cert_file="$1";
    #local cert_subject=`openssl x509 -in "$cert_file" -nocert -subject | cut -d= -f2,3`
    local cert_subject_domain=`openssl x509 -in "$cert_file" -nocert -subject | cut -d= -f3 | cut -b2-`;

    local cert_fqdn_list=`openssl x509 -in "$cert_file" -nocert -ext subjectAltName | echo -En | cut -z -c39- | cut -d, -f1- --output-delimiter=""`;

    local cert_end_date=`openssl x509 -in "$cert_file" -nocert -enddate | cut -d"=" -f2`;
    local cert_end_year=`echo "$cert_end_date" | rev | cut -d" " -f2 | rev`;
    local cert_end_month_string=`echo "$cert_end_date" | cut -d" " -f1`;
    local cert_end_month_num=$(month2num "$cert_end_month_string" "--prepend_zero");
    local cert_end_day=`echo "$cert_end_date" | rev | cut -d" " -f4 | rev`;
    if [[ $(( cert_end_day < 10 )) = 1 ]]; then
      cert_end_day="0""$cert_end_day";
    fi
    local cert_end="${cert_end_year}-${cert_end_month_num}-${cert_end_day}";

    local cert_will_expire=`openssl x509 -in "$cert_file" -nocert -checkend $(( 7 * $secinday )) | grep --color=no "will expire"`;
    if ! [[ -z "$cert_will_expire" ]]; then
      cert_will_expire="true";
    else
      cert_will_expire="false";
    fi

    cert_data="$cert_subject_domain,$cert_end,$cert_will_expire,$cert_fqdn_list";
  fi

  if [[ "$__resultvar" ]]; then
      eval $__resultvar="'$cert_data'";
  else
      echo "$cert_data";
  fi
}

remove_from_array() {
	local array_to_check="";
	local check_array=();
	local index_to_remove="-1";
	local i=0;

	if [[ -n "$1" ]]; then
		array_to_check="$1";
		if [[ -n "$2" ]]; then
			index_to_remove="$2";
		fi
	else
		return
	fi

	# echo -e "Array_to_Check: $array_to_check";
	# if (( index_to_remove > -1 )); then
	# 	echo -e "Index_to_Remove: $index_to_remove";
	# fi

	# import to local array
	case "$array_to_check" in
		"param_array")
			check_array=();
			for ((i=0; i<${#param_array[*]}; i++)) do
				check_array+=("${param_array[i]}");
			done
			;;
		"directory_listing_array")
			check_array=();
			for ((i=0; i<${#directory_listing_array[*]}; i++)) do
				check_array+=("${directory_listing_array[i]}");
			done
			;;
	esac

	# compress array at requested index
	for ((i=0; i<${#check_array[*]}; i++)) do
		# echo -en "   Data ($i): \"${check_array[i]}\"";
		if (( index_to_remove > -1 )); then
			if (( i >= index_to_remove )); then
				if (( i + 1 < ${#check_array[*]} )); then
					check_array[i]="${check_array[i+1]}";
				else
					check_array[i]="";
				fi
			# 	echo -en "  <--  \"${check_array[i]}\"";
			# else
			# 	echo -en "";
			fi
			# if (( i == index_to_remove )); then
			# 	echo -en "  <-- Overwrite"
			# fi
			if (( i == ${#check_array[*]} - 1 )); then
				# echo -en "  <-- Compressing";
				unset -v "check_array[${#check_array[*]}-1]";
			fi
		fi
	done

	# export back to global variable
	case "$array_to_check" in
		"param_array")
			param_array=();
			for ((i=0; i<${#check_array[*]}; i++)) do
				param_array+=("${check_array[i]}");
			done
			;;
		"directory_listing_array")
			directory_listing_array=();
			for ((i=0; i<${#check_array[*]}; i++)) do
				directory_listing_array+=("${check_array[i]}");
			done
			;;
	esac

	# echo -e "-------------------------------------------------------------------------------";
	return
}

repeat() {
    # usage: repeat "40" "_|\_/|_" "varname"
    # $1=number of patterns to repeat
    # $2=pattern
    # $3=output variable name
    printf -v "$3" '%*s' "$1"
    printf -v "$3" '%s' "${!3// /$2}"
}

# -----------------------------------------------------------------
# RGB2HEX takes an rgb code formatted as an escaped color code for
# bash, and retruns a typical web hex tripplet color code #RRGGBB
# Usage: value=$(rgb2bash "r#;g#;b#")
# -----------------------------------------------------------------
function rgb2hex {
	local rgb="$1";
	if [[ -z "$rgb" ]]; then
		rgb="0;0;0";
	fi

	local dr=0
	local dg=0
	local db=0
	substring ";" "$rgb";
	dr=${substring[1]};
	substring ";" "${substring[3]}"
	dg=${substring[1]};
	db=${substring[3]};

	local hr="";
	local hg="";
	local hb="";
	hr=$(echo "obase=16; $dr" | bc)
	hg=$(echo "obase=16; $dg" | bc)
	hb=$(echo "obase=16; $db" | bc)
	if (( ${#hr} == 1 )); then
		hr="0$hr";
	fi
	if (( ${#hg} == 1 )); then
		hg="0$hg";
	fi
	if (( ${#hb} == 1 )); then
		hb="0$hb";
	fi

	echo "#${hr}${hg}${hb}";
	return
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
			string=" $2 ";
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

# ----------------------
x=$(build_cert_line "$@")
x=$(elapsed "$@")
x=$(error_message "$@")
x=$(error_report "$@")
x=$(file_check "$@")
x=$(floating_point_division "$@")
x=$(guess_digest_type "$@")
x=$(hex2rgb "$@")
x=$(human_number "$@")
x=$(isnumeric "$@")
x=$(ltrim "$@")
x=$(month2num "$@")
x=$(nap "$@")
x=$(pause "$@")
x=$(read_x509 "$@")
x=$(remove_from_array "$@")
x=$(repeat "$@")
x=$(rgb2hex "$@")
x=$(rtrim "$@")
x=$(space "$@")
x=$(substring "$@")
x=$(trim "$@")
# -------------------
echo "$x" >/dev/null
