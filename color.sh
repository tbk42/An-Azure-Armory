#!/bin/bash
# -----------------------------------------------------------------
# An Azure Armory
# X Functions
# -----------------------------------------------------------------
# color
# hex2rgb
# rgb2hex
# -----------------------------------------------------------------

# Script name, real name, real dir, real path
# script_real_path=$(realpath "${BASH_SOURCE:-$0}")
# script_real_dir=$(dirname "$script_real_path")
# script_real_name="$(echo "$script_real_path" | rev | cut -d/ -f1 | rev)";
# script_local_name="$(echo "$0" | rev | cut -d/ -f1 | rev)";

# -----------------------------------------------------------------
# COLOR returns the escaped 256-color code for output to the
#   terminal. Format is the output format, so you can request the
#   rgb for xterm color numbers. Returns the reset value for color
#   requests that are not found.
# 
# Usage:
# var=$(color request [format] [layer] [style])
# var=$(color name|xterm#|r#;g#;b#|#rrggbb
#             [x|xterm|rgb] [fg|bg] [b|bold|i|italic|u|underline])
# -----------------------------------------------------------------
function color() {
    # constants
    local esc="\e[";
    local fg="38;";
    local bg="48;";
    local xterm="5;"
    local rgb="2;"
    local m="m";
    local bold=";1";
    local italics=";2";
    local underline=";3";

    local request="reset";
    local request_type="";
    local output_format="$xterm";
    local layer="$fg";
    local style="";

    local hex="";
    local value="";

    local param="";
    if (( $# > 0 )); then
        for ((i=1; i<=$#; i++)); do
            param=${*:i:1}
            case "${param,,}" in
                "x"|"xterm") output_format="$xterm"; ;;
                "rgb") output_format="$rgb"; ;;

                "fg"|"fore"|"foregroud") layer="$fg"; ;;
                "bg"|"back"|"backgroud") layer="$bg"; ;;
                
                "b"|"bold") style+="$bold"; ;;
                "i"|"italics") style+="$italics"; ;;
                "u"|"underline") style+="$underline"; ;;

                *)  if [[ ${*:i:1} =~ ^[0-9]+?$ ]]; then
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
            esac
        done
    fi

    # Data
    local name_array=();
    local xterm_array=();
    local rgb_array=();

    # import the xterm colors file building the three
    # arrays listed above with the official colors list.
    source "$(dirname "$(realpath "${BASH_SOURCE:-$0}")")/xterm_colors.sh"

    if [[ "$request_type" == "hex" ]]; then
        request_type="rgb";
        hex="$request";
        request="$((16#${hex:1:2}))";
        request+=";";
        request+="$((16#${hex:3:2}))";
        request+=";";
        request+="$((16#${hex:5:2}))";
    fi

    case "$request_type" in
        "xterm") substring " ${request,,}" "${xterm_array[*],,}"; ;;
        "rgb") substring "${request,,}" "${rgb_array[*],,}"; ;;
        "name") substring "${request,,}" "${name_array[*],,}"; ;;
    esac
    count_array=(${substring[1]});
    i=${#count_array[*]}

    if (( i == ${#name_array[*]} )); then
        # request (name, xterm#, r#;g#;b#, converted #rrggbb)
        # was not found, i=256, use "reset" and i=0 (black)
        i=0;
        request="reset";
    fi

    if [[ "$output_format" == "$rgb" ]]; then
        value="${rgb_array[i]}"
    else
        value="${xterm_array[i]}"
    fi

    if [[ "$request" == "reset" ]]; then
        i=-1;
        layer="";
        output_format="";
        style="";
        value="0";
    fi

    echo "${esc}${layer}${output_format}${value}${style}${m}";
    return;
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# HEX2RGB takes a web hex triplet and returns an rgb code usable in
#   bash color codes.
# 
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
# RGB2HEX takes an rgb code formatted as an escaped color code for
#   bash (where r, g, and b are from 0 to 255) & returns a typical
#   web hex tripplet color code styles like #RRGGBB
# 
# Usage: value=$(rgb2hex "r#;g#;b#")
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
