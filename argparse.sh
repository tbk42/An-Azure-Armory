#!/usr/bin/env bash

# ----------------------------
# Defaults (can override)
# ----------------------------
ARG_DELAY=5
ARG_SLEEP=5


# ----------------------------
# Helpers
# ----------------------------
is_value() {
    [[ "$1" =~ ^-?[0-9]+$ ]]
}


# ----------------------------
# Usage Generator
# ----------------------------
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
                if [[ $# -gt 0 ]] && is_value "$1"; then
                    normalized+=(--delay="$1")
                    shift
                else
                    normalized+=(--delay="$ARG_DELAY")
                fi
                ;;

            -d=*|--delay=*)
                normalized+=(--delay="${arg#*=}")
                ;;

            -p|--procs)
                if [[ $# -gt 0 ]] && is_value "$1"; then
                    normalized+=(--procs="$1")
                    shift
                else
                    printf "%s
" ""Missing value for --procs" >&2"
                    return 1
                fi
                ;;

            -p=*|--procs=*)
                normalized+=(--procs="${arg#*=}")
                ;;

            -s|--sleep)
                if [[ $# -gt 0 ]] && is_value "$1"; then
                    normalized+=(--sleep="$1")
                    shift
                else
                    normalized+=(--sleep="$ARG_SLEEP")
                fi
                ;;

            -s=*|--sleep=*)
                normalized+=(--sleep="${arg#*=}")
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
                printf "%s
" ""Unknown option: $arg" >&2"
                return 1
                ;;
        esac
    done

    printf '%s\n' "${normalized[@]}"
}
