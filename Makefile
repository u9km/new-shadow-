# 1. إعدادات المعمارية (ARM64 للأجهزة الحديثة)
ARCHS = arm64
TARGET := iphone:clang:latest:14.0
DEBUG = 0
FINALPACKAGE = 1

# 2. تحديد مسار Theos (تلقائي)
THEOS ?= ~/theos
include $(THEOS)/makefiles/common.mk

# 3. اسم الأداة
TWEAK_NAME = SovereignSecurity

# 4. ملفات الكود (تأكد أن اسم ملفك هنا يطابق الملف الموجود في المجلد)
# إذا كان اسم ملفك Mithril.mm فغير Tweak.mm إلى Mithril.mm
SovereignSecurity_FILES = Tweak.mm

# 5. مكتبات النظام المطلوبة
SovereignSecurity_FRAMEWORKS = UIKit Foundation

# 6. أعلام التجميع (Flags) - أهم جزء للسايدلود
# -fobjc-arc: لإدارة الذاكرة تلقائياً
# -Wl,-segalign,0x4000: يمنع الكراش في iOS 14+ عند الحقن الخارجي
SovereignSecurity_CFLAGS = -fobjc-arc
SovereignSecurity_LDFLAGS = -Wl,-segalign,0x4000

include $(THEOS_MAKE_PATH)/tweak.mk
