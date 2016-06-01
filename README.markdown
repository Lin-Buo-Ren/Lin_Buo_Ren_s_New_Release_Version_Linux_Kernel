# 林博仁的新釋出版本 Linux 作業系統核心
<https://github.com/Lin-Buo-Ren/Lin_Buo_Ren_s_New_Release_Version_Linux_Kernel>

## 智慧財產授權條款
GNU GPL 第三版（不涵蓋 Linux 作業系統核心本身）

## 下載軟體
<https://mega.nz/#F!B0MyUIga!DHpoIkbeq-Uj2Qp52RmTbw>

## 專案開發狀態
還在設計自動化建構程式中，目前只支援 pf-kernel 建構。

## 製作程式執行時期依賴軟體
* realpath
* Linux 作業系統核心的軟體建構依賴軟體

## 用語說明
這邊列出的可用參數不一定已經實作，僅供參考

### Kernel Base Version(--kernel-base-version)
做為基底的 Linux 作業系統核心版本

### Kernel Branch(--kernel-branch)
Linux 作業系統核心的分支，例如：

* mainline/vanilla
	* 上游無修改版
* pf（預設）
* ubuntu

### Kernel Feature(--kernel-feature)
Linux 作業系統核心啟用或停用的功能，例如：

* （無）（預設）
* non-pae

### CPU Architecture(--cpu-architecture)
主要的處理器指令集，例如：

* x86
* amd64（預設）
* armv6
* armv7
* aarch64
* powerpc

### CPU Architecture Compatibility(--cpu-architecture-compatibility)
相容的（最低）處理器指令集類別，例如：

* autodetected-optimized（預設）
	* 由 GCC 針對您的電腦自動偵測出來的設定
* intel-haswell-optimized
* intel-ivybridge-optimized
* intel-core2-optimized
* intel-nehalem-optimized
* generic
	* 採用 Ubuntu 作業系統核心的預設設定
