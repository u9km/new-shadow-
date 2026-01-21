#include <Foundation/Foundation.h>
#include <mach/mach.h>
#include <mach-o/dyld.h>
#include <mach/mach_traps.h>
#import <UIKit/UIKit.h>
#include <string.h>

// دالة آمنة للبحث عن الـ Header بدون كراش
const struct mach_header *Mithril_GetSafeHeader() {
    // نبحث عن الملف التنفيذي الرئيسي (عادة رقم 0)
    const struct mach_header *header = _dyld_get_image_header(0);
    if (header) return header;
    
    // في حال فشل 0، نبحث عن أول صورة صالحة
    uint32_t count = _dyld_image_count();
    for (int i = 0; i < count; i++) {
        header = _dyld_get_image_header(i);
        if (header && (header->filetype == MH_EXECUTE)) {
            return header;
        }
    }
    return NULL;
}

bool Mithril_hasASLRzc() {
    const struct mach_header *mach = Mithril_GetSafeHeader();
    if (!mach) return FALSE; // حماية من الكراش
    
    if (mach->flags & MH_PIE) {
        return TRUE;
    } else {
        return FALSE;
    }
}

// دالة ذكية للبحث عن الأوفست الصحيح
long long Mithril_get_image_vmaddr_slidezc(const char *target_name) {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *path = _dyld_get_image_name(i);
        if (!path) continue;
        
        // البحث عن الاسم داخل المسار (سواء كان يحتوي على / أم لا)
        if (strstr(path, target_name) != NULL) {
            return (long long)_dyld_get_image_vmaddr_slide(i);
        }
    }
    return 0; // إرجاع 0 بدلاً من -1 لتجنب الحسابات الخاطئة
}

long long Mithril_calculateAddresszc(long long offset) {
    // محاولة البحث عن اسم اللعبة الشائع أو المكتبة المستهدفة
    // يمكنك تغيير "ShadowTrackerExtra" باسم المكتبة التي تريدها إذا كانت مختلفة
    long long slide = Mithril_get_image_vmaddr_slidezc("ShadowTrackerExtra");
    
    if (slide == 0) {
        // محاولة أخيرة مع الملف التنفيذي الرئيسي
        slide = (long long)_dyld_get_image_vmaddr_slide(0);
    }
    
    return slide + offset;
}

// تحديد نوع البيانات (Int32 vs Int64/Others)
bool Mithril_getTypezc(unsigned int data) {
    // منطق بسيط لتحديد نوع التعديل بناءً على حجم البيانات
    return (data > 0xFFFF);
}

// دالة الكتابة في الذاكرة (Memory Patching)
bool Mithril_nssb(long long offset, unsigned int data) {
    kern_return_t err;
    mach_port_t port = mach_task_self();
    
    // 1. حساب العنوان
    long long address = Mithril_calculateAddresszc(offset);
    if (address == 0 || address < 0x10000) return FALSE; // عنوان غير صالح
    
    // 2. فك الحماية للكتابة
    err = vm_protect(port, (vm_address_t)address, sizeof(data), NO, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (err != KERN_SUCCESS) return FALSE;
    
    // 3. معالجة البيانات (Big Endian vs Little Endian)
    // ملاحظة: معالجات ARM64 تستخدم Little Endian، عادة لا تحتاج لـ CFSwap إلا إذا كانت الأوفستات مصممة لذلك
    // لقد تركت التبديل مفعلاً كما في كودك الأصلي
    unsigned int finalData = data;
    if (Mithril_getTypezc(data)) {
        finalData = CFSwapInt32(data); 
    } else {
        // للأرقام الصغيرة
    }
    
    // 4. الكتابة
    err = vm_write(port, (vm_address_t)address, (vm_offset_t)&finalData, sizeof(finalData));
    if (err != KERN_SUCCESS) {
        // محاولة إعادة الحماية حتى لو فشلت الكتابة
        vm_protect(port, (vm_address_t)address, sizeof(data), NO, VM_PROT_READ | VM_PROT_EXECUTE);
        return FALSE;
    }
    
    // 5. إعادة الحماية للتنفيذ
    err = vm_protect(port, (vm_address_t)address, sizeof(data), NO, VM_PROT_READ | VM_PROT_EXECUTE);
    
    return TRUE;
}
