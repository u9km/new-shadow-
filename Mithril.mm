#include <sys/mman.h>
#import <Foundation/Foundation.h>
#include <string>
#include <vector>
#include <dlfcn.h>
#include <unistd.h>
#include <stdlib.h>
#include <mach/mach.h>
#include <mach-o/dyld.h>
#import "2.h" 
// تأكد من وجود ملف 2.h في نفس المجلد، أو احذف السطر إذا لم تكن بحاجة إليه، 
// لكن بما أنك طلبت عدم تغيير الأوفستات، فقد تركت الاعتماد عليه كما هو.

// دالة البحث عن عنوان القاعدة (Base Address) بدون جيلبريك
static uintptr_t Mithril_GetModuleBase(const std::string& targetPath) {
    uint32_t count = _dyld_image_count();
    for (int i = 0; i < count; i++) {
        const char *imageName = _dyld_get_image_name(i);
        if (imageName) {
            std::string path = imageName;
            // البحث عن اسم اللعبة داخل المسار
            if (path.find(targetPath) != std::string::npos) {
                return (uintptr_t)_dyld_get_image_vmaddr_slide(i);
            }
        }
    }
    return 0;
}

// تنظيف الملفات المؤقتة
static void Mithril_CleanTempFiles() {
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ano_tmp"];
    NSString *tmpPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:docPath]) [fm removeItemAtPath:docPath error:nil];
    if ([fm fileExistsAtPath:tmpPath]) [fm removeItemAtPath:tmpPath error:nil];
}

// دالة الترقيع (Patch) المباشرة في الذاكرة
// هذه الدالة تعمل بالسايدلود لأنها تعدل ذاكرة التطبيق نفسه (Self-Task)
template<typename T>
void Mithril_Patch(vm_address_t addr, T data, int size = 0) {
    if (size == 0) size = sizeof(T);
    
    // 1. تغيير حماية الذاكرة للسماح بالكتابة
    kern_return_t kret = vm_protect(mach_task_self(), (vm_address_t)addr, size, 0, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    
    if (kret == KERN_SUCCESS) {
        // 2. كتابة البيانات (تعديل الأوفست)
        memcpy((void*)addr, &data, size);
        
        // 3. إعادة حماية الذاكرة للتنفيذ (تجنب الكراش)
        vm_protect(mach_task_self(), (vm_address_t)addr, size, 0, VM_PROT_READ | VM_PROT_EXECUTE);
    }
}

// نقطة الدخول (Constructor)
__attribute__((constructor))
static void Mithril_Init() {
    // تنظيف أولي
    Mithril_CleanTempFiles();

    // تأخير 10 ثواني لضمان تحميل اللعبة للأوفستات
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // جلب عنوان الذاكرة الأساسي للعبة
        uintptr_t abc1 = Mithril_GetModuleBase("ShadowTrackerExtra"); 
        
        // إذا وجدنا اللعبة، نبدأ الترقيع
        if (abc1 != 0) {
            
            // ==========================================
            // [منطقة الأوفستات - لم يتم المساس بها]
            // ==========================================
            Mithril_Patch<int>(abc1+std::stol(std::string("0x0002A8B68"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x101C84770"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x101C87200"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x101C85C80"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x101C86DF0"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x101C851DC"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x101947e04"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x101948928"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x100c8293c"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x101c42b90"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x101c427f0"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x101c41c70"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x101c3f988"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x1015c7284"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x1005a47dc"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x101c80474"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x101c80710"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x10093ae94"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x10093f9a8"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x101938a10"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x10193821c"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x101936d54"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x10193504c"), nullptr, 16), CFSwapInt32(0xC0035FD6)); 
            Mithril_Patch<int>(abc1+std::stol(std::string("0x100c82804"), nullptr, 16), CFSwapInt32(0xC0035FD6));  
            Mithril_Patch<int>(abc1+std::stol(std::string("0x100c827b8"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x100c8270c"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x100c81304"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x100c80dd4"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x100c80744"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x1000757d4"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x10007559c"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x100075378"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x10007599c"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x101C86920"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x101C83A10"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x101C88F30"), nullptr, 16), CFSwapInt32(0xC0035FD6));
            Mithril_Patch<int>(abc1+std::stol(std::string("0x101C87B00"), nullptr, 16), CFSwapInt32(0xC0035FD6));
        }
    });
}
