#!/bin/bash
xterm_array=();
rgb_array=();
name_array=();
script_real_path=$(realpath "${BASH_SOURCE:-$0}")
script_real_dir=$(dirname "$script_real_path")
source "$script_real_dir/../function-colors/xterm_colors.sh";
source "$script_real_dir/../function-colors/colors.sh";

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
