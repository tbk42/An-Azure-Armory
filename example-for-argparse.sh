#!/usr/bin/env bash

source "$(dirname "$(realpath "${BASH_SOURCE:-$0}")")/argparse.sh"

# -----------------------------------------------------------------------------------------------------------


# ----------------------------
# Argument Handler
# ----------------------------
arguments() {

    # Defaults (local to app)
    DELAY="$ARG_DELAY"
    SLEEP="$ARG_SLEEP"
    KILL=true
    PROCS=""

    # Normalize
    mapfile -t NORMALIZED < <(arg_normalize "$@") || return 1

    set -- "${NORMALIZED[@]}"


    # Map to short flags
    local mapped=()

    for arg in "$@"; do
        case "$arg" in

            --background) mapped+=(-b) ;;
            --delay=*)    mapped+=(-d "${arg#*=}") ;;
            --procs=*)    mapped+=(-p "${arg#*=}") ;;
            --sleep=*)    mapped+=(-s "${arg#*=}") ;;
            --kill)       mapped+=(-k) ;;
            --no-kill)    mapped+=(-n) ;;
            --help)       mapped+=(-h) ;;

        esac
    done

    set -- "${mapped[@]}"


    # Parse
    while getopts ":bd:p:s:knh" opt; do
        case "$opt" in

            b) DELAY=-1 ;;
            d) DELAY="$OPTARG" ;;
            p) PROCS="$OPTARG" ;;
            s) SLEEP="$OPTARG" ;;
            k) KILL=true ;;
            n) KILL=false ;;
            h) arg_usage; exit 0 ;;

            :)
                printf "%s\n" "Option -$OPTARG needs value" >&2
                return 1
                ;;

            \?)
                printf "%s\n" "Invalid option -$OPTARG" >&2
                return 1
                ;;
        esac
    done
}


# ----------------------------
# Main
# ----------------------------
main() {

    arguments "$@" || exit 1

    printf "%s\n" "Delay: $DELAY"
    printf "%s\n" "Sleep: $SLEEP"
    printf "%s\n" "Kill:  $KILL"
    printf "%s\n" "Procs: $PROCS"

    # Your real logic here
}

main "$@"
