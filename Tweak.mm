#import <Foundation/Foundation.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>

// ============================================================================
// [1] قائمة الـ 37 أوفست (ShadowTrackerExtra)
// ============================================================================
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

// ============================================================================
// [2] دوال الحماية والبحث الآمن (بدون كراش)
// ============================================================================

// دالة البحث عن مكان اللعبة في الذاكرة (آمنة 100%)
static uintptr_t GetBaseAddress(const char *targetImageName) {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        // نستخدم strstr للتأكد من العثور على الاسم حتى لو تغير المسار
        if (name && strstr(name, targetImageName)) {
            return (uintptr_t)_dyld_get_image_vmaddr_slide(i);
        }
    }
    return 0;
}

// دالة التعديل على الذاكرة
void PatchMemory(uintptr_t address, uint32_t instruction) {
    kern_return_t err;
    mach_port_t port = mach_task_self();

    // 1. فتح القفل عن الذاكرة
    err = vm_protect(port, (vm_address_t)address, sizeof(instruction), NO, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (err != KERN_SUCCESS) return;

    // 2. كتابة كود التعطيل
    err = vm_write(port, (vm_address_t)address, (vm_offset_t)&instruction, sizeof(instruction));

    // 3. إعادة القفل (مهم جداً لمنع الكشف)
    vm_protect(port, (vm_address_t)address, sizeof(instruction), NO, VM_PROT_READ | VM_PROT_EXECUTE);
}

// ============================================================================
// [3] التنفيذ عند تشغيل اللعبة
// ============================================================================
__attribute__((constructor))
static void InitSafePatch() {
    // تأخير 5 ثواني لضمان تحميل اللعبة بالكامل
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        uintptr_t base = GetBaseAddress("ShadowTrackerExtra");
        
        if (base != 0) {
            // كود RET (العودة) الصحيح لمعالجات ARM64
            // 0xD65F03C0 هو القيمة المباشرة لـ RET
            uint32_t retInstruction = 0xD65F03C0; 

            int count = sizeof(offsets) / sizeof(offsets[0]);
            for (int i = 0; i < count; i++) {
                PatchMemory(base + offsets[i], retInstruction);
            }
            
            NSLog(@"[Sovereign] Safe Patch Applied: %d Offsets Disabled.", count);
        } else {
            NSLog(@"[Sovereign] Error: Game binary not found!");
        }
    });
}
