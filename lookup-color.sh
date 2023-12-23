#!/bin/bash
xterm_array=();
rgb_array=();
name_array=();
# script_real_path=$(realpath "${BASH_SOURCE:-$0}")
# script_real_dir=$(dirname "$script_real_path")

source "./string.sh"
source "./color.sh"
source "./xterm_colors.sh";

if (( $# == 0 )); then
	echo "No value was submitted.";
	exit 1;
fi

i=1
if [[ ${*:i:1} =~ ^[0-9]+?$ ]]; then
	# xterm request is purely numeric (no decimal, no signed, and no currency (us dollar))
	request_type="xterm";
	request="${*:i:1}";
elif [[ ${*:i:1} =~ ^[0-9]{1,3}\;[0-9]{1,3}\;[0-9]{1,3}$ ]]; then
	# r#;g#;b# request is purely numeric with ; in the patten rrr;ggg;bbb
	request_type="rgb";
	request="${*:i:1}";
elif [[ ${*:i:1} =~ ^#[0-9a-fA-F]{6}$ ]]; then
	# #rrggbb is a standard web hex color code.
	request_type="hex";
	request="${*:i:1}";
else
	# anything else, must be a name
	request_type="name";
	request="${*:i:1}";
fi

case "$request_type" in
	"name") substring "${request,,}" "${name_array[*],,}"; ;;
	"hex") substring "$(hex2rgb "${request,,}")" "${rgb_array[*],,}"; ;;
	"rgb") substring "${request,,}" " ${rgb_array[*],,}"; ;;
	"xterm") substring "${request,,}" "${xterm_array[*],,}"; ;;
esac
# shellcheck disable=SC2206
count_array=(${substring[1]});
i=${#count_array[*]}

if (( i == ${#name_array[*]} )); then
	echo "Search for $request_type $request not found ($i)"
	exit 0;
fi

hex="$(rgb2hex "${rgb_array[i]}")";

echo -e " Color: ${name_array[i]}";
echo -e " XTerm: ${xterm_array[i]}";
echo -e "   RGB: ${rgb_array[i]}";
echo -e "   Hex: $hex";
echo -e "Sample: $(color "$hex" bg)$(color "white") text $(color reset)$(color "white" bg)$(color "$hex") text $(color reset)$(color "black" bg)$(color "$hex") text $(color reset)$(color "$hex" bg)$(color "black") text $(color reset)"
exit 0;
