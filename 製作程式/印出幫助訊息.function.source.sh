# 印出幫助訊息.function.source.sh - 印出程式的幫助訊息包含命令列參數與用法
# 林博仁 © 2016

######## Included files ########

# 支援的特色定義 ($SUPPORTED_FEATURE_*)
source "$PROGRAM_DIRECTORY/支援的特色定義.source.sh"

######## Included files ended ########
set +e
declare -pF 2>/dev/null | grep --extended-regexp "^declare.* print_help_message$" &>/dev/null
if [ 0 -ne $? ]; then
	set -e
	print_help_message(){
		printf "## 使用方法 ##\n"
		printf "請先參閱並設定「設定/建構作業系統核心.configuration.source.sh」設定檔\n"
		printf "\n"
		printf "\t$PROGRAM_FILENAME --help\n"
		printf "\t$PROGRAM_FILENAME -h\n"
		printf "\t\t印出幫助訊息\n"
		printf "\n"
		printf "\t$PROGRAM_FILENAME （--kernel-branch 〈Linux 作業系統核心的分支〉） （--cpu-architecture 〈主要的處理器指令集〉） （--cpu-architecture-compatibility 〈相容的（最低）處理器指令集類別〉） （--kernel-feature 〈Linux 作業系統核心啟用或停用的功能〉）\n"
		printf "\t\t建構作業系統核心變種的作業系統核心，如省略之預設將建構自動偵測最佳化核心\n"
		printf "\t\t〈Linux 作業系統核心的分支〉：$SUPPORTED_FEATURE_KERNEL_BRANCH\n"
		printf "\t\t〈主要的處理器指令集〉：$SUPPORTED_FEATURE_CPU_ARCHITECTURE\n"
		printf "\t\t〈相容的（最低）處理器指令集類別〉：$SUPPORTED_FEATURE_CPU_ARCHITECTURE_COMPATIBILITY\n"
		printf "\t\t〈Linux 作業系統核心啟用或停用的功能〉：$SUPPORTED_FEATURE_KERNEL_FEATURE\n"
		printf "\n"
		printf "本程式不需要且不應該以 root 身份執行，但執行途中仍需要詢問密碼以完成部份不能用一般權限完成的工作（特別是 bind mount）。\n"
		return
	}
	declare -fr print_help_message
fi
set -e
