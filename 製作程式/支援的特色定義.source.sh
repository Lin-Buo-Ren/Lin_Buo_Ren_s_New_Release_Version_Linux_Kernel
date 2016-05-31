# 支援的特色定義.source.sh - 定義製作程式所支援的特色（功能）
# 林博仁 <Buo.Ren.Lin@gmail.com> © 2016

set +e
declare -p 2>/dev/null | grep --extended-regexp "^declare.* SUPPORTED_FEATURE_INITIALIZED(|=.*)$" &>/dev/null
if [ $? -ne 0 ]; then
	set -e
	declare -r SUPPORTED_FEATURE_KERNEL_BRANCH="pf mainline vanilla"
	declare -r SUPPORTED_FEATURE_CPU_ARCHITECTURE="amd64"
	declare -r SUPPORTED_FEATURE_CPU_ARCHITECTURE_COMPATIBILITY="generic autodetected-optimized intel-haswell-optimized intel-ivybridge-optimized intel-core2-optimized intel-nehalem-optimized"
	declare -r SUPPORTED_FEATURE_KERNEL_FEATURE=""
	
	declare -r SUPPORTED_FEATURE_INITIALIZED
fi
set -e
