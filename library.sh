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
#  - file_size
# 
# +general
#  - error_message
#  - error_report
#  - nap
#  - pause
#  - pause2
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
#  - sec2dhms
# -----------------------------------------------------------------
# Script name, real name, real dir, real path
# 
#   script_local      = "${BASH_SOURCE:-${0}}"            /unified/projects/deploy-manager/the_script.sh
#   script_local_path = "$(dirname  "${script_local}")"   /unified/projects/deploy-manager
#   script_local_name = "$(basename "${script_local}")"   the_script.sh
#   script_real       = "$(realpath "${script_local}")"   /unified/git/tbk42/deploy-manager/deploy-manager.sh
#   script_real_path  = "$(dirname  "${script_real}")"    /unified/git/tbk42/deploy-manager
# > script_real_path  = "$(dirname  "$(realpath "${BASH_SOURCE:-${0}}")")"
#   script_real_name  = "$(basename "${script_real}")"    deploy-manager.sh
# 
# echo -e "script_local: ${script_local}"
# echo -e "script_local_name: ${script_local_name}"
# echo -e "script_local_path: ${script_local_path}"
# echo -e "script_real: ${script_real_full_path}"
# echo -e "script_real_path: ${script_real_path}"
# echo -e "script_real_name: ${script_real_name}"
# 
# > source "${script_real_path}/An-Azure-Armory/color.sh"
#   source "${script_real_path}/color.sh"
#   source "${script_real_path}/cryptography.sh"
#   source "${script_real_path}/file_system.sh"
#   source "${script_real_path}/general.sh"
#   source "${script_real_path}/math.sh"
#   source "${script_real_path}/string.sh"
#   source "${script_real_path}/time.sh"
