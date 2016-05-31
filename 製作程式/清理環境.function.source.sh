# 清理環境.function.source.sh - 回覆原來的狀態
# 林博仁 <Buo.Ren.Lin@gmail.com> © 2016

######## Included files ########
# 專案路徑定義（$PROJECT_*）
source "$PROGRAM_DIRECTORY/專案目錄設定.source.sh"

# 讀取軟體設定
source "$PROJECT_SETTINGS_DIRECTORY/建構作業系統核心.configuration.source.sh"

######## Included files ended ########

set +e
declare -p 2>/dev/null | grep --extended-regexp "^declare.* PROJECT_DIRECTORY_SETTINGS_INITIALIZED(|=.*)$" &>/dev/null
if [ 0 -ne $? ]; then
	set -e
	printf "錯誤：專案目錄設定未初始化！\n" 1>&2
	printf "錯誤：程式無法這樣繼續運行。\n" 1>&2
	sleep 3
	exit 1
fi

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

set +e
declare -pF 2>/dev/null | grep --extended-regexp "^declare.* clean_up$" &>/dev/null
if [ $? -ne 0 ]; then
	set -e
	clean_up() {
		printf "資訊：清理資料中……\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		if [ -d "$workaround_safe_build_directory" ]; then
			printf "試圖卸載建構目錄……\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
			pkexec umount "$workaround_safe_build_directory" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
			rmdir "$workaround_safe_build_directory" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		fi
		
		if [ -f "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/.git" ]; then
			rm -rf "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/build" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
			# reset tracked files
			git --git-dir="$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/.git" reset --hard 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
			# remove untracked files
			git --git-dir="$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/.git" clean --force -d -x 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
			# checkout back to master branch
			git --git-dir="$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/.git" checkout master 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		fi
		return
	}
	declare -fr clean_up
fi
set -e