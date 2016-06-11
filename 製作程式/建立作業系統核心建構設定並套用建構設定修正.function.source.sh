# 建立作業系統核心建構設定並套用建構設定修正.function.source.sh
# 林博仁 <Buo.Ren.Lin@gmail.com> © 2016

set +e
declare -p 2>/dev/null | grep --extended-regexp "^declare.* PROJECT_DIRECTORY_SETTINGS_INITIALIZED(|=.*)$" &>/dev/null
if [ 0 -ne $? ]; then
	printf "錯誤：專案目錄設定未初始化！\n" 1>&2
	printf "錯誤：程式無法這樣繼續運行。\n" 1>&2
	sleep 3
	exit 1
fi

set +e
declare -p 2>/dev/null | grep --extended-regexp "^declare.* CONFIGURATION_LOADED(|=.*)$" &>/dev/null
if [ 0 -ne $? ]; then
	set -e
	printf "錯誤：軟體設定未載入！\n" 1>&2 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
	printf "錯誤：程式無法這樣繼續運行。\n" 1>&2 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
	sleep 3
	exit 1
fi
set -e

set +e
declare -p 2>/dev/null | grep --extended-regexp "^declare.* UNIVERSAL_VARIABLE_DECLARED(|=.*)$" &>/dev/null
if [ $? -ne 0 ]; then
	set -e
	printf "錯誤：通用變數未宣告！\n" 1>&2 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
	printf "錯誤：程式無法這樣繼續運行。\n" 1>&2 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
fi
set -e

source "${PROGRAM_DIRECTORY}/清理環境.function.source.sh"
source "${PROGRAM_DIRECTORY}/支援的特色定義.source.sh"

set +e
declare -pF 2>/dev/null | grep --extended-regexp "^declare.* generate_and_patch_kernel_build_configuration$" &>/dev/null
if [ 0 -ne $? ]; then
	set -e
	generate_and_patch_kernel_build_configuration(){
		if [ $# -ne 3 ]; then
			printf "錯誤：generate_and_patch_kernel_build_configuration：函式參數數目錯誤！\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
			exit 1
		fi
		declare cpu_architecture=$1
		declare cpu_architecture_compatibility=$2
		declare kernel_feature=$3
		
		printf "複製 Linux 作業系統核心建構設定範本……\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		if [ ! -e "$linux_kernel_build_config_template_path" ]; then
			printf "錯誤：Linux 作業系統核心建構設定範本檔案不存在！\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
			printf "請檢查設定檔中 linux_kernel_build_config_template_path 設定值的路徑是否正確！\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
			clean_up
			exit 1
		fi
		
		mkdir --parents "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/build"
		cp "$linux_kernel_build_config_template_path" "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/build/.config" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		
		printf "套用 Linux 作業系統核心建構設定修正……\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		
		# 不建構除錯資料軟體包
		"$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/scripts/config" --file "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/build/.config" --disable "CONFIG_DEBUG_INFO" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		
		case $cpu_architecture_compatibility in
			"generic")
				# 預設值，無事可作
			;;
			"autodetected-optimized")
				"$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/scripts/config" --file "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/build/.config" --disable "CONFIG_GENERIC" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
				"$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/scripts/config" --file "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/build/.config" --enable "CONFIG_MNATIVE" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
			;;
			"intel-haswell-optimized")
				"$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/scripts/config" --file "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/build/.config" --disable "CONFIG_GENERIC" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
				"$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/scripts/config" --file "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/build/.config" --enable "CONFIG_MHASWELL" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
			;;
			"intel-ivybridge-optimized")
				"$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/scripts/config" --file "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/build/.config" --disable "CONFIG_GENERIC" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
				"$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/scripts/config" --file "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/build/.config" --enable "CONFIG_MIVYBRIDGE" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
			;;
			"intel-core2-optimized")
				"$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/scripts/config" --file "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/build/.config" --disable "CONFIG_GENERIC" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
				"$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/scripts/config" --file "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/build/.config" --enable "CONFIG_MCORE2" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
			;;
			"intel-nehalem-optimized")
				"$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/scripts/config" --file "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/build/.config" --disable "CONFIG_GENERIC" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
				"$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/scripts/config" --file "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/build/.config" --enable "CONFIG_MNEHALEM" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
			;;
			*)
				printf "錯誤：相容的（最低）處理器指令集類別不支援！\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
				printf "錯誤：目前相容的處理器指令集類別：${SUPPORTED_FEATURE_CPU_ARCHITECTURE_COMPATIBILITY}。\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
				clean_up
				exit 1
			;;
		esac
	}
	declare -fr generate_and_patch_kernel_build_configuration
fi
set -e