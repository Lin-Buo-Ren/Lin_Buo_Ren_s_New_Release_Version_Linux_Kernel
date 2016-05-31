# 專案目錄設定.source.sh - 設定專案各目錄的位置
# 林博仁 <Buo.Ren.Lin@gmail.com> © 2016
set +e

declare -p 2>/dev/null | grep --extended-regexp "^declare.* PROJECT_DIRECTORY_SETTINGS_INITIALIZED(|=.*)$" &>/dev/null
if [ 0 -ne $? ]; then
	set -e
	readonly PROJECT_ROOT_DIRECTORY="$(realpath --strip "$PROGRAM_DIRECTORY/..")"
	readonly PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY="$PROJECT_ROOT_DIRECTORY/第三方軟體/Linux 作業系統核心（穩定版）"
	readonly PROJECT_THIRD_PARTY_PF_KERNEL_PATCH_DIRECTORY="$PROJECT_ROOT_DIRECTORY/第三方軟體/pf-kernel"
	declare -r PROJECT_THIRD_PARTY_KERNEL_GCC_PATCH_DIRECTORY="$PROJECT_ROOT_DIRECTORY/第三方軟體/kernel_gcc_patch"
	readonly PROJECT_LOGS_DIRECTORY="$PROJECT_ROOT_DIRECTORY/運行紀錄檔"
	readonly PROJECT_BUILD_ARTIFACT_DIRECTORY="$PROJECT_ROOT_DIRECTORY/建構產物"
	readonly PROJECT_SETTINGS_DIRECTORY="$PROJECT_ROOT_DIRECTORY/設定"
	
	readonly PROJECT_DIRECTORY_SETTINGS_INITIALIZED
fi
set -e
