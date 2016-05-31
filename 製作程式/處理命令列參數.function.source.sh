# 處理命令列參數.function.source.sh - 處理本專案所有程式的命令列參數的子程式
# 林博仁 <Buo.Ren.Lin@gmail.com> © 2016

set +e
declare -p 2>/dev/null | grep --extended-regexp "^declare.* PROJECT_DIRECTORY_SETTINGS_INITIALIZED(|=.*)$" &>/dev/null
if [ 0 -ne $? ]; then
	set -e
	printf "錯誤：專案目錄設定未初始化！\n" 1>&2
	printf "錯誤：程式無法這樣繼續運行。\n" 1>&2
	sleep 3
	exit 1
fi
set -e

set +e
declare -p 2>/dev/null | grep --extended-regexp "^declare.* CONFIGURATION_LOADED(|=.*)$" &>/dev/null
if [ 0 -ne $? ]; then
	set -e
	printf "錯誤：軟體設定未載入！\n" 1>&2
	printf "錯誤：程式無法這樣繼續運行。\n" 1>&2
	sleep 3
	exit 1
fi
set -e

# Sourced files #
source "$PROGRAM_DIRECTORY/印出幫助訊息.function.source.sh"
source "$PROGRAM_DIRECTORY/印出關於訊息.function.source.sh"

set +e
declare -pF 2>/dev/null | grep --extended-regexp "^declare.* process_commandline_arguments$" &>/dev/null
if [ 0 -ne $? ]; then
	set -e
	process_commandline_arguments() {
		# Defensive Bash Programming - Command line arguments
		# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
		local arguments="$PROGRAM_ARGUMENT_ORIGINAL_LIST"
		local arguments_translated=""
		
		# 翻譯長版本選項為短版本選項
		for argument in $arguments; do # $arguments 是有意不要被引號括住的，才會被 for 迴圈一一走訪
			local delimiter=""
			local argument_separater=" "
			
			case $argument in
				--help)
					arguments_translated="${arguments_translated}-h${argument_separater}"
				;;
				--about)
					print_about_message
					exit 0
				;;
				--kernel-branch)
					arguments_translated="${arguments_translated}-b${argument_separater}"
				;;
				--cpu-architecture)
					arguments_translated="${arguments_translated}-a${argument_separater}"
				;;
				--cpu-architecture-compatibility)
					arguments_translated="${arguments_translated}-c${argument_separater}"
				;;
				--kernel-feature)
					arguments_translated="${arguments_translated}-f${argument_separater}"
				;;
				# pass anything else
				*)
					# 報錯所有不認識的長選項
					if [ "${argument:0:2}" == "--" ]; then
						printf "錯誤：$argument 命令列選項不存在！\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
						printf "錯誤：請執行「$PROGRAM_FILENAME --help」命令以查詢所有可用的命令列選項。\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
						exit 1
					fi
					
					# 如果參數不是「-」開頭（不是命令列選項）就將 $delimiter 改為「"」，不然的話維持「（空字串）」
					# -e -> ${arguments_translated}-e${argument_separater}
					# et -> ${arguments_translated}"et"${argument_separater}
					[[ "${argument:0:1}" == "-" ]] || delimiter="\""
					arguments_translated="${arguments_translated}${delimiter}${argument}${delimiter}${argument_separater}"
				;;
			esac
		done
		
		#Reset the positional parameters to the short options
		eval set -- $arguments_translated
		
		while getopts "hb:a:c:f:" short_argument; do
			case $short_argument in
				h)
					print_help_message
					exit 0
				;;
				b)
					readonly KERNEL_BRANCH="$OPTARG"
				;;
				a)
					declare -r CPU_ARCHITECTURE="$OPTARG"
				;;
				c)
					declare -r CPU_ARCHITECTURE_COMPATIBILITY="$OPTARG"
				;;
				f)
					declare -r KERNEL_FEATURE="$OPTARG"
				;;
			esac
		done
		
		# 如果參數未設定的話採用預設值
		if [ ! -v KERNEL_BRANCH ]; then
			printf "資訊：作業系統核心分支未設定，採用預設值 ${default_kernel_branch}。\n" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
			readonly KERNEL_BRANCH=$default_kernel_branch
		fi
		if [ ! -v CPU_ARCHITECTURE ]; then
			printf "資訊：主要的處理器指令集未設定，採用預設值 ${default_cpu_architecture}。\n" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
			readonly CPU_ARCHITECTURE=$default_cpu_architecture
		fi
		if [ ! -v CPU_ARCHITECTURE_COMPATIBILITY ]; then
			printf "資訊：相容的（最低）處理器指令集類別未設定，採用預設值 ${default_cpu_architecture_compatibility}。\n" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
			readonly CPU_ARCHITECTURE_COMPATIBILITY=$default_cpu_architecture_compatibility
		fi
		if [ ! -v KERNEL_FEATURE ]; then
			if [ ! -z "$default_kernel_feature" ]; then
				printf "資訊：Linux 作業系統核心啟用或停用的功能未設定，採用預設值 ${default_kernel_feature}。\n" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
			else
				printf "資訊：Linux 作業系統核心啟用或停用的功能未設定，採用預設值。\n" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
			fi
			readonly KERNEL_FEATURE=$default_kernel_feature
		fi
		return
	}
	declare -fr process_commandline_arguments
fi
set -e
