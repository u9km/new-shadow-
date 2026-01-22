#include <sys/mman.h>
#import <Foundation/Foundation.h>
#include <mach/mach.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>

// 1. استخدام مصفوفة للأوفستات بدلاً من التكرار
// هذه هي العناوين الثابتة (Static Addresses)
static uintptr_t offsets[] = {
    0x0002A8B68, 0x101C84770, 0x101C87200, 0x101C85C80, 0x101C86DF0, 
    0x101C851DC, 0x101947e04, 0x101948928, 0x100c8293c, 0x101c42b90, 
    0x101c427f0, 0x101c41c70, 0x101c3f988, 0x1015c7284, 0x1005a47dc, 
    0x101c80474, 0x101c80710, 0x10093ae94, 0x10093f9a8, 0x101938a10, 
    0x10193821c, 0x101936d54, 0x10193504c, 0x100c82804, 0x100c827b8, 
    0x100c8270c, 0x100c81304, 0x100c80dd4, 0x100c80744, 0x1000757d4, 
    0x10007559c, 0x100075378, 0x10007599c, 0x101C86920, 0x101C83A10, 
    0x101C88F30, 0x101C87B00
};

// 2. دالة البحث عن العنوان الأساسي (محسنة)
static uintptr_t GetBaseAddress(const char *target) {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, target)) { // استخدام strstr أسرع وأبسط
            return (uintptr_t)_dyld_get_image_vmaddr_slide(i);
        }
    }
    return 0;
}

// 3. دالة الباتش (مبسطة)
void ApplyPatch(uintptr_t address, uint32_t instruction) {
    kern_return_t err;
    mach_port_t port = mach_task_self();

    // فك الحماية
    err = vm_protect(port, (vm_address_t)address, sizeof(instruction), NO, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (err != KERN_SUCCESS) return;

    // الكتابة
    *(uint32_t *)address = instruction;

    // إعادة الحماية
    vm_protect(port, (vm_address_t)address, sizeof(instruction), NO, VM_PROT_READ | VM_PROT_EXECUTE);
}

// 4. نقطة الدخول (Constructor)
__attribute__((constructor))
static void Init() {
    // تنظيف الملفات (اختياري)
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ano_tmp"] error:nil];

    // تأخير 10 ثواني
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        uintptr_t slide = GetBaseAddress("ShadowTrackerExtra");
        
        if (slide != 0) {
            // كود RET المباشر (Little Endian)
            // هذا يعادل CFSwapInt32(0xC0035FD6)
            uint32_t retPayload = 0xD65F03C0; 

            int count = sizeof(offsets) / sizeof(offsets[0]);
            for (int i = 0; i < count; i++) {
                // حساب العنوان الحقيقي = Slide + Offset
                ApplyPatch(slide + offsets[i], retPayload);
            }
        }
    });
}
