LOCAL_PATH := $(call my-dir)
include $(LOCAL_PATH)/../common.mk
include $(CLEAR_VARS)

LOCAL_MODULE                  := hwcomposer.$(TARGET_BOARD_PLATFORM)
LOCAL_VENDOR_MODULE           := true
LOCAL_MODULE_RELATIVE_PATH    := hw
LOCAL_MODULE_TAGS             := optional
LOCAL_STATIC_LIBRARIES        += libskia_renderengine

ifeq ($(strip $(TARGET_USES_QCOM_DISPLAY_PP)),true)
LOCAL_C_INCLUDES              += $(TARGET_OUT_HEADERS)/qdcm/inc \
                                 $(TARGET_OUT_HEADERS)/common/inc \
                                 $(TARGET_OUT_HEADERS)/pp/inc
endif

LOCAL_SHARED_LIBRARIES        := $(common_libs) libEGL liboverlay \
                                 libhdmi libqdutils libhardware_legacy \
                                 libdl libmemalloc libqservice libsync \
                                 libbinder libmedia libdisplayconfig \
                                 libbfqio libnativewindow libGLESv2 libpng

LOCAL_CFLAGS                  := $(common_flags) -DLOG_TAG=\"qdhwcomposer\" -Wno-absolute-value \
                                 -Wno-float-conversion -Wno-unused-parameter

ifeq ($(TARGET_USES_QCOM_BSP),true)
LOCAL_SHARED_LIBRARIES += libhwui
ifeq ($(GET_FRAMEBUFFER_FORMAT_FROM_HWC),true)
    LOCAL_CFLAGS += -DGET_FRAMEBUFFER_FORMAT_FROM_HWC
endif
ifeq ($(GET_DISPLAY_SECURE_STATUS_FROM_HWC),true)
    LOCAL_CFLAGS += -DGET_DISPLAY_SECURE_STATUS_FROM_HWC
endif
endif #TARGET_USES_QCOM_BSP

#Enable Dynamic FPS if PHASE_OFFSET is not set
ifeq ($(VSYNC_EVENT_PHASE_OFFSET_NS),)
    LOCAL_CFLAGS += -DDYNAMIC_FPS
endif

LOCAL_HEADER_LIBRARIES        := display_headers generated_kernel_headers
LOCAL_SRC_FILES               := hwc.cpp          \
                                 hwc_utils.cpp    \
                                 hwc_uevents.cpp  \
                                 hwc_vsync.cpp    \
                                 hwc_fbupdate.cpp \
                                 hwc_mdpcomp.cpp  \
                                 hwc_copybit.cpp  \
                                 hwc_qclient.cpp  \
                                 hwc_dump_layers.cpp \
                                 hwc_ad.cpp \
                                 hwc_virtual.cpp

TARGET_MIGRATE_QDCM_LIST := msm8909
TARGET_MIGRATE_QDCM := $(call is-board-platform-in-list,$(TARGET_MIGRATE_QDCM_LIST))

ifeq ($(TARGET_MIGRATE_QDCM), true)
ifeq ($(strip $(TARGET_USES_QCOM_DISPLAY_PP)),true)
LOCAL_SRC_FILES += hwc_qdcm.cpp
else
LOCAL_SRC_FILES += hwc_qdcm_legacy.cpp
endif
else
LOCAL_SRC_FILES += hwc_qdcm_legacy.cpp
endif

include $(BUILD_SHARED_LIBRARY)
