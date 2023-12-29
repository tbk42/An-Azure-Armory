#!/bin/bash
# -----------------------------------------------------------------
# An Azure Armory
# Cryptography Functions
# -----------------------------------------------------------------
# build_cert_line2
# build_cert_line
# guess_digest_type
# read_x509
# -----------------------------------------------------------------

# -----------------------------------------------------------------------------
# The build_cert_line() function generates a colorful readout making 
# certificate expiration date and status easy to identify. Pass the full path 
# and filename of the certificate to the function.
# 
# Useage: one_line=$(build_cert_line "$cert_end" "$cert_name" "cert_name_maxlength")
# -----------------------------------------------------------------------------
function build_cert_line2() {
	local secinday=86400;
	local domain_maxlength=0;
	local cert_end="";
	local cert_name="";
	local cert_end_stripped="";
	local cert_end_as_sec="";
	local today="";
	local today_stripped="";
	local today_as_sec="";
	local difference_as_days="";
	local icon="";
	local domain_text="";
	local domain_background="";
	local highlight_color="";
	local highlight_background="";
	local highlight_text="";
	local post_note="";
	local post_command="";
	local time_frames=();
	local build="";
  
	if [[ -n "$1" ]]; then
		cert_end="$1";
	fi
	if [[ -n "$2" ]]; then
		cert_name="$2";
	fi
	if [[ -n "$3" ]]; then
		domain_maxlength="$3";
	fi

	one_domain="$cert_name";
	after_domain_space="";
	for ((i=0; i<$((domain_maxlength - ${#one_domain})); i++)); do
		after_domain_space="$after_domain_space ";
	done

	cert_end_stripped=$(echo "$cert_end" | cut -c5,8 --complement);
	cert_end_as_sec=$(date +%s -d "$cert_end_stripped");

	today=$(date +%Y-%m-%d);
	today_stripped=$(echo "$today" | cut -c5,8 --complement);
	today_as_sec=$(date +%s -d "$today_stripped");

	difference_as_days=$(((cert_end_as_sec - today_as_sec) / secinday));

	# defaults
	# endcaps are actually a text/foreground item
	# endcap_color use highlight_color
	# icon_color use highlight_text_color (already set)
	# icon_background use highlight_background (already set)
	# middle area with domain text ... same for everyone
	# domain_text do not set, use default
	# domain_background do not set, use default
	# date_text_color use highlight_text (already set)
	# date_background_color use highlight_background (already set)
	# shellcheck disable=SC2154
	icon="$warning";
	# shellcheck disable=SC2154
	domain_text="$c_white";
	# shellcheck disable=SC2154
	domain_background="$c_back_grey_234";
	# shellcheck disable=SC2154
	highlight_color="$c_yellow";
	# shellcheck disable=SC2154
	highlight_background="$c_back_yellow";
	# shellcheck disable=SC2154
	highlight_text="$c_black";
	post_note=" - manual review";
	post_command="";

	time_frames=();			# 0 or less  is red:    expired
	time_frames+=("0");		# 1 - 20     is gold:   renew overdue
	time_frames+=("20");	# 21 - 30    is yellow: renew now
	time_frames+=("29");	# 30 - 31    is purple: pending
	time_frames+=("31");	# 32 or over is green:  good

	if (( difference_as_days > time_frames[3] )); then
		# green: 32 or more days, good.
		# shellcheck disable=SC2154
		icon="$good";
		# shellcheck disable=SC2154
		highlight_color="$c_green";
		# shellcheck disable=SC2154
		highlight_background="$c_back_green";
		highlight_text="$c_black";
		post_note="";
	elif (( difference_as_days > time_frames[2] )); then
		# purple: Between 30 and 32 days, alert period
		icon="$good";
		# shellcheck disable=SC2154
		highlight_color="$c_purple";
		# shellcheck disable=SC2154
		highlight_background="$c_back_purple";
		highlight_text="$c_white";
		post_note=" - Renewal pending within $(( time_frames[3] - time_frames[2] )) days";
	elif (( difference_as_days > time_frames[1] )); then
		# yellow: Between 21 and 30 days, renew should run
		# shellcheck disable=SC2154
		icon="$warning";
		# shellcheck disable=SC2154
		highlight_color="$c_gold";
		# shellcheck disable=SC2154
		highlight_background="$c_back_gold";
		# shellcheck disable=SC2154
		highlight_text="$c_black";
		post_note=" - Renewal should run now";
	elif (( difference_as_days > time_frames[0] )); then
		# gold: Between 21 and 0 days, renew is overdue
		# shellcheck disable=SC2154
		icon="$warning";
		# shellcheck disable=SC2154
		highlight_color="$c_yellow";
		# shellcheck disable=SC2154
		highlight_background="$c_back_yellow";
		# shellcheck disable=SC2154
		highlight_text="$c_black";
		post_note=" - Renewal is overdue";
	else
		# red: Zero or fewer days, expired.
		# shellcheck disable=SC2154
		icon="$bad";
		# shellcheck disable=SC2154
		highlight_color="$c_red";
		# shellcheck disable=SC2154
		highlight_background="$c_back_red";
		# shellcheck disable=SC2154
		highlight_text="$c_white";
		post_note=" - Expired";
	fi

	build="  ";
	# shellcheck disable=SC2154
	build+="${highlight_color}${outter_left_end}";
	build+="${highlight_background}${highlight_text} ${icon} ";
	# shellcheck disable=SC2154
	build+="${domain_background}${highlight_color}${inner_right_end}";

	build+="${domain_background}${domain_text}  ${cert_name}  ${after_domain_space}";

	# shellcheck disable=SC2154
	build+="${domain_background}${highlight_color}${inner_left_end}";
	# shellcheck disable=SC2154
	build+="${highlight_background}${highlight_text} ${cert_end} ${c_reset}";
	# shellcheck disable=SC2154
	build+="${highlight_color}${outter_right_end}";
	build+="${c_reset}";
	build+="${post_note}";
	if [[ -n "$post_command" ]]; then
		$post_command
	fi

	if [[ "$__resultvar" ]]; then
		eval "$__resultvar"="'$build'";
	else
		echo "$build";
	fi
}

# -----------------------------------------------------------------------------
# The build_cert_line() function generates a colorful readout making 
# certificate expiration date and status easy to identify. Pass the full path 
# and filename of the certificate to the function.
# 
# Useage: one_line=$(build_cert_line "$new_cert")
# -----------------------------------------------------------------------------
function build_cert_line() {
	local good="✓";
	local warning="◬";
	local bad="⬣";
	local outter_left_end="\uE0B4";
	local outter_right_end="\uE0B4";
	local inner_left_end="\uE0B4";
	local inner_right_end="\uE0B4";

	local secinday=86400;
	local one_cert="";
	local cert_info="";
	local cert_name="";
	local cert_end="";
	local cert_will_expire="";
	# local cert_ext_domains="";
	local cert_end_stripped="";
	local cert_end_as_sec="";
	local today="";
	local today_stripped="";
	local today_as_sec="";
	local difference_as_days="";
	local icon="";
	local foreground_color="";
	local background_color="";
	local pri_color="";
	local build="";

	if [ -n "$1" ]; then
		one_cert="$1";

		cert_info=$(read_x509 "$one_cert");

		cert_name=$(echo "$cert_info" | cut -d, -f1);
		cert_end=$(echo "$cert_info" | cut -d, -f2);
		cert_will_expire=$(echo "$cert_info" | cut -d, -f3);

		# cert_ext_domains=$(echo "$cert_info" | cut -d, -f4);

		cert_end_stripped=$(echo "$cert_end" | cut -c5,8 --complement);
		cert_end_as_sec=$(date "+%s" -d "$cert_end_stripped");

		today=$(date "+%Y-%m-%d");
		today_stripped=$(echo "$today" | cut -c5,8 --complement);
		today_as_sec=$(date "+%s" -d "$today_stripped");

		difference_as_days=$(( (cert_end_as_sec - today_as_sec) / secinday ));

		# shellcheck disable=SC2154
		icon="$warning";
		# shellcheck disable=SC2154
		foreground_color="$(color white bold)";
		# shellcheck disable=SC2154
		background_color="$back_dkgray";
		# shellcheck disable=SC2154
		pri_color="$white";

	    if [ $(( difference_as_days > 6 )) == 1 ]; then
			# shellcheck disable=SC2154
			icon="$good";
			# shellcheck disable=SC2154
			foreground_color="$green";
			# shellcheck disable=SC2154
			background_color="$back_green";
			pri_color="$white";
	    elif [ $(( difference_as_days > 0 )) == 1 ]; then
			icon="$warning";
			# shellcheck disable=SC2154
			foreground_color="$yellow";
			# shellcheck disable=SC2154
			background_color="$back_yellow";
			# shellcheck disable=SC2154
			pri_color="$bold_black";
	    else
			# shellcheck disable=SC2154
			icon="$bad";
			# shellcheck disable=SC2154
			foreground_color="$red";
			# shellcheck disable=SC2154
			background_color="$back_red";
			pri_color="$white";
	    fi

		# shellcheck disable=SC2154
		build+="${foreground_color}${outter_left_end}${reset}";
		# shellcheck disable=SC2154
		build+="${background_color}${pri_color}${bold} ${icon} ${reset}";
		# shellcheck disable=SC2154
		build+="${foreground_color}${back_dkgray}${inner_right_end}${reset}";

		build+="${back_dkgray}${white}  ${cert_name}   ${reset}";

		# shellcheck disable=SC2154
		build+="${foreground_color}${back_dkgray}${inner_left_end}${reset}";
		# shellcheck disable=SC2154
		build+="${background_color}${pri_color} ${cert_end} ${reset}";
		# shellcheck disable=SC2154
		build+="${foreground_color}${outter_right_end}${reset}";
	fi

	if [[ "$__resultvar" ]]; then
		eval "$__resultvar"="'$build'";
	else
		echo "$build";
	fi
}

# -----------------------------------------------------------------------------
# The guess_digest_type() function guesses what type of hash digest is supplied
#	based on the length of the digest. md5's are 32 characters, sha1 is 40
#	characters, and so on. Please note that Blake2b (abbrivated b2) is 128
#	characters, the same length as sha512.
# 
# Useage: guess=$(guess_digest_type "digest")
# -----------------------------------------------------------------------------
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
		*) answer="unknown"; ;;
	esac

	if [[ "$__resultvar" ]]; then
		eval "$__resultvar"="'$answer'";
	else
		echo "$answer";
	fi
	return 0;
}

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
	local cert_subject_domain="";
	local cert_fqdn_list="";
	local cert_end="";
	local cert_end_date="";
	local cert_end_year="";
	local cert_end_month_string="";
	local cert_end_month_num="";
	local cert_end_day="";
	local cert_will_expire="";

	if [[ -n "$1" ]]; then
		cert_file="$1";

		#local cert_subject=$(openssl x509 -in "$cert_file" -nocert -subject | cut -d= -f2,3);
		cert_subject_domain=$(openssl x509 -in "$cert_file" -nocert -subject | cut -d= -f3 | cut -b2-);

		cert_fqdn_list=$(openssl x509 -in "$cert_file" -nocert -ext subjectAltName | cut -s -d, -f1- --output-delimiter=" ");

		cert_end_date=$(openssl x509 -in "$cert_file" -nocert -enddate | cut -d"=" -f2);
		cert_end_year=$(echo "$cert_end_date" | rev | cut -d" " -f2 | rev);
		cert_end_month_string=$(echo "$cert_end_date" | cut -d" " -f1);
		cert_end_month_num=$(month2num "$cert_end_month_string" "--prepend_zero");
		cert_end_day=$(echo "$cert_end_date" | rev | cut -d" " -f4 | rev);
		if [[ $(( cert_end_day < 10 )) = 1 ]]; then
			cert_end_day="0""$cert_end_day";
		fi
		cert_end="${cert_end_year}-${cert_end_month_num}-${cert_end_day}";

		cert_will_expire=$(openssl x509 -in "$cert_file" -nocert -checkend $(( 7 * secinday )) | grep --color=no "will expire");
		if [[ -n "$cert_will_expire" ]]; then
			cert_will_expire="true";
		else
			cert_will_expire="false";
		fi

		cert_data="$cert_subject_domain,$cert_end,$cert_will_expire,$cert_fqdn_list";
	fi

	if [[ "$__resultvar" ]]; then
		eval "$__resultvar"="'$cert_data'";
	else
		echo "$cert_data";
	fi
}
