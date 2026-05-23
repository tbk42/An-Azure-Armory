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

printf "%b" "$(color black bg)$(color white bold)";
printf "%b" "Sample$(space "$((sample_max_length - 6))")";
printf "%b" " ";
printf "%b" "Hex$(space "$((hex_max_length - 3))")";
printf "%b" " ";
printf "%b" "RGB$(space "$((rgb_max_length - 3))")";
printf "%b" " ";
printf "%b" "XTerm";
printf "%b" " ";
printf "%b" "Name$(space "$((name_max_length - 4))")";
printf "%b\n" "$(color reset)";

for ((i=0; i<256; i++)) do
	this_hex=$(rgb2hex "${rgb_array[i]}");
	printf "%b" "$(color "white" bg)$(color "${xterm_array[i]}") text $(color reset)"; # color on white
	printf "%b" "$(color "${xterm_array[i]}" bg)$(color "white") text $(color reset)"; # white on color
	printf "%b" "$(color "black" bg)$(color "${xterm_array[i]}") text $(color reset)"; # color on black
	printf "%b" "$(color "${xterm_array[i]}" bg)$(color "black") text $(color reset)"; # black on color
	if (( i > 255 )); then
		printf "%b" "$(color black bg)";
	fi
	printf "%b" " ";
	printf "%b" "${this_hex}$(space "$((hex_max_length - ${#this_hex}))")";
	printf "%b" " ";
	printf "%b" "${rgb_array[i]}$(space "$((rgb_max_length - ${#rgb_array[i]}))")";
	printf "%b" " ";
#	printf "%b" "${xterm_array[i]}$(space "$((xterm_max_length - ${#xterm_array[i]}))")";
	printf "%b" " $(space "$((3 - ${#xterm_array[i]}))")${xterm_array[i]} ";
	printf "%b" " ";
	printf "%b" "${name_array[i]}$(space "$((name_max_length - ${#name_array[i]}))")";
	printf "%b\n" "$(color reset)";
done
