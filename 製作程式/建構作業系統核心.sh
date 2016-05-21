#!/usr/bin/env bash
# 上列為宣告執行 script 程式用的殼程式(shell)的 shebang
# 建構作業系統核心 - 作業系統核心建構程序
# 林博仁 <Buo.Ren.Lin@gmail.com> © 2016

######## Included files ########

######## Included files ended ########

######## File scope variable definitions ########
# Defensive Bash Programming - not-overridable primitive definitions
# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
readonly PROGRAM_FILENAME="$(basename "$0")"
readonly PROGRAM_DIRECTORY="$(realpath --strip "$(dirname "$0")")"
readonly PROGRAM_ARGUMENT_ORIGINAL_LIST="$@"
readonly PROGRAM_ARGUMENT_ORIGINAL_NUMBER=$#

# 將未定義的變數視為錯誤
set -u

# 專案路徑定義（$PROJECT_*）
source "$PROGRAM_DIRECTORY/專案目錄設定.source.sh"

# 讀取軟體設定
source "$PROJECT_SETTINGS_DIRECTORY/建構作業系統核心.configuration.source.sh"

######## File scope variable definitions ended ########

######## Program ########
print_help_message(){
	printf "## 使用方法 ##\n"
	printf "請先參閱並設定「設定/建構作業系統核心.configuration.source.sh」設定檔\n"
	printf "\n"
	printf "\t$PROGRAM_FILENAME （--branch 〈Linux 作業系統核心的分支〉） （--architecture 〈相容的（最低）處理器指令集類別〉） （--feature 〈Linux 作業系統核心啟用或停用的功能〉）\n"
	printf "\t\t建構作業系統核心變種的作業系統核心，如省略之預設將建構自動偵測最佳化核心\n"
	printf "\t$PROGRAM_FILENAME --help\n"
	printf "\t$PROGRAM_FILENAME -h\n"
	printf "\t\t印出幫助訊息\n"
	printf "\n"
	printf "本程式不需要且不應該以 root 身份執行，但執行途中仍需要詢問密碼以完成部份不能用一般權限完成的工作（特別是 bind mount）。\n"
	return
}

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

prepare_base_kernel(){
	printf "資訊：切換當前工作目錄到 Linux 作業系統核心來源碼目錄。\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	cd "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY"
	git fetch --depth=1 origin "refs/tags/v${stable_kernel_version_to_checkout}:refs/tags/v${stable_kernel_version_to_checkout}" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	git checkout v${stable_kernel_version_to_checkout} 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	
}

clean_up() {
	printf "資訊：清理資料中……\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	if [ -d "$workaround_safe_build_directory" ]; then
		printf "試圖卸載建構目錄……\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		pkexec umount "$workaround_safe_build_directory" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		rmdir "$workaround_safe_build_directory" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	fi
	
	if [ -f "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/.git" ]; then
		printf "資訊：切換當前工作目錄到 Linux 作業系統核心來源碼目錄。\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		cd "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY"
		rm -rf build 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		# reset tracked files
		git reset --hard 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		# remove untracked files
		git clean --force -d -x 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		# checkout back to master branch
		git checkout master 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	fi
	return
}

process_commandline_arguments() {
	# Defensive Bash Programming - Command line arguments
	# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
	local arguments="$PROGRAM_ARGUMENT_ORIGINAL_LIST"
	
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
	
	while getopts "h" short_argument; do
		case $short_argument in
			h)
				print_help_message
				exit 0
			;;
		esac
	done
	return
}

# Defensive Bash Programming - main function, program entry point
# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
main() {
	# -e Exit immediately if a pipeline , which may consist of a single simple command , a list , or a compound command returns a non-zero status.
	set -e
	
	# -E If set, any trap on `ERR' is inherited by shell functions,
	# command substitutions, and commands executed in a subshell
	# environment.  The `ERR' trap is normally not inherited in
	# such cases.
	set -E
	
	# 每當錯誤發生或程式被終止時清理資料
	trap clean_up ERR SIGINT SIGTERM
	
	printf "# 林博仁的新釋出版本 Linux 作業系統核心建構程序 #\n" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	
	process_commandline_arguments
	
	# 預防程式先前被強制終止我們在開始之前多做一次清潔程序
	clean_up
	
	# 更新 Git 子模組
	git submodule init
	git submodule update --force --depth 1
	
	# 將 Linux 作業系統核心來源碼切換到我們要用的版本
	prepare_base_kernel
	
	printf "下載 pf-kernel 修正……\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	wget --no-clobber --directory-prefix="$PROJECT_THIRD_PARTY_PF_KERNEL_PATCH_DIRECTORY" ${pf_kernel_patch_download_url} ${pf_kernel_patch_download_url}.sig 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	if [ $? -ne 0 ]; then
		printf "錯誤：pf-kernel 修正下載失敗！\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
		printf "請檢查設定檔中 pf_kernel_patch_download_url 設定值的路徑是否正確！\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
		clean_up
		exit 1
	fi
	
	# 驗證資料完整性
	readonly pf_kernel_patch_filename=$(basename ${pf_kernel_patch_download_url})
	
	#gpg --verify "$PROJECT_THIRD_PARTY_PF_KERNEL_PATCH_DIRECTORY/$pf_kernel_patch_filename.sig"
	
	xz --decompress --keep "$PROJECT_THIRD_PARTY_PF_KERNEL_PATCH_DIRECTORY/$(basename ${pf_kernel_patch_download_url})" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" || true
	
	printf "套用 pf-kernel 修正……\n" | tee "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	if [ ! -e "$PROJECT_THIRD_PARTY_PF_KERNEL_PATCH_DIRECTORY/$(basename --suffix=.xz ${pf_kernel_patch_download_url})" ]; then
		printf "錯誤： pf-kernel 修正檔案不存在！\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
		clean_up
		exit 1
	fi
	patch --strip=1 --directory="$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY" <"$PROJECT_THIRD_PARTY_PF_KERNEL_PATCH_DIRECTORY/$(basename  --suffix=.xz ${pf_kernel_patch_download_url})" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	
	printf "複製 Linux 作業系統核心建構設定範本……\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	if [ ! -e "$linux_kernel_build_config_template_path" ]; then
		printf "錯誤：Linux 作業系統核心建構設定範本檔案不存在！\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
		printf "請檢查設定檔中 linux_kernel_build_config_template_path 設定值的路徑是否正確！\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
		clean_up
		exit 1
	fi
	
	mkdir --parents "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/build"
	cp "$linux_kernel_build_config_template_path" "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/build/.config" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	
	# 決定要建構的作業系統核心變種
	if [ $PROGRAM_ARGUMENT_ORIGINAL_NUMBER -eq 0 ]; then
		kernel_variant="autodetected-optimized"
	else
		kernel_variant="$PROGRAM_ARGUMENT_ORIGINAL_LIST"
	fi
	
	printf "套用 Linux 作業系統核心建構設定修正……\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	"$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/scripts/config" --file "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/build/.config" --disable "CONFIG_DEBUG_INFO" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	
	case $kernel_variant in
		"generic")
			# 無事可作
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
			printf "錯誤：作業系統核心變種無法辨識！\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
			clean_up
			exit 1
		;;
	esac
	
	if [ ! -d "$workaround_safe_build_directory" ]; then
		printf "Workarounding GNU Make bug, we'll create a new directory for building kernel.\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
		mkdir --parents "$workaround_safe_build_directory" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	fi
	
	printf "掛載 Linux 作業系統核心來源碼目錄到建構路徑……\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	pkexec mount --bind "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY" "$workaround_safe_build_directory" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	
	printf "資訊：切換當前工作目錄到安全路徑建構目錄。\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	cd "$workaround_safe_build_directory"
	
	make O=build olddefconfig 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	env DEBFULLNAME="$maintainer_name" DEBEMAIL="$maintainer_email_address" make --jobs=$(nproc) LOCALVERSION=-${maintainer_identifier_used_in_package_name}-${kernel_variant} KDEB_PKGVERSION=$(make kernelversion)-${package_release_number} O=build bindeb-pkg  2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	
	# Leave build directory in order to unmount it
	printf "資訊：切換當前工作目錄到專案根目錄。\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	cd "$PROJECT_ROOT_DIRECTORY"
	
	mv "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY"/linux-*.deb "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY"/linux-*.changes "$PROJECT_BUILD_ARTIFACT_DIRECTORY" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
	
	clean_up
	
	## 正常結束 script 程式
	exit 0
}
main

######## Program ended ########
