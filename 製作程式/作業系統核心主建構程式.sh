#!/usr/bin/env bash
# 上列為宣告執行 script 程式用的殼程式(shell)的 shebang
# 作業系統核心主建構程式.sh - 作業系統核心建構程序主程式
# 林博仁 <Buo.Ren.Lin@gmail.com> © 2016
# 一般來說執行這個程式就可以了，這個程式會自動呼叫其他程式建構 Linux 作業系統核心軟體包

######## File scope variable definitions ########
# Defensive Bash Programming - not-overridable primitive definitions
# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
readonly PROGRAM_FILENAME="$(basename "$0")"
readonly PROGRAM_DIRECTORY="$(realpath --strip "$(dirname "$0")")"
readonly PROGRAM_ARGUMENT_ORIGINAL_LIST="$@"
readonly PROGRAM_ARGUMENT_ORIGINAL_NUMBER=$#

# 將未定義的變數視為錯誤
set -u

# 專案路徑定義（$PROJECT_*）
source "$PROGRAM_DIRECTORY/專案目錄設定.source.sh"

# 讀取軟體設定
source "$PROJECT_SETTINGS_DIRECTORY/建構作業系統核心.configuration.source.sh"

# 通用變數宣告
source "$PROGRAM_DIRECTORY/通用變數宣告.source.sh"

######## File scope variable definitions ended ########

######## Included files ########
source "$PROGRAM_DIRECTORY/處理命令列參數.function.source.sh"
source "$PROGRAM_DIRECTORY/清理環境.function.source.sh"
source "$PROGRAM_DIRECTORY/準備基底 Linux 作業系統核心來源碼.function.source.sh"
source "$PROGRAM_DIRECTORY/獲取並套用 Linux 作業系統核心修正.function.source.sh"
source "$PROGRAM_DIRECTORY/建立作業系統核心建構設定並套用建構設定修正.function.source.sh"
source "$PROGRAM_DIRECTORY/建構作業系統核心.function.source.sh"
######## Included files ended ########

######## Program ########
# Defensive Bash Programming - main function, program entry point
# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
main() {
	# -e Exit immediately if a pipeline , which may consist of a single simple command , a list , or a compound command returns a non-zero status.
	set -e
	
	# -E If set, any trap on `ERR' is inherited by shell functions,
	# command substitutions, and commands executed in a subshell
	# environment.  The `ERR' trap is normally not inherited in
	# such cases.
	set -E
	
	# 每當錯誤發生或程式被終止時清理資料
	trap clean_up ERR SIGINT SIGTERM
	
	printf "# 林博仁的新釋出版本 Linux 作業系統核心建構程序 #\n" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	
	process_commandline_arguments
	
	# 預防程式先前被強制終止我們在開始之前多做一次清潔程序
	clean_up
	
	# 將 Linux 作業系統核心來源碼切換到我們要用的版本
	prepare_base_kernel
	
	acquire_and_apply_patch $KERNEL_BRANCH
	
	generate_and_patch_kernel_build_configuration $CPU_ARCHITECTURE $CPU_ARCHITECTURE_COMPATIBILITY "$KERNEL_FEATURE"
	
	build_kernel
	
	clean_up
	
	## 正常結束 script 程式
	exit 0
}
main

######## Program ended ########
