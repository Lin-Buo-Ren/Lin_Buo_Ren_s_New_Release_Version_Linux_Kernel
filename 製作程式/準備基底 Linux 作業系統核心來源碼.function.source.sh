# 準備基底 Linux 作業系統核心來源碼.function.source.sh - 下載指定版本的 Linux 作業系統核心來源碼
# 林博仁 <Buo.Ren.Lin@gmail.com> © 2016

######## Included files ########

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

set +e
declare -pF 2>/dev/null | grep --extended-regexp "^declare.* prepare_base_kernel$" &>/dev/null
if [ 0 -ne $? ]; then
	set -e
	prepare_base_kernel(){
		# 更新 Git 子模組
		git --git-dir="$PROJECT_ROOT_DIRECTORY/.git" --work-tree="$PROJECT_ROOT_DIRECTORY" submodule init
		git --git-dir="$PROJECT_ROOT_DIRECTORY/.git" --work-tree="$PROJECT_ROOT_DIRECTORY" submodule update --force --depth 1 "$(realpath --relative-to="$PROJECT_ROOT_DIRECTORY" --strip "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY")"
		
		git --git-dir="$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/.git" --work-tree="$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY" fetch --depth=1 origin "refs/tags/v${stable_kernel_version_to_checkout}:refs/tags/v${stable_kernel_version_to_checkout}" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		git --git-dir="$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/.git" --work-tree="$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY" checkout v${stable_kernel_version_to_checkout} 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	}
	declare -fr prepare_base_kernel
fi
set -e
