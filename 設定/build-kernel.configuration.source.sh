# build-kernel.configuration.source.sh - build-kernel 的設定檔
# 林博仁 <Buo.Ren.Lin@gmail.com> © 2016
# 這個檔案會被 build-kernel.sh `source` 進去

# 因為 Linux 作業系統核心的軟體建構系統 GNU Make 不支援含有空白的路徑故我們用 bind mount point 來當作建構路徑（會在執行時自動嘗試建立）
readonly workaround_safe_build_directory="$HOME/Workarounds/Safe_build_directory_for_Buo_Ren_Linux_Kernel"

# Linux 來源碼樹的版本，對應到 linux-stable 版本倉庫中的 v${stable_kernel_version_to_checkout} 標籤
readonly stable_kernel_version_to_checkout="4.5"

# pf-kernel 修正的下載路徑
readonly pf_kernel_patch_download_link="https://pf.natalenko.name/sources/4.5/patch-4.5-pf2.xz"

# Linux 作業系統核心設定檔範本
readonly linux_kernel_build_config_template="/boot/config-4.4.0-21-generic"

readonly maintainer_name="林博仁"
readonly maintainer_email_address="Buo.Ren.Lin@gmail.com"
readonly maintainer_identifier_used_in_package_name="buo-ren"

readonly package_release_number="1"