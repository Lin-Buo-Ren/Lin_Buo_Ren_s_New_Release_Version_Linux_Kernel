#!/usr/bin/env bash
# 上列為宣告執行 script 程式用的殼程式(shell)的 shebang
# 〈程式檔名〉 - 〈程式描述文字（一言以蔽之）〉
# 〈程式智慧財產權擁有者名諱、地址（選用）〉 © 〈智慧財產權生效年〉
# 〈更多程式描述文字〉

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

# 專案路徑定義（$PROJECT_*）
source "$PROGRAM_DIRECTORY/專案目錄設定.source.sh"

# 讀取軟體設定
source "$PROJECT_SETTINGS_DIRECTORY/建構作業系統核心.configuration.source.sh"

# 通用變數宣告
source "$PROGRAM_DIRECTORY/通用變數宣告.source.sh"

######## File scope variable definitions ended ########

######## Included files ########
source "$PROGRAM_DIRECTORY/處理命令列參數.function.source.sh"
source "$PROGRAM_DIRECTORY/建構作業系統核心.function.source.sh"
######## Included files ended ########

######## Program ########
# Defensive Bash Programming - main function, program entry point
# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
main() {
	process_commandline_arguments
	
	build_kernel
	## 正常結束 script 程式
	exit 0
}
main
######## Program ended ########