#!/usr/bin/env bash
# 上列為宣告執行 script 程式用的殼程式(shell)的 shebang
# 初始化開發環境.sh - 設定好要提交本專案程式碼時必須要有的開發環境
# 林博仁 © 2016
# 如題

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
	# 安裝專案專用 Git 設定
	# git - Is it possible to include a file in your .gitconfig - Stack Overflow
	# http://stackoverflow.com/questions/1557183/is-it-possible-to-include-a-file-in-your-gitconfig
	git config --local include.path '../.gitconfig'
	
	## 正常結束 script 程式
	exit 0
}
main
######## Program ended ########