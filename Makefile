# إعدادات المعمارية للأجهزة الحديثة
ARCHS = arm64
TARGET := iphone:clang:latest:14.0
DEBUG = 0
FINALPACKAGE = 1

# مسار Theos (تلقائي)
THEOS ?= ~/theos
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SovereignSecurity

# الملف الذي يحتوي على الكود
SovereignSecurity_FILES = Tweak.mm

# مكتبات النظام المطلوبة
SovereignSecurity_FRAMEWORKS = UIKit Foundation

# إعدادات مهمة جداً:
# -fobjc-arc: إدارة الذاكرة التلقائية
# -segalign,0x4000: ضروري جداً لنسخ السايدلود لمنع الكراش
SovereignSecurity_CFLAGS = -fobjc-arc
SovereignSecurity_LDFLAGS = -Wl,-segalign,0x4000

include $(THEOS_MAKE_PATH)/tweak.mk
