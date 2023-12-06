#!/bin/bash
# -----------------------------------------------------------------
# An Azure Armory
# Repository for my bash function Library
# -----------------------------------------------------------------
# +color
#  - color
#  - hex2rgb
#  - rgb2hex
# 
# +cryptography
#  - build_cert_line
#  - build_cert_line2
#  - guess_digest_type
#  - read_x509
# 
# +file system
#  - file_check
# 
# +general
#  - error_message
#  - error_report
#  - nap
#  - pause
# 
# +math
#  - floating_point_division
#  - human_number
#  - isnumeric
# 
# +string
#  - ltrim
#  - repeat
#  - rtrim
#  - space
#  - substring
#  - trim
# 
# +time
#  - elapsed
#  - month2num
# -----------------------------------------------------------------
# Script name, real name, real dir, real path
script_real_path=$(realpath "${BASH_SOURCE:-$0}")
script_real_dir=$(dirname "$script_real_path")
# script_real_name="$(echo "$script_real_path" | rev | cut -d/ -f1 | rev)";
# script_local_name="$(echo "$0" | rev | cut -d/ -f1 | rev)";
source "${script_real_dir}/color.sh"
source "${script_real_dir}/cryptography.sh"
source "${script_real_dir}/file_system.sh"
source "${script_real_dir}/general.sh"
source "${script_real_dir}/math.sh"
source "${script_real_dir}/string.sh"
source "${script_real_dir}/time.sh"
