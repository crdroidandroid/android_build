# Copyright (C) 2015-2016 DragonTC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Set Bluetooth Modules
BLUETOOTH := libbluetooth_jni bluetooth.mapsapi bluetooth.default bluetooth.mapsapi libbt-brcm_stack audio.a2dp.default libbt-brcm_gki libbt-utils libbt-qcom_sbc_decoder libbt-brcm_bta libbt-brcm_stack libbt-vendor libbtprofile libbtdevice libbtcore bdt bdtest libbt-hci libosi ositests libbluetooth_jni net_test_osi net_test_device net_test_btcore net_bdtool net_hci bdAddrLoader

#######################
##  D R A G O N T C  ##
#######################

# Disable modules that don't work with DragonTC. Split up by arch.
DISABLE_DTC_arm :=
DISABLE_DTC_arm64 := libbnnmlowpV8 libF77blasV8 libF77blas libRSSupport

# Set DISABLE_DTC based on arch
DISABLE_DTC := \
  $(DISABLE_DTC_$(TARGET_ARCH)) \
  $(LOCAL_DISABLE_DTC)

# Enable DragonTC on GCC modules. Split up by arch.
ENABLE_DTC_arm :=
ENABLE_DTC_arm64 :=

# Set ENABLE_DTC based on arch
ENABLE_DTC := \
  $(ENABLE_DTC_$(TARGET_ARCH)) \
  $(LOCAL_ENABLE_DTC)

# Enable DragonTC on current module if requested.
ifeq (1,$(words $(filter $(ENABLE_DTC),$(LOCAL_MODULE))))
  my_cc := $(CLANG)
  my_cxx := $(CLANG_CXX)
  my_clang := true
endif

# Disable DragonTC on current module if requested.
ifeq ($(my_clang),true)
  ifeq (1,$(words $(filter $(DISABLE_DTC),$(LOCAL_MODULE))))
    my_cc := $(AOSP_CLANG)
    my_cxx := $(AOSP_CLANG_CXX)
    ifeq ($(HOST_OS),darwin)
      # Darwin is really bad at dealing with idiv/sdiv. Don't use krait on Darwin.
      CLANG_CONFIG_arm_EXTRA_CFLAGS += -mcpu=cortex-a9
    else
      CLANG_CONFIG_arm_EXTRA_CFLAGS += -mcpu=krait
    endif
  else
    CLANG_CONFIG_arm_EXTRA_CFLAGS += -mcpu=krait2
  endif
endif


#################
##  P O L L Y  ##
#################

# Polly flags for use with Clang
POLLY := -O3 -mllvm -polly \
  -mllvm -polly-parallel -lgomp \
  -mllvm -polly-ast-use-context \
  -mllvm -polly-vectorizer=stripmine \
  -mllvm -polly-opt-fusion=max \
  -mllvm -polly-opt-maximize-bands=yes \
  -mllvm -polly-run-dce \
  -mllvm -polly-position=after-loopopt \
  -mllvm -polly-run-inliner \
  -mllvm -polly-detect-keep-going \
  -mllvm -polly-opt-simplify-deps=no \
  -mllvm -polly-rtc-max-arrays-per-group=40

# Disable modules that dont work with Polly. Split up by arch.
DISABLE_POLLY_arm := \
  libjpeg_static \
  libicuuc

DISABLE_POLLY_arm64 := \
  libjpeg_static \
  libicuuc \
  libwebp-decode \
  libwebp-encode \
  libpdfiumfxge \
  libskia_static \
  libaudioutils \
  libpdfium% \
  libLLVMSupport \
  libsvoxpico \
  libRS_internal \
  libvpx \
  libopus \
  libv8 \
  libsonic \
  libaudioflinger \
  libstagefright% \
  libart \
  libFFTEm \
  libRSCpuRef \
  libbnnmlowp \
  libmedia_jni \
  libFraunhoferAAC \
  libavcdec \
  libavcenc \
  libmpeg2dec \
  libwebrtc% \
  libmusicbundle \
  libreverb \
  libscrypt_static \
  libmpeg2dec \
  libcrypto_static \
  libcrypto \
  libyuv%

# Set DISABLE_POLLY based on arch
DISABLE_POLLY := \
  $(DISABLE_POLLY_$(TARGET_ARCH)) \
	$(DISABLE_DTC) \
  $(LOCAL_DISABLE_POLLY)

# Set POLLY based on DISABLE_POLLY
ifeq (1,$(words $(filter $(DISABLE_POLLY),$(LOCAL_MODULE))))
  POLLY := -O3
endif

# Set POLLY based on BLUETOOTH
ifeq (1,$(words $(filter $(BLUETOOTH),$(LOCAL_MODULE))))
  POLLY := -Os
endif

# Set POLLY based on DISABLE_POLLY
ifeq ($(my_32_64_bit_suffix),32)
  ifeq (1,$(words $(filter $(DISABLE_POLLY_arm64_32),$(LOCAL_MODULE))))
    POLLY := -O3
  endif
endif

ifeq ($(my_clang),true)
  ifndef LOCAL_IS_HOST_MODULE
    # Possible conflicting flags will be filtered out to reduce argument
    # size and to prevent issues with locally set optimizations.
    my_cflags := $(filter-out -Wall -Werror -g -O3 -O2 -Os -O1 -O0 -Og -Oz -Wextra -Weverything,$(my_cflags))
    # Enable -O3 and Polly if not blacklisted, otherwise use -Os.
    my_cflags += $(POLLY) -Qunused-arguments -Wno-unknown-warning-option -w -fuse-ld=gold
    my_ldflags += -fuse-ld=gold
  endif
endif


#############
##  L T O  ##
#############

# Disable modules that don't work with Link Time Optimizations. Split up by arch.
DISABLE_LTO_arm := libLLVMScalarOpts libjni_latinime_common_static libjni_latinime adbd nit libnetd_client libblas
DISABLE_THINLTO_arm := libart libart-compiler libsigchain
DISABLE_LTO_arm64 :=
DISABLE_THINLTO_arm64 :=


# Set DISABLE_LTO and DISABLE_THINLTO based on arch
DISABLE_LTO := \
  $(DISABLE_LTO_$(TARGET_ARCH)) \
  $(DISABLE_DTC) \
  $(LOCAL_DISABLE_LTO)
DISABLE_THINLTO := \
  $(DISABLE_THINLTO_$(TARGET_ARCH)) \
  $(LOCAL_DISABLE_THINLTO)

# Enable LTO (currently disabled due to issues in linking, enable at your own risk)
ifeq ($(ENABLE_DTC_LTO),true)
  ifeq ($(my_clang),true)
    ifndef LOCAL_IS_HOST_MODULE
      ifneq ($(LOCAL_MODULE_CLASS),STATIC_LIBRARIES)
        ifneq (1,$(words $(filter $(DISABLE_LTO),$(LOCAL_MODULE))))
          ifneq (1,$(words $(filter $(DISABLE_THINLTO),$(LOCAL_MODULE))))
            my_cflags += -flto=thin -fuse-ld=gold
            my_ldflags += -flto=thin -fuse-ld=gold
          else
            my_cflags += -flto -fuse-ld=gold
            my_ldflags += -flto -fuse-ld=gold
          endif
        else
          my_cflags += -fno-lto -fuse-ld=gold
          my_ldflags += -fno-lto -fuse-ld=gold
        endif
      endif
    endif
  endif
endif
