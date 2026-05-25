#!/usr/bin/env bash

# ----------------------------
# Defaults (can override)
# ----------------------------
ARG_DELAY=5
ARG_SLEEP=5


# ----------------------------
# Helpers
# ----------------------------
# -----------------------------------------------------------------
# is_int checks whether the given value is a valid integer
#   (optional leading sign, digits only.)
# 
# Usage: is_int "value"
# Returns: 0 (true) or 1 (false)
# -----------------------------------------------------------------
is_int() {
    [[ "$1" =~ ^-?[0-9]+$ ]]
}


# ----------------------------
# Usage Generator
# ----------------------------
# -----------------------------------------------------------------
# arg_usage prints the standard usage/help message to stdout.
# 
# Usage: arg_usage
# -----------------------------------------------------------------
arg_usage() {

    cat <<EOF
Usage: $0 [options]

Options:
  -b, --background        Run in background
  -d, --delay[=N]         Delay (default: $ARG_DELAY)
  -p, --procs=N           Process refresh
  -s, --sleep[=N]         Sleep time (default: $ARG_SLEEP)
  -k, --kill              Kill old
  -n, --no-kill           Do not kill
  -h, --help              Show help
EOF
}


# ----------------------------
# Normalize
# ----------------------------
# -----------------------------------------------------------------
# arg_normalize converts short-form flags to their long-form
#   equivalents, expanding inline values (--flag=val) and applying
#   defaults where appropriate. Outputs one normalized arg per line.
# 
# Usage: arg_normalize "$@"
# -----------------------------------------------------------------
arg_normalize() {

    local normalized=()

    while [[ $# -gt 0 ]]; do
        local arg="$1"
        shift

        case "$arg" in

            -b|--background)
                normalized+=(--background)
                ;;

            -d|--delay)
                if [[ $# -gt 0 ]] && is_int "$1"; then
                    normalized+=(--delay="$1")
                    shift
                else
                    normalized+=(--delay="$ARG_DELAY")
                fi
                ;;

            -d=*|--delay=*)
                if is_int "${arg#*=}"; then
                    normalized+=(--delay="${arg#*=}")
                else
                    normalized+=(--delay="$ARG_DELAY")
                fi
                ;;

            -p|--procs)
                if [[ $# -gt 0 ]] && is_int "$1"; then
                    normalized+=(--procs="$1")
                    shift
                else
                    printf "%s\n" "Invalid value for --procs" >&2
                    return 1
                fi
                ;;

            -p=*|--procs=*)
                if is_int "${arg#*=}"; then
                    normalized+=(--procs="${arg#*=}")
                else
                    printf "%s\n" "Invalid value for --procs" >&2
                    return 1
                fi
                ;;

            -s|--sleep)
                if [[ $# -gt 0 ]] && is_int "$1"; then
                    normalized+=(--sleep="$1")
                    shift
                else
                    normalized+=(--sleep="$ARG_SLEEP")
                fi
                ;;

            -s=*|--sleep=*)
                if is_int "${arg#*=}"; then
                    normalized+=(--sleep="${arg#*=}")
                else
                    normalized+=(--sleep="$ARG_SLEEP")
                fi
                ;;

            -k|--kill|--killold|--kill-old)
                normalized+=(--kill)
                ;;

            -n|--nokill|--no-kill)
                normalized+=(--no-kill)
                ;;

            -h|--help)
                normalized+=(--help)
                ;;

            *)
                printf "%s\n" "Unknown option: $arg" >&2
                return 1
                ;;
        esac
    done

    printf '%s\n' "${normalized[@]}"
}
