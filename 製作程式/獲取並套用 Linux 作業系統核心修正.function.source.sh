# 獲取並套用 Linux 作業系統核心修正.function.source.sh - 下載、解開然後套用修正到 Linux 作業系統核心來源碼樹中
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

######## Included files ########
source "$PROGRAM_DIRECTORY/清理環境.function.source.sh"
source "$PROGRAM_DIRECTORY/支援的特色定義.source.sh"
######## Included files ended ########

set +e
declare -pF 2>/dev/null | grep --extended-regexp "^declare.* acquire_and_apply_patch$" &>/dev/null
if [ $? -ne 0 ]; then
	set -E
	acquire_and_apply_patch() {
		if [ $# -lt 1 ]; then
			printf "錯誤：acquire_and_apply_patch()：參數不足！\n"
			exit 1
		fi
		
		# 函式參數 #
		declare -r kernel_branch=$1
		
		git --git-dir="$PROJECT_ROOT_DIRECTORY/.git" --work-tree="$PROJECT_ROOT_DIRECTORY" submodule init 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		printf "資訊：下載 kernel_gcc_patch 修正……\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		git --git-dir="$PROJECT_ROOT_DIRECTORY/.git" --work-tree="$PROJECT_ROOT_DIRECTORY" submodule update --force "$(realpath --strip --relative-to="$PROJECT_ROOT_DIRECTORY" "$PROJECT_THIRD_PARTY_KERNEL_GCC_PATCH_DIRECTORY")" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
		
		case $kernel_branch in
			mainline | vanilla)
				printf "資訊：套用 kernel_gcc_patch 修正……\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
				patch --strip=1 --directory="$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY" <"$PROJECT_THIRD_PARTY_KERNEL_GCC_PATCH_DIRECTORY/enable_additional_cpu_optimizations_for_gcc_v4.9+_kernel_v3.15+.patch" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
			;;
			pf)
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
					elif [ ! -d "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY" ]; then
					printf "錯誤：Linux 作業系統核心來源碼目錄不存在！\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
					printf "錯誤：請確定您有先執行「$(basename "${PROGRAM_DIRECTORY}")/準備基底 Linux 作業系統核心來源碼.sh」。\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
					clean_up
					exit 1
				fi
				patch --strip=1 --directory="$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY" <"$PROJECT_THIRD_PARTY_PF_KERNEL_PATCH_DIRECTORY/$(basename  --suffix=.xz ${pf_kernel_patch_download_url})" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log"
			;;
			*)
				printf "錯誤：不支援此作業系統核心分支！\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
				printf "錯誤：目前所支援的作業系統核心分支為：${SUPPORTED_FEATURE_KERNEL_BRANCH}。\n" | tee --append "$PROJECT_LOGS_DIRECTORY/$PROGRAM_FILENAME.log" 1>&2
			;;
		esac
		return
	}
	declare -fr acquire_and_apply_patch
fi
set -e