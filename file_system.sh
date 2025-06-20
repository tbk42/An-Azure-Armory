#!/bin/bash
# -----------------------------------------------------------------
# An Azure Armory
# File System Functions
# -----------------------------------------------------------------
# file_check
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# The file_check() function reports back an abriviated code
#   expressing the details about the file. It lists whether the
#   file exists, is a good or bad link, is a directory, pipe,
#   socket, and other types of files.
# 
# Usage: check=$(file_check "filename");
# -----------------------------------------------------------------
function file_check() {
    local file="$1";
    local file_type="";
    [[ -e "$file" ]] && file_type+="e"
    [[ ! -e "$file" ]] && [[ -L "$file" ]] && file_type+="L?"
    if [[ -e "$file" ]] || [[ -L "$file" ]] ; then
        [[ -f "$file" ]] && file_type+="f"
        [[ -d "$file" ]] && file_type+="d"
        [[ -b "$file" ]] && file_type+="b"
        [[ -c "$file" ]] && file_type+="c"
        [[ -p "$file" ]] && file_type+="p"
        [[ -S "$file" ]] && file_type+="S"
        [[ -t "$file" ]] && file_type+="t"
        [[ -L "$file" ]] && file_type+="L"
        [[ -L "$file" ]] && [[ -e "$(readlink "$file")" ]] && file_type+="+"
    fi
    echo "$file_type"
}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# The file_size() function reports back the size of a given file
#   or directory.
# 
# Usage: size=$(file_size "filename");
# -----------------------------------------------------------------
source "$(dirname "$(realpath "${BASH_SOURCE:-$0}")")/math.sh"

function file_size() {
    local filename="$1";
    local size=0;
    if [[ -z "${filename}" ]]; then
        echo "0 bytes"
        return
    fi

    if [[ ! -f "${filename}" ]] && [[ ! -d "${filename}" ]]; then
        echo "0 bytes"
        return
    fi

    size=$(du --bytes "${filename}" | cut -f1)

    echo "$(human_number "${size}")"
    return
}
# -----------------------------------------------------------------
