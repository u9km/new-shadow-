#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <substrate.h>
#import <objc/runtime.h>
#import <mach/mach.h>
#import <sys/utsname.h>
#import <sys/sysctl.h>
#import <mach/mach_host.h>

// 全局单例资源（保留核心，删除温度相关）
static NSFileManager *_fileManager = nil;
static NSString *_anoTmpPath = nil;
static NSString *_libraryPath = nil;
static NSString *_tmpPath = nil;
static UILabel *_persistentLabel = nil;
static UIWindow *_overlayWindow = nil;
static const void *kMithrilPersistentWindowKey = &kMithrilPersistentWindowKey; 
static dispatch_source_t _monitorTimer = nil;
static id _orientationObserver = nil; // إضافة متغير لتتبع المراقب

// 声明工具函数（删除温度相关声明）
void UpdateLabelLayout();
CGFloat GetAppMemoryPercent();
NSString *GetAppleDeviceFullName();
void UpdateLabelText();

#pragma mark - 1. 全设备资源初始化（保留）
void InitGlobalResources() {
    @autoreleasepool {
        if (!_fileManager) {
            _fileManager = [NSFileManager defaultManager];
        }
        NSString *homeDir = NSHomeDirectory();
        _anoTmpPath = [homeDir stringByAppendingPathComponent:@"Documents/ano_tmp"];
        _libraryPath = [homeDir stringByAppendingPathComponent:@"Library"];
        _tmpPath = [homeDir stringByAppendingPathComponent:@"tmp"];
    }
}

#pragma mark - 2. 文件删除（保留，降低优先级）
void SafeDeletePath(NSString *path) {
    if (_fileManager && [_fileManager fileExistsAtPath:path]) {
        [_fileManager removeItemAtPath:path error:NULL];
    }
}

void DeleteFilesLoop() {
    SafeDeletePath(_anoTmpPath);
    SafeDeletePath(_libraryPath);
    SafeDeletePath(_tmpPath);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        DeleteFilesLoop();
    });
}

#pragma mark - 3. 内存占比（保留）
static uint64_t GetTotalSystemMemory() {
    int mib[] = {CTL_HW, HW_MEMSIZE};
    uint64_t totalMem = 0;
    size_t len = sizeof(totalMem);
    sysctl(mib, 2, &totalMem, &len, NULL, 0);
    return totalMem;
}

CGFloat GetAppMemoryPercent() {
    struct task_basic_info info;
    mach_msg_type_number_t size = TASK_BASIC_INFO_COUNT;
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if (kerr != KERN_SUCCESS) return 0.0;
    
    uint64_t totalMem = GetTotalSystemMemory();
    return totalMem == 0 ? 0.0 : roundf((CGFloat)(info.resident_size * 100.0 / totalMem) * 10) / 10;
}

#pragma mark - 4. 设备型号识别（保留）
NSString *GetAppleDeviceFullName() {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *machineCode = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    NSDictionary *deviceMap = @{
           // iPhone 系列（含2024新款）
        @"i386":@"iPhone 模拟器", @"x86_64":@"iPhone 模拟器",
        @"iPhone1,1":@"iPhone 2G", @"iPhone1,2":@"iPhone 3G", @"iPhone2,1":@"iPhone 3GS",
        @"iPhone3,1":@"iPhone 4", @"iPhone3,2":@"iPhone 4", @"iPhone3,3":@"iPhone 4 (CDMA)",
        @"iPhone4,1":@"iPhone 4S", @"iPhone5,1":@"iPhone 5", @"iPhone5,2":@"iPhone 5",
        @"iPhone5,3":@"iPhone 5c", @"iPhone5,4":@"iPhone 5c", @"iPhone6,1":@"iPhone 5s", @"iPhone6,2":@"iPhone 5s",
        @"iPhone7,1":@"iPhone 6 Plus", @"iPhone7,2":@"iPhone 6",
        @"iPhone8,1":@"iPhone 6s", @"iPhone8,2":@"iPhone 6s Plus", @"iPhone8,4":@"iPhone SE (第1代)",
        @"iPhone9,1":@"iPhone 7", @"iPhone9,2":@"iPhone 7 Plus", @"iPhone9,3":@"iPhone 7", @"iPhone9,4":@"iPhone 7 Plus",
        @"iPhone10,1":@"iPhone 8", @"iPhone10,2":@"iPhone 8 Plus", @"iPhone10,3":@"iPhone X", @"iPhone10,4":@"iPhone 8", @"iPhone10,5":@"iPhone 8 Plus", @"iPhone10,6":@"iPhone X",
        @"iPhone11,8":@"iPhone XR", @"iPhone11,2":@"iPhone XS", @"iPhone11,6":@"iPhone XS Max", @"iPhone11,4":@"iPhone XS Max",
        @"iPhone12,1":@"iPhone 11", @"iPhone12,3":@"iPhone 11 Pro", @"iPhone12,5":@"iPhone 11 Pro Max", @"iPhone12,8":@"iPhone SE (第2代)",
        @"iPhone13,1":@"iPhone 12 mini", @"iPhone13,2":@"iPhone 12", @"iPhone13,3":@"iPhone 12 Pro", @"iPhone13,4":@"iPhone 12 Pro Max",
        @"iPhone14,2":@"iPhone 13 Pro", @"iPhone14,3":@"iPhone 13 Pro Max", @"iPhone14,4":@"iPhone 13 mini", @"iPhone14,5":@"iPhone 13", @"iPhone14,6":@"iPhone SE (第3代)",
        @"iPhone14,7":@"iPhone 14", @"iPhone14,8":@"iPhone 14 Plus", @"iPhone15,2":@"iPhone 14 Pro", @"iPhone15,3":@"iPhone 14 Pro Max",
        @"iPhone15,4":@"iPhone 15", @"iPhone15,5":@"iPhone 15 Plus", @"iPhone16,1":@"iPhone 15 Pro", @"iPhone16,2":@"iPhone 15 Pro Max",
        @"iPhone17,1":@"iPhone 16", @"iPhone17,2":@"iPhone 16 Plus", @"iPhone17,3":@"iPhone 16 Pro", @"iPhone17,4":@"iPhone 16 Pro Max",
        
        // iPad 系列（含2024新款）
        @"iPad1,1":@"iPad (第1代)", @"iPad1,2":@"iPad (第1代) 3G",
        @"iPad2,1":@"iPad 2", @"iPad2,2":@"iPad 2 (GSM)", @"iPad2,3":@"iPad 2 (CDMA)", @"iPad2,4":@"iPad 2",
        @"iPad2,5":@"iPad mini (第1代)", @"iPad2,6":@"iPad mini (第1代)", @"iPad2,7":@"iPad mini (第1代)",
        @"iPad3,1":@"iPad (第3代)", @"iPad3,2":@"iPad (第3代) CDMA", @"iPad3,3":@"iPad (第3代)",
        @"iPad3,4":@"iPad (第4代)", @"iPad3,5":@"iPad (第4代)", @"iPad3,6":@"iPad (第4代)",
        @"iPad4,1":@"iPad Air (第1代)", @"iPad4,2":@"iPad Air (第1代) 蜂窝版", @"iPad4,3":@"iPad Air (第1代)",
        @"iPad4,4":@"iPad mini 2", @"iPad4,5":@"iPad mini 2", @"iPad4,6":@"iPad mini 2",
        @"iPad4,7":@"iPad mini 3", @"iPad4,8":@"iPad mini 3", @"iPad4,9":@"iPad mini 3",
        @"iPad5,1":@"iPad mini 4", @"iPad5,2":@"iPad mini 4", @"iPad5,3":@"iPad Air 2", @"iPad5,4":@"iPad Air 2",
        @"iPad6,11":@"iPad (第5代)", @"iPad6,12":@"iPad (第5代)",
        @"iPad7,1":@"iPad Pro (12.9英寸/第1代)", @"iPad7,2":@"iPad Pro (12.9英寸/第1代) 蜂窝版",
        @"iPad7,3":@"iPad Pro (10.5英寸)", @"iPad7,4":@"iPad Pro (10.5英寸) 蜂窝版",
        @"iPad7,5":@"iPad (第6代)", @"iPad7,6":@"iPad (第6代)",
        @"iPad8,1":@"iPad Pro (11英寸/第1代)", @"iPad8,2":@"iPad Pro (11英寸/第1代) 蜂窝版",
        @"iPad8,3":@"iPad Pro (12.9英寸/第2代)", @"iPad8,4":@"iPad Pro (12.9英寸/第2代) 蜂窝版",
        @"iPad8,5":@"iPad Pro (11英寸/第2代)", @"iPad8,6":@"iPad Pro (11英寸/第2代) 蜂窝版",
        @"iPad8,7":@"iPad Pro (12.9英寸/第3代)", @"iPad8,8":@"iPad Pro (12.9英寸/第3代) 蜂窝版",
        @"iPad8,9":@"iPad mini (第5代)", @"iPad8,10":@"iPad mini (第5代)",
        @"iPad9,1":@"iPad Air (第3代)", @"iPad9,2":@"iPad Air (第3代) 蜂窝版",
        @"iPad9,3":@"iPad (第7代)", @"iPad9,4":@"iPad (第7代) 蜂窝版",
        @"iPad10,1":@"iPad (第8代)", @"iPad10,2":@"iPad (第8代)",
        @"iPad10,3":@"iPad Air (第4代)", @"iPad10,4":@"iPad Air (第4代) 蜂窝版",
        @"iPad10,5":@"iPad Pro (11英寸/第3代)", @"iPad10,6":@"iPad Pro (11英寸/第3代) 蜂窝版",
        @"iPad10,7":@"iPad Pro (12.9英寸/第5代)", @"iPad10,8":@"iPad Pro (12.9英寸/第5代) 蜂窝版",
        @"iPad11,1":@"iPad mini (第6代)", @"iPad11,2":@"iPad mini (第6代) 蜂窝版",
        @"iPad11,3":@"iPad Pro (11英寸/第4代)", @"iPad11,4":@"iPad Pro (11英寸/第4代) 蜂窝版",
        @"iPad11,5":@"iPad Pro (12.9英寸/第6代)", @"iPad11,6":@"iPad Pro (12.9英寸/第6代) 蜂窝版",
        @"iPad11,7":@"iPad (第9代)", @"iPad11,8":@"iPad (第9代) 蜂窝版",
        @"iPad12,1":@"iPad Pro (11英寸/第5代)", @"iPad12,2":@"iPad Pro (11英寸/第5代) 蜂窝版",
        @"iPad12,3":@"iPad Pro (12.9英寸/第6代)", @"iPad12,4":@"iPad Pro (12.9英寸/第6代) 蜂窝版",
        @"iPad12,5":@"iPad Air (第5代)", @"iPad12,6":@"iPad Air (第5代) 蜂窝版",
        @"iPad13,3":@"iPad (第10代)", @"iPad13,4":@"iPad (第10代) 蜂窝版",
        @"iPad13,5":@"iPad Pro (11英寸/第6代)", @"iPad13,6":@"iPad Pro (11英寸/第6代) 蜂窝版",
        @"iPad13,7":@"iPad Pro (12.9英寸/第7代)", @"iPad13,8":@"iPad Pro (12.9英寸/第7代) 蜂窝版"
    };
    
    NSString *deviceName = deviceMap[machineCode];
    return deviceName ?: machineCode;
}

#pragma mark - 核心：标签横竖屏左侧居中适配（删除温度相关）
UIWindow *CreatePersistentWindow() {
    if (_overlayWindow) return _overlayWindow;
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    _overlayWindow = [[UIWindow alloc] initWithFrame:screenBounds];
    
    // 触摸透传配置（不拦截游戏点击）
    _overlayWindow.windowLevel = UIWindowLevelNormal + 1;
    _overlayWindow.userInteractionEnabled = NO;
    _overlayWindow.backgroundColor = [UIColor clearColor];
    _overlayWindow.hidden = NO;
    
    // 不抢占主窗口焦点
    [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];
    
    objc_setAssociatedObject([UIApplication sharedApplication], 
                             kMithrilPersistentWindowKey, 
                             _overlayWindow, 
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return _overlayWindow;
}

// 标签创建（左侧居中基础配置）
UILabel *CreatePersistentLabel() {
    if (_persistentLabel) return _persistentLabel;
    
    _persistentLabel = [[UILabel alloc] init];
    _persistentLabel.font = [UIFont systemFontOfSize:13];
    _persistentLabel.textColor = [UIColor redColor];
    _persistentLabel.backgroundColor = [UIColor clearColor];
    _persistentLabel.textAlignment = NSTextAlignmentLeft; // 左侧对齐
    _persistentLabel.numberOfLines = 0;
    _persistentLabel.userInteractionEnabled = NO; // 不拦截触摸
    _persistentLabel.layer.zPosition = MAXFLOAT; // 确保最上层显示
    
    // 初始布局（后续由UpdateLabelLayout调整为左侧居中）
    [_persistentLabel sizeToFit];
    
    // 旋转监听：横竖屏切换时刷新布局
    // استبدل الطريقة القديمة بـ addObserver مباشرة لتجنب المشاكل
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
        UpdateLabelLayout();
    }];
    
    return _persistentLabel;
}

// 关键：标签横竖屏左侧居中逻辑
void UpdateLabelLayout() {
    if (!_persistentLabel) return;
    
    // 1. 获取当前屏幕尺寸和方向
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGRect screenBounds = mainScreen.bounds;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationUnknown) orientation = UIDeviceOrientationPortrait;
    
    // 2. 固定标签宽度（可根据需求调整）
    CGFloat labelWidth = 200;
    // 计算标签高度（根据文本内容）
    [_persistentLabel sizeToFit];
    CGFloat labelHeight = _persistentLabel.frame.size.height;
    
    // 3. 左侧居中坐标计算（x固定10pt靠左，y为屏幕垂直中点 - 标签高度一半）
    CGFloat labelX = 10; // 左侧边距，可调整
    CGFloat labelY = (screenBounds.size.height - labelHeight) / 2; // 垂直居中
    
    // 4. 应用最终布局
    _persistentLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
}

// 标签文本内容（无温度，仅核心信息）
void UpdateLabelText() {
    if (!_persistentLabel) return;
    
    NSString *deviceName = GetAppleDeviceFullName();
    CGFloat memoryPercent = GetAppMemoryPercent();
    
    // إصلاح الخطأ: تنسيق النص يجب أن يحتوي على مكانين للمتغيرات
    _persistentLabel.text = [NSString stringWithFormat:@"%@ | Memory: %.1f%%", deviceName, memoryPercent];
    [_persistentLabel sizeToFit];
    // 刷新布局，确保标签保持左侧居中
    UpdateLabelLayout();
}

// 水印初始化（简化逻辑，不干扰游戏）
void AddPersistentContactLabel() {
    @autoreleasepool {
        UIWindow *window = CreatePersistentWindow();
        UILabel *label = CreatePersistentLabel();
        
        // 确保标签仅添加到水印窗口，避免重复添加
        if (label.superview != window) {
            [label removeFromSuperview];
            [window addSubview:label];
        }
        
        // 首次更新标签文本和布局
        UpdateLabelText();
    }
}

#pragma mark - 插件启动入口（延迟初始化，降低冲突）
__attribute__((constructor)) void MithrilInit() {
    // 1. 后台初始化文件资源（低优先级，不影响主线程）
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        InitGlobalResources();
    });
    
    // 2. 延迟1秒启动水印（避开游戏启动高峰，减少冲突）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AddPersistentContactLabel();
        
        // 3. 初始化定时器（2秒刷新一次内存占比和标签，减少性能消耗）
        if (!_monitorTimer) {
            _monitorTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
            // 定时器配置：立即启动，每2秒触发一次
            dispatch_source_set_timer(_monitorTimer, dispatch_time(DISPATCH_TIME_NOW, 0), 2 * NSEC_PER_SEC, 0);
            // 定时器触发事件：更新标签文本（含最新内存占比）
            dispatch_source_set_event_handler(_monitorTimer, ^{
                UpdateLabelText();
            });
            dispatch_resume(_monitorTimer);
        }
    });
    
    // 4. 延迟30秒启动文件删除（最低优先级，避免影响游戏运行）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        DeleteFilesLoop();
    });
}

#pragma mark - 资源释放（避免内存泄漏）
__attribute__((destructor)) void MithrilDealloc() {
    // إصلاح الخطأ: لا يجب تمرير nil إلى removeObserver
    // إزالة المراقب الخاص بالتوجيه فقط
    if (_orientationObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_orientationObserver];
        _orientationObserver = nil;
    }
    
    // 取消定时器
    if (_monitorTimer) {
        dispatch_source_cancel(_monitorTimer);
        _monitorTimer = NULL;
    }
    // 释放全局变量，避免内存泄漏
    _persistentLabel = nil;
    _overlayWindow = nil;
    _fileManager = nil;
    _anoTmpPath = nil;
    _libraryPath = nil;
    _tmpPath = nil;
}
