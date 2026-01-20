#include <sys/mman.h>
#import <Foundation/Foundation.h>
#include <string>
#include <math.h>
#include <vector>
#include <dlfcn.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <mach/mach.h>
#include <mach-o/dyld.h>
#import "2.h"
#import "ViewController.h"
static uintptr_t Mithril_GetModuleBase(const std::string& targetPath) {
    uint32_t count = _dyld_image_count();
    for (int i = 0; i < count; i++) {
        std::string path = (const char *)_dyld_get_image_name(i);
        if (path.find(targetPath) != path.npos) {
            return (uintptr_t)_dyld_get_image_vmaddr_slide(i);
        }
    }
    return 0;
}
static void Mithril_CleanTempFiles() {
    NSString *filepath9 = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/ano_tmp"];
    NSFileManager *fileManager9 = [NSFileManager defaultManager];
    [fileManager9 removeItemAtPath:filepath9 error:nil];

    NSString *filepath91 = [NSHomeDirectory() stringByAppendingPathComponent:@"/tmp"];
    NSFileManager *fileManager91 = [NSFileManager defaultManager];
    [fileManager91 removeItemAtPath:filepath91 error:nil];
}
template<typename T>
void Mithril_Patch(vm_address_t addr, T data, int size = 0) {
    if (size == 0) size = sizeof(T);

    vm_protect(mach_task_self(), (vm_address_t) addr, size, NO, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    memcpy((void*)addr, &data, size);
    vm_protect(mach_task_self(), (vm_address_t)addr, size, NO, VM_PROT_READ | VM_PROT_EXECUTE);
}
__attribute__((constructor))
static void Mithril_Init() {
    Mithril_CleanTempFiles();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        uintptr_t abc1 = Mithril_GetModuleBase("ShadowTrackerExtra.app/ShadowTrackerExtra");

        if (abc1 != 0) {

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
