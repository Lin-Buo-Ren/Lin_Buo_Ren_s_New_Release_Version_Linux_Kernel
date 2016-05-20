#!/usr/bin/env bash
# 上列為宣告執行 script 程式用的殼程式(shell)的 shebang
# precommit.sh - 提交版本前檢查程式
# 林博仁 <Buo.Ren.Lin@gmail.com> © 2016
# 這個程式會在提交版本前自動執行並檢查所有 bash script 的語法正確性

######## Included files ########

######## Included files ended ########

######## File scope variable definitions ########
# Defensive Bash Programming - not-overridable primitive definitions
# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
readonly PROGRAM_FILENAME="$(basename "$0")"
readonly PROGRAM_DIRECTORY="$(realpath --no-symlinks "$(dirname "$0")")"
readonly PROGRAM_ARGUMENT_ORIGINAL_LIST="$@"
readonly PROGRAM_ARGUMENT_ORIGINAL_NUMBER=$#

######## File scope variable definitions ended ########

######## Program ########
# Defensive Bash Programming - main function, program entry point
# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
main() {
	printf "專案提交版本前掛勾程式：檢查 shell script 語法……\n"
	find . -path './第三方軟體/Linux 作業系統核心（穩定版）' -prune -o -path './.git/*' -prune -o -name "*.sh" -print0 | xargs --null --max-args=1 bash -n
	if [ $? -ne 0 ]; then
		exit 1
	else
		printf "專案提交版本前掛勾程式：語法檢查完畢。\n"
	fi
	
	## 正常結束 script 程式
	exit 0
}
main
######## Program ended ########