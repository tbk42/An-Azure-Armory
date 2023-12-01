#!/bin/bash
# -----------------------------------------------------------------
# COLOR returns the escaped 256-color code for output to the
# terminal.
# Usage: var=$(color name [bg|bold])
# -----------------------------------------------------------------
# --- Colors -------------------------------------------------------------------
function color() {
    local esc="\e[";
    local fg="38;5;";
    local bg="48;5;";
    local m="m";
    local answer="";
    local name="reset";
    local layer="$fg";
    local bold="";
    if (( $# > 0 )); then
        for param in "$@"; do
            case "$param" in
                "fg"|"fore"|"foregroud") layer="$fg"; ;;
                "bg"|"back"|"backgroud") layer="$bg"; ;;
                "b"|"bold") bold=";1"; ;;
                *) name="$param"; ;;
            esac
        done
    fi

    # Data
    local name_array=();
    local value_array=();

    value_array+=("0;39"); name_array+=("reset");
    value_array+=("16");   name_array+=("black");
    value_array+=("52");   name_array+=("blood");
    value_array+=("21");   name_array+=("blue");
    value_array+=("94");   name_array+=("brown");
    value_array+=("237");  name_array+=("charcoal");
    value_array+=("51");   name_array+=("cyan");
    value_array+=("22");   name_array+=("forest");
    value_array+=("178");  name_array+=("gold");
    value_array+=("243");  name_array+=("gray");
    value_array+=("34");   name_array+=("green");
    value_array+=("243");  name_array+=("grey");
    value_array+=("192");  name_array+=("lemon");
    value_array+=("46");   name_array+=("lime");
    value_array+=("165");  name_array+=("magenta");
    value_array+=("17");   name_array+=("navy");
    value_array+=("205");  name_array+=("pink");
    value_array+=("55");   name_array+=("purple");
    value_array+=("202");  name_array+=("orange");
    value_array+=("124");  name_array+=("red");
    value_array+=("250");  name_array+=("silver");
    value_array+=("39");   name_array+=("sky");
    value_array+=("37");   name_array+=("teal");
    value_array+=("255");  name_array+=("white");
    value_array+=("226");  name_array+=("yellow");
    value_array+=("194");  name_array+=("buttermilk");
    value_array+=("144");  name_array+=("wheat");
    value_array+=("97");   name_array+=("lavender");
    value_array+=("133");  name_array+=("rose");

    for ((i=0; i<${#name_array[*]}; i++)); do
        if [[ "$name" == "${name_array[i]}" ]]; then
            break;
        fi
    done

    if (( i == ${#name_array[*]} )); then
        # name not found, use reset
        i=0;
        name="reset";
    fi

    if [[ "$name" == "reset" ]]; then
        layer="";
    fi

    answer="${esc}${layer}${value_array[i]}${bold}${m}";

    echo "$answer";
    return;
}
