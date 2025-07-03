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
# $(color reset) $(color blue) $(color green bg)
# $(color #ff0000 fg italic)
# var=$(color request [format] [layer] [style])
# var=$(color name|xterm#|r#;g#;b#|#rrggbb
#             [x|xterm|rgb] [fg|bg] [b|bold|i|italic|u|underline])
# -----------------------------------------------------------------
source "$(dirname "$(realpath "${BASH_SOURCE:-$0}")")/string.sh"

function color() {
    local output="";
    # constants
    local esc="\e[";
    local fg="38;";
    local bg="48;";
    local xterm="5;"
    local rgb="2;"
    local m="m";
    local bold=";1";
    local italics=";3";
    local underline=";4";

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
        request=$(hex2rgb "${hex}")
        # request="$((16#${hex:1:2}))";
        # request+=";";
        # request+="$((16#${hex:3:2}))";
        # request+=";";
        # request+="$((16#${hex:5:2}))";
    elif [[ "$request_type" == "name" ]]; then
        # Ensure name requests are lowercased for consistent comparison
        request="${request,,}"
    fi

    local found_index=-1
    local -n search_array # Nameref for the array to search (requires Bash 4.3+)

    # Determine which array to search based on request_type
    case "$request_type" in
        "xterm") search_array=xterm_array ;;
        "rgb") search_array=rgb_array ;;
        "name") search_array=name_array ;;
        *) # This case should ideally not be reached if request_type is always set correctly
           echo "Error: Unknown request type '$request_type' in color function." >&2
           i=0; request="reset"; # Fallback to black/reset
           output+="${esc}${layer}${output_format}${value}${style}${m}";
           echo "${output}";
           return;
           ;;
    esac

    # Iterate through the selected array to find the matching index
    for ((idx=0; idx<${#search_array[*]}; idx++)); do
        if [[ "${search_array[idx],,}" == "${request,,}" ]]; then
            found_index="${idx}"
            break
        fi
    done

    if (( found_index == -1 )); then # Color not found in the arrays
        i=0;
        request="reset";
    else
        i="${found_index}"; # Set 'i' to the found index
    fi

    if [[ "$request" == "reset" ]]; then
        i=-1;
        layer="";
        output_format="";
        style="";
        value="0";
    else
        # Use the determined 'i' (either 0 for not found, or found_index)
        if [[ "$output_format" == "$rgb" ]]; then
            value="${rgb_array[i]}"
        else
            value="${xterm_array[i]}"
        fi
    fi

    output+="${esc}${layer}${output_format}${value}${style}${m}";
    echo "${output}";
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
substring=()
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
    hr=$(printf "%02X" "$dr")
    hg=$(printf "%02X" "$dg")
    hb=$(printf "%02X" "$db")

    echo "#${hr}${hg}${hb}";
    return
}
# -----------------------------------------------------------------
