# إعدادات المعمارية لعام 2026 (دعم آيفون XS وما فوق)
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SovereignSecurity

# [span_4](start_span)ربط ملفات المشروع: fishhook ومحتويات مجلد الحماية[span_4](end_span)
SovereignSecurity_FILES = fishhook.c $(wildcard 防禁令/*.mm)
# [span_5](start_span)إضافة الأطر البرمجية المطلوبة للواجهة والأمن[span_5](end_span)
SovereignSecurity_FRAMEWORKS = UIKit CoreML Foundation Security QuartzCore
# إعدادات التجميع لضمان استقرار الحقن
SovereignSecurity_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable

include $(THEOS_MAKE_PATH)/tweak.mk
