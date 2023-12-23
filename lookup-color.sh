#!/bin/bash
script_real_path=$(realpath "${BASH_SOURCE:-$0}")
script_real_dir=$(dirname "$script_real_path")
source "$script_real_dir/xterm_colors.sh";
source "$script_real_dir/color.sh";
source "$script_real_dir/string.sh";

if (( $# == 0 )); then
	echo "No value was submitted.";
	exit 1;
fi

name_max_length=0
for ((i=0; i<${#name_array[*]}; i++)) do
	if (( ${#name_array[i]} > name_max_length )); then
		name_max_length=${#name_array[i]};
	fi
done

# xterm_max_length=5
rgb_max_length=11
hex_max_length=7
sample_max_length=24

echo -en "$(color black bg)$(color white bold)";
echo -en "Sample$(space "$((sample_max_length - 6))")";
echo -en " ";
echo -en "Hex$(space "$((hex_max_length - 3))")";
echo -en " ";
echo -en "RGB$(space "$((rgb_max_length - 3))")";
echo -en " ";
echo -en "XTerm";
echo -en " ";
echo -en "Name$(space "$((name_max_length - 4))")";
echo -e "$(color reset)";


for ((p=1; p<=$#; p++)) do
	if [[ -z "${*:p:1}" ]]; then
		request_type="name";
		request="empty string";
	elif [[ -z "$(trim "${*:p:1}")" ]]; then
		request_type="name";
		request="white space";
	elif [[ ${*:p:1} =~ ^[0-9]+?$ ]]; then
		# xterm request is purely numeric (no decimal, no signed, and no currency (us dollar))
		request_type="xterm";
		request="${*:p:1}";
	elif [[ ${*:p:1} =~ ^[0-9]{1,3}\;[0-9]{1,3}\;[0-9]{1,3}$ ]]; then
		# r#;g#;b# request is purely numeric with ; in the patten rrr;ggg;bbb
		request_type="rgb";
		request="${*:p:1}";
	elif [[ ${*:p:1} =~ ^#[0-9a-fA-F]{6}$ ]]; then
		# #rrggbb is a standard web hex color code.
		request_type="hex";
		request="${*:p:1}";
	else
		# anything else, must be a name
		request_type="name";
		request="${*:p:1}";
	fi

	case "$request_type" in
		"name") substring "${request,,}" "${name_array[*],,}"; ;;
		"hex") substring "$(hex2rgb "${request,,}")" "${rgb_array[*],,}"; ;;
		"rgb") substring "${request,,}" " ${rgb_array[*],,}"; ;;
		"xterm") substring "${request,,}" "${xterm_array[*],,}"; ;;
	esac

	# shellcheck disable=SC2206
	remaining_array=(${substring[1]});
	r=${#remaining_array[*]}

	if (( r == ${#name_array[*]} )); then
		echo -e "Search for $request_type \"$request\" not found."
		continue;
	fi

	this_hex=$(rgb2hex "${rgb_array[r]}");
	echo -en "$(color "white" bg)$(color "${xterm_array[r]}") text $(color reset)"; # color on white
	echo -en "$(color "${xterm_array[r]}" bg)$(color "white") text $(color reset)"; # white on color
	echo -en "$(color "black" bg)$(color "${xterm_array[r]}") text $(color reset)"; # color on black
	echo -en "$(color "${xterm_array[r]}" bg)$(color "black") text $(color reset)"; # black on color
	if (( r > 255 )); then
		echo -en "$(color black bg)";
	fi
	echo -en " ";
	echo -en "${this_hex}$(space "$((hex_max_length - ${#this_hex}))")";
	echo -en " ";
	echo -en "${rgb_array[r]}$(space "$((rgb_max_length - ${#rgb_array[r]}))")";
	echo -en " ";
	echo -en " $(space "$((3 - ${#xterm_array[r]}))")${xterm_array[r]} ";
	echo -en " ";
	echo -en "${name_array[r]}$(space "$((name_max_length - ${#name_array[r]}))")";
	echo -e "$(color reset)";
done
exit 0;
