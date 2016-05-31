#!/usr/bin/env bash
# 上列為宣告執行 script 程式用的殼程式(shell)的 shebang
# 準備基底 Linux 作業系統核心來源碼.sh - 取得指定版本的 Linux 作業系統核心來源碼做為基底來源碼
# 林博仁 © 2016

######## File scope variable definitions ########
# Defensive Bash Programming - not-overridable primitive definitions
# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
readonly PROGRAM_FILENAME="$(basename "$0")"
readonly PROGRAM_DIRECTORY="$(realpath --no-symlinks "$(dirname "$0")")"
readonly PROGRAM_ARGUMENT_ORIGINAL_LIST="$@"
readonly PROGRAM_ARGUMENT_ORIGINAL_NUMBER=$#

# 將未定義的變數視為錯誤
set -u

######## File scope variable definitions ended ########

######## Included files ########
source "$PROGRAM_DIRECTORY/專案目錄設定.source.sh"
source "$PROJECT_SETTINGS_DIRECTORY/建構作業系統核心.configuration.source.sh"

source "$PROGRAM_DIRECTORY/準備基底 Linux 作業系統核心來源碼.function.source.sh"

######## Included files ended ########

######## Program ########
# Defensive Bash Programming - main function, program entry point
# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
main() {
	prepare_base_kernel
	## 正常結束 script 程式
	exit 0
}
main
######## Program ended ########