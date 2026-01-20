ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
DEBUG = 0
FINALPACKAGE = 1

# تعريف المسار لـ GitHub
THEOS ?= ~/theos
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SovereignSecurity

# استدعاء كافة الملفات البرمجية بالأسماء الجديدة
SovereignSecurity_FILES = fishhook.c Mithril.mm 
SovereignSecurity_FRAMEWORKS = UIKit Foundation Security CoreGraphics QuartzCore
# إعدادات لمنع الكراش وتحسين الأداء
SovereignSecurity_CFLAGS = -fobjc-arc -O3 -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk
