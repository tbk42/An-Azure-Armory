#!/bin/bash

script_real_path=$(realpath "${BASH_SOURCE:-$0}")
script_real_dir=$(dirname "$script_real_path")
source "$script_real_dir/xterm_colors.sh";
source "$script_real_dir/color.sh";
source "$script_real_dir/string.sh";

name_max_length=0
for ((i=0; i<${#name_array[*]}; i++)) do
	if (( ${#name_array[i]} > name_max_length )); then
		name_max_length=${#name_array[i]};
	fi
done

xterm_max_length=5
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

for ((i=0; i<256; i++)) do
	this_hex=$(rgb2hex "${rgb_array[i]}");
	echo -en "$(color "white" bg)$(color "${xterm_array[i]}") text $(color reset)"; # color on white
	echo -en "$(color "${xterm_array[i]}" bg)$(color "white") text $(color reset)"; # white on color
	echo -en "$(color "black" bg)$(color "${xterm_array[i]}") text $(color reset)"; # color on black
	echo -en "$(color "${xterm_array[i]}" bg)$(color "black") text $(color reset)"; # black on color
	if (( i > 255 )); then
		echo -en "$(color black bg)";
	fi
	echo -en " ";
	echo -en "${this_hex}$(space "$((hex_max_length - ${#this_hex}))")";
	echo -en " ";
	echo -en "${rgb_array[i]}$(space "$((rgb_max_length - ${#rgb_array[i]}))")";
	echo -en " ";
#	echo -en "${xterm_array[i]}$(space "$((xterm_max_length - ${#xterm_array[i]}))")";
	echo -en " $(space "$((3 - ${#xterm_array[i]}))")${xterm_array[i]} ";
	echo -en " ";
	echo -en "${name_array[i]}$(space "$((name_max_length - ${#name_array[i]}))")";
	echo -e "$(color reset)";
done
