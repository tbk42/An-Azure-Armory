#!/bin/bash
# -----------------------------------------------------------------
# An Azure Armory
# General Functions
# -----------------------------------------------------------------
# error_message
# error_report
# nap
# pause
# controls_advanced
# -----------------------------------------------------------------

source "$(dirname "$(realpath "${BASH_SOURCE:-$0}")")/color.sh" # For color function
source "$(dirname "$(realpath "${BASH_SOURCE:-$0}")")/math.sh" # For isnumeric
source "$(dirname "$(realpath "${BASH_SOURCE:-$0}")")/string.sh" # For repeat function

# -----------------------------------------------------------------
# Function: array_find_indices
# Description: Searches an array for a specific element and prints the indices of all matches.
# Arguments:
#   $1: The name of the array to search (passed as a string).
#   $2: The element (string) to search for.
# Returns:
#   Status Code (Exit): Always 0.
#   Standard Output: A newline-separated list of all matching indices (0-based).
#
# Usage for Existence Check:
#   indices=$(array_find_indices my_array "banana")
#   if [[ -n "$indices" ]]; then ... # Item exists
# -----------------------------------------------------------------
array_find_indices() {
    # Check for required arguments
    if [[ $# -ne 2 ]]; then
        printf "%s\n" "Error: array_find_indices requires exactly 2 arguments (array_name, search_element)" >&2
        return 0 # Still exit 0, but print error to stderr
    fi

    local array_name="$1"
    local search_element="$2"
    local found_indices=""
    local i=0  # Initialize index counter
    local -n arr_ref="$array_name"

    # Iterate via nameref for safe access
    for element in "${arr_ref[@]}"; do
        
        # Check for an exact match, crucial for handling elements with spaces
        if [[ "$element" == "$search_element" ]]; then
            # Append the current index followed by a space character
            found_indices+="\"${i}\" "
        fi
        
        i=$((i + 1))
    done

    # Print the space-separated list of indices if any were found
    if [[ -n "$found_indices" ]]; then
        printf "%b" "$found_indices"
    fi

    return 0 # Always return 0 (success) as the result is in the output string
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# The controls() function provides a flexible user input prompt.
# It displays a prompt, a list of valid characters, and can
# handle timeouts. The user's input is returned in the global
# variable 'outside_storage'.
#
# Arguments are parsed by type:
#   - Strings are concatenated into the prompt.
#   - Single letters are added to the list of valid inputs.
#   - An integer sets the timeout (positive for countdown,
#     negative for count-up, 0 for no timeout).
#   - 'q' is always a valid input for quitting.
#
# Usage: controls ["Prompt string"] [valid_letters...] [timeout]
# -----------------------------------------------------------------
controls() {
    # --- Argument Parsing ---
    local prompt_string=""
    local -a valid_letters=()
    local timeout=0 # Default: no timeout
    local arg

    for arg in "$@"; do
        if [[ "$(isnumeric "$arg")" == "true" ]]; then
            timeout=$arg
        elif [[ "$arg" =~ ^[a-zA-Z]$ ]]; then
            valid_letters+=("$arg")
        else
            prompt_string+="$arg "
        fi
    done
    # Trim trailing space from prompt
    prompt_string="${prompt_string% }"

    # --- Setup ---
    # 'q' is always a valid choice for quitting.
    valid_letters+=("q")
    # Remove duplicates
    read -r -a valid_letters <<< "$(printf "%s\n" "${valid_letters[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"

    # Build the display string for valid letters (e.g., [a/b/c/q])
    local letter_display
    letter_display=$(printf "/%s" "${valid_letters[@]}")
    letter_display="[${letter_display:1}]"

    # --- Display Prompt ---
    printf "%b" "${prompt_string} ${letter_display} "

    # --- Input Loop ---
    local storage=""
    local d=0
    local counter_active="false"
    local step=0

    if (( timeout > 0 )); then
        d=$timeout; step=-1; counter_active="true"
    elif (( timeout < 0 )); then
        d=0; step=1; counter_active="true"
    fi

    while true; do
        local counter_text=""
        if [[ "$counter_active" == "true" ]]; then
            counter_text="${d}s"
            printf "%b" "$(color Grey54)${counter_text}$(color reset)"
        fi

        # Wait for input. Use -t 1 for a 1-second timeout if a counter is active.
        if [[ "$counter_active" == "true" ]]; then
            read -rs -n 1 -t 1 storage
        else
            read -rs -n 1 storage
        fi

        # Erase counter if it was displayed
        if [[ "$counter_active" == "true" ]]; then
            printf "%b" "$(repeat "${#counter_text}" "\b \b")"
        fi

        # Validate input
        local is_valid="false"
        if [[ -n "$storage" ]]; then
            for letter in "${valid_letters[@]}"; do
                if [[ "$storage" == "$letter" ]]; then
                    is_valid="true"
                    break
                fi
            done
        fi

        if [[ "$is_valid" == "true" ]]; then
            break # Exit loop on valid input
        fi

        # Handle timeout logic
        if [[ "$counter_active" == "true" ]]; then
            d=$((d + step))
            if (( timeout > 0 && d < 0 )); then storage=""; break; fi # Countdown finished
        fi
    done

    # --- Finalization ---
    printf "%s\n" "" # Newline for clean output
    # shellcheck disable=SC2034
    outside_storage="${storage}"
}

# -----------------------------------------------------------------
# The error_message() subroutine standardizes the error message
#   readout while providing an easy way to notify the user of an
#   error before exiting.
# 
# Usage: error_message "#" "message";
# -----------------------------------------------------------------
error_message() {
    local error_num="$1";
    shift
    local error_string="$*";

    # shellcheck disable=SC2154
    printf "%b\n" "${color_bad}Error ${error_num}${color_reset}: ${error_string}";
    usage;
    exit "$(printf "%s\n" "$error_num" | cut -d. -f1)"
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# The error_report() subroutine provides a stack trace type readout 
#   enumerating the steps and functions involved in the error
#   along with line numbers to make trouble shooting easier.
# 
# Usage: error_report;
# -----------------------------------------------------------------
error_report() {
    printf "%b\n" "Error in script: ${BASH_SOURCE[0]}"
    printf "%b\n" "Error on line: ${BASH_LINENO[0]} in function ${FUNCNAME[1]}()"
    # printf "%b\n" "This is line: ${color_red}${LINENO}${color_reset} in: ${color_green}${FUNCNAME[0]}()${color_reset}";
    printf "%b\n" "Stack Trace:"
    for i in ${!BASH_LINENO[*]}; do
        if [[ "$i" == "0" ]]; then
            false;
        elif [[ "${BASH_LINENO[i]}" == "0" ]]; then
            false;
        else
            printf "%b\n" "  ${FUNCNAME[i]}() was called from line: ${BASH_LINENO[i]}";
        fi
    done
    printf "%s\n" "";
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# The nap() subroutine is a little pause of X seconds, but unlike
#   sleep, this has a countdown.
# 
# Usage: nap "10"
# -----------------------------------------------------------------
nap() {
    local delay="1"
    local i=0;

    if [[ -n "$1" ]]; then
        delay="$1"
    fi

    # Echo this message first
    printf "%s\n" "Pausing to allow time to stop the script.";
    printf "%s\n" "(press ctrl-c to stop)";

    for ((i=delay; i>0; i=$((i - 1)) )); do
        printf "%s" "$i... "
        sleep 1
    done
    printf "%s\n" "";

    # echo a blank line after the countdown
    printf "%s\n" "";
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# The pause() subroutine waits for any input from the user before
#   proceeding with an optional timeout.
	# shellcheck disable=SC2086
	# shellcheck disable=SC2034
	# shellcheck disable=SC2229
# 
# Usage: pause ["30"]
# -----------------------------------------------------------------
pause() {
    local timeout="";
    if [[ -n "$1" ]]; then
		timeout="-t $1";
    fi
    read -rs -n 1 ${timeout} -p "(press any key to continue)";
    printf "%s\n" "";
    return;
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# Enhanced pause with optional timeout and optional prompt text.
# If a timeout is requested, a countdown timer runs next to the
# optional prompt. And to clean it all out, an optional --clear
# parameter will instruct pause2 to clear out the prompt before
# finishing. Order of parameters doesn't matter.
# 
# usage: pause2 ["30"] ["Press any key to continue..."] [--clear]
# -----------------------------------------------------------------
pause2() {
    local prompt_clear=""
    local count_clear=""
    local length=0
    local storage=""
    local d=0
    local delay="0"
    local prompt=""
    local default_prompt="Press any key to continue... "

    for ((i=1; i-1<$#; i++)); do
        case "${*:i:1}" in
            [0-9][0-9][0-9][0-9]|[0-9][0-9][0-9]|[0-9][0-9]|[0-9]) delay="${*:i:1}";;
            "--clear") prompt_clear="true";;
            *) prompt+="${*:i:1} ";;
        esac
    done

    if [[ -z "${prompt}" ]]; then prompt="${default_prompt}"; fi
    if [[ -n "${prompt_clear}" ]]; then
        prompt_clear=""
        for ((l=0; l<${#prompt}; l++)); do
            prompt_clear+="\b \b"
        done
    fi
    printf "%b" "${prompt}"

    if (( delay > 0 )); then
        for ((d=delay; d>0; d=$(( d - 1 )) )); do
            printf "%b" "${d}... "
            read -p "" -rs -n 1 -t 1 "storage"

            length=$(( ${#d} + 4 ))
            count_clear=""
            for ((l=0; l<length; l++)); do
                count_clear+="\b \b"
            done
            printf "%b" "${count_clear}"

            case "${storage}" in
                "") ;;
                *) break; ;;
            esac
        done
    else
        read -rsn 1
    fi

    if [[ -n "${prompt_clear}" ]]; then
        printf "%b" "${prompt_clear}"
    elif [[ -n "${prompt}" ]]; then
        printf "%b\n" ""
    fi

    return
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# The prompt_user() function provides a powerful and flexible
# user input prompt, combining features for identified lists and
# autocomplete suggestions.
#
# The function's mode is determined automatically based on the arguments provided:
#
# --- Identified Mode ---
# Triggered by providing `--valid-inputs` or `--min`/`--max`.
# The user selects an item by typing an identifier (e.g., a number or letter)
# and pressing Enter.
#
# Usage: prompt_user --prompt "Select a number: " --min 1 --max 3
#
# --- Autocomplete Mode ---
# Triggered by providing `--choices`.
# The user types the beginning of a word from a list. The selection is
# automatically confirmed once the typed prefix uniquely identifies an item.
#
# Usage: prompt_user --prompt "Enter machine: " --choices "cobalt" "ghostwhite"
#
# Returns:
#   The user's selection is returned in the global variable 'outside_storage'.
#   It also returns 'q' or 'b' if the user quits or goes back.
# -----------------------------------------------------------------
prompt_user() {
    # --- Defaults and Local Variables ---
    local mode=""
    local prompt_text="Enter selection: "
    local -a choices=()
    local -a valid_inputs=()
    local min_val=""
    local max_val=""
    local case_sensitive="false"
    local err_msg=""

    # --- Global Return Variable ---
    outside_storage=""

    # --- Argument Parsing ---
    while (( "$#" )); do
        case "$1" in
            --prompt)
                prompt_text="$2"
                shift 2 ;;
            --min)
                min_val="$2"
                shift 2 ;;
            --max)
                max_val="$2"
                shift 2 ;;
            --case-sensitive)
                case_sensitive="true"
                shift ;;
            --choices)
                shift
                while (( "$#" )) && ! [[ "$1" =~ ^-- ]]; do
                    choices+=("$1")
                    shift
                done ;;
            --valid-inputs)
                shift
                while (( "$#" )) && ! [[ "$1" =~ ^-- ]]; do
                    valid_inputs+=("$1")
                    shift
                done ;;
            *)  err_msg="Unknown option: $1"
                shift ;;
        esac
    done

    # --- Unify numeric range into valid_inputs list ---
    if [[ -n "$min_val" ]] && [[ -n "$max_val" ]]; then
        # Check for conflicting parameters
        if (( ${#valid_inputs[@]} > 0 )); then
            err_msg="Conflicting parameters: Cannot use --valid-inputs with --min/--max."
        else
            # Generate the list of numbers
            for i in $(seq "$min_val" "$max_val"); do
                valid_inputs+=("$i")
            done
        fi
    fi

    # --- Mode Detection & Validation ---
    if [[ -n "$err_msg" ]]; then
        printf "%b\n" "$(color Red1)Error: ${err_msg}$(color reset)" >&2
        return 1
    fi

    local autocomplete_params=0
    local identified_params=0
    if (( ${#choices[@]} > 0 )); then
        autocomplete_params=1
    fi
    if (( ${#valid_inputs[@]} > 0 )); then
        identified_params=1
    fi

    if (( autocomplete_params > 0 && identified_params == 0 )); then
        mode="autocomplete"
    elif (( identified_params > 0 && autocomplete_params == 0 )); then
        mode="identified"
    else
        err_msg="Incorrect parameter usage. Use --choices for autocomplete mode OR --valid-inputs or --min/--max for identified mode."
    fi

    if [[ -n "$err_msg" ]]; then
        printf "%b\n" "$(color Red1)Error: ${err_msg}$(color reset)" >&2
        return 1
    fi

    # --- Display Prompt ---
    printf "%b" "${prompt_text}"

    # --- Mode Dispatch ---
    case "$mode" in
        identified) _prompt_identified_mode ;;
        autocomplete) _prompt_autocomplete_mode ;;
        *)  printf "%b\n" "$(color Red1)Error: Invalid mode '${mode}'.$(color reset)" >&2
            return 1 ;;
    esac

    # --- Finalization ---
    # printf "%s\n" "" # Ensure cursor is on a new line
    return 0
}

_prompt_identified_mode() {
    local current_input=""
    local input_char
    local is_valid_prefix

    while true; do
        read -rs -n 1 "input_char"
        case "${input_char}" in
            $'\e') read -rsn 2 -t 0.01 # discard the input and next 2 characters
                   continue ;;
            $'\n'|"") : # Enter key
                local is_valid="false" 
                for valid_item in "${valid_inputs[@]}"; do
                    if [[ "${current_input}" == "${valid_item}" ]]; then
                        is_valid="true"
                        break
                    fi
                done

                if [[ "${is_valid}" == "true" ]]; then
                    outside_storage="${current_input}"
                    break
                else
                    local invalid_message=""
                    invalid_message="$(color Red1) Invalid$(color reset)"
                    printf "%b" "${invalid_message}"
                    sleep 1
                    printf "%b" "$(repeat "${#invalid_message}" "\b \b")"
                    printf "%b" "$(repeat "${#current_input}" "\b \b")"
                    current_input=""
                fi ;;
            $'\x7f'|'\b') : # Backspace
                if [[ -n "${current_input}" ]]; then
                    current_input="${current_input%?}";
                    printf "%b" "\b \b"
                fi ;;
            q|b) if [[ -z "${current_input}" ]]; then
                    outside_storage="${input_char}"
                    break
                 fi
                 ;& # Fallthrough to default if not the first character
            *)  local potential_input="${current_input}${input_char}"
                local is_valid_prefix="false"

                # For a list of valid inputs, check if it's a prefix of any valid item.
                for valid_item in "${valid_inputs[@]}"; do
                    if [[ "${valid_item}" == "${potential_input}"* ]]; then
                        is_valid_prefix="true"
                        break
                    fi
                done

                if [[ "${is_valid_prefix}" == "true" ]]; then
                    current_input="${potential_input}"
                    printf "%b" "$(color Green3)${input_char}$(color reset)"
                else
                    # Flash red and erase the invalid character
                    printf "%b" "$(color Red1)${input_char}$(color reset)"
                    sleep 0.75
                    printf "%b" "\b \b"
                fi ;;
        esac
    done
}

_prompt_autocomplete_mode() {
    local current_input=""
    local input_char
    local -a matches=()
    local item_to_check
    local current_input_to_check
    local completion=""

    while true; do
        read -rs -n 1 "input_char"
        case "${input_char}" in
            $'\e') read -rsn 2 -t 0.01 # discard the input and next 2 characters
                   continue ;;
            $'\n'|"") : # Enter key
                if (( ${#matches[@]} == 1 )); then
                    outside_storage="${matches[0]}"
                    break
                fi ;;
            $'\x7f'|'\b') : # Backspace
                if [[ -n "${completion}" ]]; then
                     printf "%b" "$(repeat "$(( ${#completion} ))" " ")"
                     printf "%b" "$(repeat "$(( ${#completion} ))" "\b")"
                fi
                if [[ -n "${current_input}" ]]; then
                    current_input="${current_input%?}"
                    printf "%b" "\b \b"
                fi ;;
            q|b) if [[ -z "${current_input}" ]]; then
                    outside_storage="${input_char}"; break
                 fi
                 ;& # Fallthrough to default if not the first character
            *)  current_input+="${input_char}"
                matches=()
                item_to_check=""
                current_input_to_check=""
                for item in "${choices[@]}"; do
                    if [[ "$case_sensitive" == "true" ]]; then
                        item_to_check="${item}"
                        current_input_to_check="${current_input}"
                    else
                        item_to_check="${item,,}"
                        current_input_to_check="${current_input,,}"
                    fi

                    if [[ "${item_to_check}" == "${current_input_to_check}"* ]]; then
                        matches+=("$item")
                    fi
                done

                if [[ -n "${completion}" ]]; then
                     printf "%b" "$(repeat "$(( ${#completion} ))" " ")"
                     printf "%b" "$(repeat "$(( ${#completion} ))" "\b")"
                fi

                if (( ${#matches[@]} > 1 )); then
                    completion="${matches[0]#"${current_input}"}"
                    printf "%b" "$(color Green3)${input_char}$(color reset)"
                    printf "%b" "$(color Grey54)${completion}$(color reset)"
                    printf "%b" "$(repeat "${#completion}" "\b")"
                    # shellcheck disable=SC2034
                    outside_storage="${matches[0]}"
                    # break
                elif (( ${#matches[@]} == 1 )); then
                    completion="${matches[0]#"${current_input}"}"
                    printf "%b" "$(color Green3)${input_char}$(color reset)"
                    printf "%b" "$(color Green3)${completion}$(color reset)"
                    printf "%b" "$(repeat "${#completion}" "\b")"
                    # shellcheck disable=SC2034
                    outside_storage="${matches[0]}"
                    break
                elif (( ${#matches[@]} == 0 )); then
                    printf "%b" "$(repeat "$(( ${#current_input} - 1 ))" "\b")"
                    printf "%b" "$(color DarkRed1)${current_input:0:${#current_input}-1}$(color reset)"
                    printf "%b" "$(color Red1)${input_char}$(color reset)"
                    sleep 0.75
                    printf "%b" "$(repeat "$(( ${#input_char} ))" "\b \b")"
                    sleep 0.50
                    printf "%b" "$(repeat "$(( ${#current_input} - 1 ))" "\b \b")"
                    current_input=""
                fi ;;
        esac
    done
}
