# Copyright (C) 2017 crDroid Android Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Disable list
DISABLE_DEVICE += camera.msm8994 gps.msm8994 gralloc.msm8994 keystore.msm8994 memtrack.msm8994 hwcomposer.msm8994 audio.primary.msm8994

DISABLE_ANALYZER := libbluetooth_jni bluetooth.mapsapi bluetooth.default bluetooth.mapsapi libbt-brcm_stack audio.a2dp.default libbt-brcm_gki \
	            libbt-utils libbt-qcom_sbc_decoder libbt-brcm_bta libbt-brcm_stack libbt-vendor libbtprofile libbtdevice libbtcore bdt bdtest libbt-hci \
	            libosi ositests libbluetooth_jni net_test_osi net_test_device net_test_btcore net_bdtool net_hci bdAddrLoader libc_bionic $(DISABLE_ANALYZER)

DISABLE_CRDROID := libaudioflinger libF77blasAOSP $(DISABLE_DEVICE) $(DISABLE_ANALYZER)

DISABLE_STRICT := busybox clatddex2oat dnsmasq ip libtwrpmtp libfusetwrp libguitwrp libuclibcrpc libmedia libpdfium% libandroid_runtime libandroidfw libaudioflinger libmediaplayerservice libziparchive-host \
                  libstagefright libfdlibm libvariablespeed librtp_jni libwilhelm libdownmix libldnhncr libqcomvisualizer libvisualizer libutils libwebview% libart% linker mm-vdec-omx-test libdiskconfig libjavacore \
                  libziparchive libstagefright_webm libc% liblog libosi libnetlink libnvvisualizer libiprouteutil libmmcamera_interface libwifi-service logd mdnsd oatdump patchoat ping ping6 static_busybox \
                  backtrace_test libLLVM% libadbd libgui libskia% libvixl libmcld% libpcap vold $(DISABLE_DEVICE) $(DISABLE_ANALYZER)

# Filter
my_cflags :=  $(filter-out -Wall -Werror -Werror=% -g,$(my_cflags))
my_cppflags :=  $(filter-out -Wall -Werror -Werror=% -g,$(my_cppflags))


# IPA
ifndef LOCAL_IS_HOST_MODULE
  ifeq (,$(filter true,$(my_clang)))
    ifneq (1,$(words $(filter $(DISABLE_ANALYZER),$(LOCAL_MODULE))))
      my_cflags += -fipa-sra -fipa-pta -fipa-cp -fipa-cp-clone
    endif
  else
    ifneq (1,$(words $(filter $(DISABLE_ANALYZER),$(LOCAL_MODULE))))
      my_cflags += -analyze -analyzer-purge
    endif
  endif
endif


# Benzo Opts
ifeq ($(my_clang),true)
 ifneq ($(strip $(LOCAL_IS_HOST_MODULE)),true)
   ifeq ($(filter $(DISABLE_CRDROID), $(LOCAL_MODULE)),)
    my_conlyflags += -pipe -ftree-slp-vectorize -fomit-frame-pointer -ffunction-sections -fdata-sections \
	             -fforce-addr -funroll-loops -ffp-contract=fast -ftree-slp-vectorize -fno-signed-zeros \
                     -freciprocal-math -inline -loop-deletion -ffast-math
    my_ldflags += -Wl,--as-needed -Wl,--gc-sections -Wl,--relax -Wl,--sort-common
  endif
 endif
endif


# Strict Aliasing
ifeq ($(my_clang),true)
 ifeq (1,$(words $(filter $(DISABLE_STRICT),$(LOCAL_MODULE))))
   my_conlyflags += -fno-strict-aliasing
   my_cppflags += -fno-strict-aliasing
  else
   my_conlyflags += -fstrict-aliasing -Wstrict-aliasing=2 -Werror=strict-aliasing
   my_cppflags += -fstrict-aliasing -Wstrict-aliasing=2 -Werror=strict-aliasing
 endif
else
 ifeq (1,$(words $(filter $(DISABLE_STRICT),$(LOCAL_MODULE))))
   my_conlyflags += -fno-strict-aliasing
   my_cppflags += -fno-strict-aliasing
  else
   my_conlyflags += -fstrict-aliasing -Wstrict-aliasing=3 -Werror=strict-aliasing
   my_cppflags += -fstrict-aliasing -Wstrict-aliasing=3 -Werror=strict-aliasing
 endif
endif
