#!/usr/bin/env bash
# 上列為宣告執行 script 程式用的殼程式(shell)的 shebang
# 建立作業系統核心建構設定並套用建構設定修正.sh - 從範本建立作業系統核心建構設定並套用建構設定修正.sh
# 林博仁 © 2016

######## File scope variable definitions ########
# Defensive Bash Programming - not-overridable primitive definitions
# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
declare -r PROGRAM_FILENAME="$(basename "$0")"
declare -r PROGRAM_DIRECTORY="$(realpath --no-symlinks "$(dirname "$0")")"
declare -r PROGRAM_ARGUMENT_ORIGINAL_LIST="$@"
declare -r PROGRAM_ARGUMENT_ORIGINAL_NUMBER=$#

## Unofficial Bash Script Mode
## http://redsymbol.net/articles/unofficial-bash-strict-mode/
# 將未定義的變數的參考視為錯誤
set -u

# Exit immediately if a pipeline, which may consist of a single simple command, a list, or a compound command returns a non-zero status.  The shell does not exit if the command that fails is part of the command list immediately following a `while' or `until' keyword, part of the test in an `if' statement, part of any command executed in a `&&' or `||' list except the command following the final `&&' or `||', any command in a pipeline but the last, or if the command's return status is being inverted with `!'.  If a compound command other than a subshell returns a non-zero status because a command failed while `-e' was being ignored, the shell does not exit.  A trap on `ERR', if set, is executed before the shell exits.
set -e

# If set, the return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status, or zero if all commands in the pipeline exit successfully.
set -o pipefail

######## File scope variable definitions ended ########

######## Included files ########
source "$PROGRAM_DIRECTORY/專案目錄設定.source.sh"
source "$PROJECT_SETTINGS_DIRECTORY/建構作業系統核心.configuration.source.sh"
# 通用變數宣告
source "$PROGRAM_DIRECTORY/通用變數宣告.source.sh"

source "$PROGRAM_DIRECTORY/處理命令列參數.function.source.sh"
source "$PROGRAM_DIRECTORY/建立作業系統核心建構設定並套用建構設定修正.function.source.sh"
######## Included files ended ########

######## Program ########
# Defensive Bash Programming - main function, program entry point
# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
main() {
	process_commandline_arguments
	
	generate_and_patch_kernel_build_configuration $CPU_ARCHITECTURE $CPU_ARCHITECTURE_COMPATIBILITY "$KERNEL_FEATURE"
	## 正常結束 script 程式
	exit 0
}
main
######## Program ended ########