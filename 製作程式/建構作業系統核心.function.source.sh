# 建構作業系統核心.function.source.sh - 只建構作業系統核心
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

######## Included files ########

######## Included files ended ########
set +e
declare -pF 2>/dev/null | grep --extended-regexp "^declare.* build_kernel$" &>/dev/null
if [ $? -ne 0 ]; then
	set -e
	build_kernel(){
		if [ ! -d "$workaround_safe_build_directory" ]; then
			printf "Info: Workarounding GNU Make bug, we'll create a new directory for building kernel.\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
			mkdir --parents "$workaround_safe_build_directory" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		fi
		
		printf "資訊：掛載 Linux 作業系統核心來源碼目錄到建構路徑……\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		pkexec mount --bind "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY" "$workaround_safe_build_directory" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		
		printf "資訊：切換當前工作目錄到安全路徑建構目錄。\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		cd "$workaround_safe_build_directory"
		
		make O=build olddefconfig 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		env DEBFULLNAME="$maintainer_name" DEBEMAIL="$maintainer_email_address" make --jobs=$(nproc) LOCALVERSION=-${maintainer_identifier_used_in_package_name}-${CPU_ARCHITECTURE_COMPATIBILITY} KDEB_PKGVERSION=$(make kernelversion)-${package_release_number} O=build bindeb-pkg  2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		
		# Leave build directory in order to unmount it
		printf "資訊：切換當前工作目錄到專案根目錄。\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		cd "$PROJECT_ROOT_DIRECTORY"
		
		mv "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY"/linux-*.deb "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY"/linux-*.changes "$PROJECT_BUILD_ARTIFACT_DIRECTORY" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		
	}
	declare -fr build_kernel
fi
set -e
