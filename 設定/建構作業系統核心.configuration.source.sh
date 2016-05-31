# 建構作業系統核心.configuration.source.sh - 建構作業系統核心的設定檔
# 林博仁 <Buo.Ren.Lin@gmail.com> © 2016
# 這個檔案會被「建構作業系統核心.sh」 `source` 進去

set +e
declare -p 2>/dev/null | grep --extended-regexp "^declare.* CONFIGURATION_LOADED(|=.*)$" &>/dev/null
if [ 0 -ne $? ]; then
	set -e
	# 軟體包相關設定
	readonly maintainer_name="林博仁"
	readonly maintainer_email_address="Buo.Ren.Lin@gmail.com"
	readonly maintainer_identifier_used_in_package_name="buo-ren"
	
	readonly package_release_number="2"
	
	# 因為 Linux 作業系統核心的軟體建構系統 GNU Make 不支援含有空白的路徑故我們用 bind mount point 來當作建構路徑（會在執行時自動嘗試建立）
	readonly workaround_safe_build_directory="$HOME/Workarounds/Safe_build_directory_for_Buo_Ren_Linux_Kernel"
	
	# Linux 來源碼樹的版本，對應到 linux-stable 版本倉庫中的 v${stable_kernel_version_to_checkout} 標籤
	readonly stable_kernel_version_to_checkout="4.6"
	
	# 預設運作模式設定
	declare -r default_kernel_branch="mainline"
	declare -r default_cpu_architecture="amd64"
	declare -r default_cpu_architecture_compatibility="autodetected-optimized"
	declare -r default_kernel_feature=""
	
	# pf-kernel 修正的下載網址
	readonly pf_kernel_patch_download_url="https://pf.natalenko.name/sources/4.5/patch-4.5-pf3.xz"
	
	# Linux 作業系統核心設定檔範本路徑
	readonly linux_kernel_build_config_template_path="/boot/config-4.4.0-22-generic"
	
	readonly CONFIGURATION_LOADED
fi
set -e
