# إعدادات المعمارية والهدف
# تم إضافة arm64e لدعم الأجهزة الحديثة
ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:14.0
DEBUG = 0
FINALPACKAGE = 1

# السطر السحري: يستخدم المسار الموجود في النظام وإذا لم يجده يبحث في المسار المحلي
THEOS ?= ~/theos
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SovereignSecurity

# استدعاء كافة الملفات البرمجية بالأسماء الجديدة المستقرة
SovereignSecurity_FILES = fishhook.c Mithril.mm SovereignCleanup.mm
SovereignSecurity_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreML
SovereignSecurity_CFLAGS = -fobjc-arc -O3 -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk
