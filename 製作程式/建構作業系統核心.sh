#!/bin/bash
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

readonly PROJECT_ROOT_DIRECTORY="$(realpath --strip "$PROGRAM_DIRECTORY/..")"
readonly PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY="$PROJECT_ROOT_DIRECTORY/第三方軟體/Linux 作業系統核心（穩定版）"
readonly PROJECT_THIRD_PARTY_PF_KERNEL_PATCH_DIRECTORY="$PROJECT_ROOT_DIRECTORY/第三方軟體/pf-kernel"
readonly PROJECT_LOGS_DIRECTORY="$PROJECT_ROOT_DIRECTORY/運行紀錄檔"
readonly PROJECT_BUILD_ARTIFACT_DIRECTORY="$PROJECT_ROOT_DIRECTORY/建構產物"
readonly PROJECT_SETTINGS_DIRECTORY="$PROJECT_ROOT_DIRECTORY/設定"

source "$PROJECT_SETTINGS_DIRECTORY/建構作業系統核心.configuration.source.sh"

######## File scope variable definitions ended ########

######## Program ########
clean_up() {
	if [ -d "$workaround_safe_build_directory" ]; then
		printf "試圖卸載建構目錄……\n" | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
		pkexec umount "$workaround_safe_build_directory" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
		rmdir "$workaround_safe_build_directory" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
	fi
	
	cd "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY"
	rm -rf build 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
	# reset tracked files
	git reset --hard 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
	# remove untracked files
	git clean --force -d -x 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
	# checkout back to master branch
	git checkout master 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
}

# Defensive Bash Programming - main function, program entry point
# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
main() {
	# 更新 Git 子模組
	git submodule init
	git submodule update --depth 1
	
	# 預防程式先前被強制終止我們在開始之前多做一次清潔程序
	clean_up

	# 將來源碼切換到我們要用的版本
	cd "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY"
	git fetch --depth=1 origin "refs/tags/v${stable_kernel_version_to_checkout}:refs/tags/v${stable_kernel_version_to_checkout}" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
	git checkout v${stable_kernel_version_to_checkout} 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
	
  printf "下載 pf-kernel 修正……\n" | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
  wget --no-clobber --directory-prefix="$PROJECT_THIRD_PARTY_PF_KERNEL_PATCH_DIRECTORY" ${pf_kernel_patch_download_url} ${pf_kernel_patch_download_url}.sig 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
  if [ $? -ne 0 ]; then
		printf "錯誤：pf-kernel 修正下載失敗！\n" | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log" 1>&2
		printf "請檢查設定檔中 pf_kernel_patch_download_url 設定值的路徑是否正確！\n" | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log" 1>&2
		clean_up
		exit 1
  fi
  
  # 驗證資料完整性
  readonly pf_kernel_patch_filename=$(basename ${pf_kernel_patch_download_url})
  
  #gpg --verify "$PROJECT_THIRD_PARTY_PF_KERNEL_PATCH_DIRECTORY/$pf_kernel_patch_filename.sig"
  
  xz --decompress --keep "$PROJECT_THIRD_PARTY_PF_KERNEL_PATCH_DIRECTORY/$(basename ${pf_kernel_patch_download_url})"
  
  printf "套用 pf-kernel 修正……\n" | tee "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
  if [ ! -e "$PROJECT_THIRD_PARTY_PF_KERNEL_PATCH_DIRECTORY/$(basename --suffix=.xz ${pf_kernel_patch_download_url})" ]; then
		printf "錯誤： pf-kernel 修正檔案不存在！\n" | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log" 1>&2
		clean_up
		exit 1
  fi
  patch --strip=1 --directory="$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY" <"$PROJECT_THIRD_PARTY_PF_KERNEL_PATCH_DIRECTORY/$(basename  --suffix=.xz ${pf_kernel_patch_download_url})" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
  
	printf "複製 Linux 作業系統核心建構設定範本……\n" | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
	if [ ! -e "$linux_kernel_build_config_template_path" ]; then
		printf "錯誤：Linux 作業系統核心建構設定範本檔案不存在！\n" | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log" 1>&2
		printf "請檢查設定檔中 linux_kernel_build_config_template_path 設定值的路徑是否正確！\n" | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log" 1>&2
		clean_up
		exit 1
	fi
	
	mkdir --parents "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/build"
	cp "$linux_kernel_build_config_template_path" "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/build/.config" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
	
	printf "套用 Linux 作業系統核心建構設定修正……\n" | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
	"$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/scripts/config" --file "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY/build/.config" --disable "CONFIG_DEBUG_INFO" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
	
  if [ ! -d "$workaround_safe_build_directory" ]; then
		printf "Workarounding GNU Make bug, we'll create a new directory for building kernel.\n" | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log" 1>&2
		mkdir --parents "$workaround_safe_build_directory" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
  fi
  
  printf "掛載 Linux 作業系統核心來源碼目錄到建構路徑……\n" | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
  pkexec mount --bind "$PROJECT_THIRD_PARTY_LINUX_SOURCE_DIRECTORY" "$workaround_safe_build_directory" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"

  cd "$workaround_safe_build_directory"
  make O=build olddefconfig 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
  env DEBFULLNAME="$maintainer_name" DEBEMAIL="$maintainer_email_address" make --jobs=$(nproc) LOCALVERSION=-${maintainer_identifier_used_in_package_name} KDEB_PKGVERSION=$(make kernelversion)-${package_release_number} O=build bindeb-pkg  2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
  mv *.deb "$PROJECT_BUILD_ARTIFACT_DIRECTORY" 2>&1 | tee --append "$PROJECT_LOGS_DIRECTORY/建構作業系統核心.log"
  
  clean_up
  
	## 正常結束 script 程式
	exit 0
}
main

######## Program ended ########
