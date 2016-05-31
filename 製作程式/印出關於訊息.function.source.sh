# 印出關於訊息.function.source.sh - 印出關於本軟體的訊息
# 林博仁 <Buo.Ren.Lin@gmail.com> © 2016

set +e
declare -pF 2>/dev/null | grep --extended-regexp "^declare.* print_about_message$" &>/dev/null
if [ $? -ne 0 ]; then
	set -e
	print_about_message(){
		printf "## 關於本軟體 ##\n"
		printf "### 作者 ###\n"
		printf "林博仁 <Buo.Ren.Lin@gmail.com>\n"
		printf "\n"
		printf "### 授權條款 ###\n"
		printf "GNU GPLv3\n"
		printf "\n"
		printf "### 官方網站 ###\n"
		printf "https://github.com/Lin-Buo-Ren/Lin_Buo_Ren_s_New_Release_Version_Linux_Kernel\n"
		printf "\n"
		printf "### 議題追蹤系統 ###\n"
		printf "https://github.com/Lin-Buo-Ren/Lin_Buo_Ren_s_New_Release_Version_Linux_Kernel/issues\n"
	}
	declare -rf print_about_message
fi
set -e
