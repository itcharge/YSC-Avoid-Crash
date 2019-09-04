//
//  NSObject+KVODefender.m
//  YSC-Avoid-Crash
//
//  Created by WalkingBoy on 2019/8/19.
//  Copyright © 2019 bujige. All rights reserved.
//

#import "NSObject+KVODefender.h"
#import "NSObject+MethodSwizzling.h"
#import <objc/runtime.h>


#pragma mark - YSCKVOProxy 相关

@interface YSCKVOProxy : NSObject

- (NSArray *)getAllKeyPaths;

@end

@implementation YSCKVOProxy
{
    // 关系数据表结构：{keypath : [observer1, observer2 , ...](NSHashTable)}
    @private
    NSMutableDictionary<NSString *, NSHashTable<NSObject *> *> *_kvoInfoMap;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _kvoInfoMap = [NSMutableDictionary dictionary];
    }
    return self;
}

// 添加 KVO 信息操作, 添加成功返回 YES
- (BOOL)addInfoToMapWithObserver:(NSObject *)observer
                      forKeyPath:(NSString *)keyPath
                         options:(NSKeyValueObservingOptions)options
                         context:(void *)context {
    
    @synchronized (self) {
        if (!observer || !keyPath ||
            ([keyPath isKindOfClass:[NSString class]] && keyPath.length <= 0)) {
            return NO;
        }
        
        NSHashTable<NSObject *> *info = _kvoInfoMap[keyPath];
        if (info.count == 0) {
            info = [[NSHashTable alloc] initWithOptions:(NSPointerFunctionsWeakMemory) capacity:0];
            [info addObject:observer];

            _kvoInfoMap[keyPath] = info;
            
            return YES;
        }
        
        if (![info containsObject:observer]) {
            [info addObject:observer];
        }
        
        return NO;
    }
}

// 移除 KVO 信息操作, 添加成功返回 YES
- (BOOL)removeInfoInMapWithObserver:(NSObject *)observer
                         forKeyPath:(NSString *)keyPath {
    
    @synchronized (self) {
        if (!observer || !keyPath ||
            ([keyPath isKindOfClass:[NSString class]] && keyPath.length <= 0)) {
            return NO;
        }
        
        NSHashTable<NSObject *> *info = _kvoInfoMap[keyPath];
        
        if (info.count == 0) {
            return NO;
        }
        
        [info removeObject:observer];
        
        if (info.count == 0) {
            [_kvoInfoMap removeObjectForKey:keyPath];
            
            return YES;
        }
        
        return NO;
    }
}

// 添加 KVO 信息操作, 添加成功返回 YES
- (BOOL)removeInfoInMapWithObserver:(NSObject *)observer
                         forKeyPath:(NSString *)keyPath
                            context:(void *)context {
    @synchronized (self) {
        if (!observer || !keyPath ||
            ([keyPath isKindOfClass:[NSString class]] && keyPath.length <= 0)) {
            return NO;
        }
    
        NSHashTable<NSObject *> *info = _kvoInfoMap[keyPath];
    
        if (info.count == 0) {
            return NO;
        }
    
        [info removeObject:observer];
    
        if (info.count == 0) {
            [_kvoInfoMap removeObjectForKey:keyPath];
            
            return YES;
        }
    
        return NO;
    }
}

// 实际观察者 yscKVOProxy 进行监听，并分发
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {

    NSHashTable<NSObject *> *info = _kvoInfoMap[keyPath];
    
    for (NSObject *observer in info) {
        @try {
            [observer observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        } @catch (NSException *exception) {
            NSString *reason = [NSString stringWithFormat:@"KVO Warning : %@",[exception description]];
            NSLog(@"%@",reason);
        }
    }
}

// 获取所有被观察的 keypaths
- (NSArray *)getAllKeyPaths {
    NSArray <NSString *>*keyPaths = _kvoInfoMap.allKeys;
    return keyPaths;
}

@end


#pragma mark - NSObject+KVODefender 分类

@implementation NSObject (KVODefender)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 拦截 `addObserver:forKeyPath:options:context:` 方法，替换自定义实现
        [NSObject yscDefenderSwizzlingInstanceMethod: @selector(addObserver:forKeyPath:options:context:)
                                          withMethod: @selector(ysc_addObserver:forKeyPath:options:context:)
                                           withClass: [NSObject class]];
        
        // 拦截 `removeObserver:forKeyPath:` 方法，替换自定义实现
        [NSObject yscDefenderSwizzlingInstanceMethod: @selector(removeObserver:forKeyPath:)
                                          withMethod: @selector(ysc_removeObserver:forKeyPath:)
                                           withClass: [NSObject class]];
        
        // 拦截 `removeObserver:forKeyPath:context:` 方法，替换自定义实现
        [NSObject yscDefenderSwizzlingInstanceMethod: @selector(removeObserver:forKeyPath:context:)
                                          withMethod: @selector(ysc_removeObserver:forKeyPath:context:)
                                           withClass: [NSObject class]];
        
        // 拦截 `dealloc` 方法，替换自定义实现
        [NSObject yscDefenderSwizzlingInstanceMethod: NSSelectorFromString(@"dealloc")
                                          withMethod: @selector(ysc_kvodealloc)
                                           withClass: [NSObject class]];
    });
}

static void *YSCKVOProxyKey = &YSCKVOProxyKey;
static NSString *const KVODefenderValue = @"YSC_KVODefender";
static void *KVODefenderKey = &KVODefenderKey;

// YSCKVOProxy setter 方法
- (void)setYscKVOProxy:(YSCKVOProxy *)yscKVOProxy {
    objc_setAssociatedObject(self, YSCKVOProxyKey, yscKVOProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// YSCKVOProxy getter 方法
- (YSCKVOProxy *)yscKVOProxy {
    id yscKVOProxy = objc_getAssociatedObject(self, YSCKVOProxyKey);
    if (yscKVOProxy == nil) {
        yscKVOProxy = [[YSCKVOProxy alloc] init];
        self.yscKVOProxy = yscKVOProxy;
    }
    return yscKVOProxy;
}

// 自定义 addObserver:forKeyPath:options:context: 实现方法
- (void)ysc_addObserver:(NSObject *)observer
             forKeyPath:(NSString *)keyPath
                options:(NSKeyValueObservingOptions)options
                context:(void *)context {
    
    if (!isSystemClass(self.class)) {
        objc_setAssociatedObject(self, KVODefenderKey, KVODefenderValue, OBJC_ASSOCIATION_RETAIN);
        if ([self.yscKVOProxy addInfoToMapWithObserver:observer forKeyPath:keyPath options:options context:context]) {
            // 如果添加 KVO 信息操作成功，则调用系统添加方法
            [self ysc_addObserver:self.yscKVOProxy forKeyPath:keyPath options:options context:context];
        } else {
            // 添加 KVO 信息操作失败：重复添加
            NSString *className = (NSStringFromClass(self.class) == nil) ? @"" : NSStringFromClass(self.class);
            NSString *reason = [NSString stringWithFormat:@"KVO Warning : Repeated additions to the observer:%@ for the key path:'%@' from %@",
                                observer, keyPath, className];
            NSLog(@"%@",reason);
        }
    } else {
        [self ysc_addObserver:observer forKeyPath:keyPath options:options context:context];
    }
}

// 自定义 removeObserver:forKeyPath:context: 实现方法
- (void)ysc_removeObserver:(NSObject *)observer
                forKeyPath:(NSString *)keyPath
                   context:(void *)context {
    
    if (!isSystemClass(self.class)) {
        if ([self.yscKVOProxy removeInfoInMapWithObserver:observer forKeyPath:keyPath context:context]) {
            // 如果移除 KVO 信息操作成功，则调用系统移除方法
            [self ysc_removeObserver:self.yscKVOProxy forKeyPath:keyPath context:context];
        } else {
            // 移除 KVO 信息操作失败：移除了未注册的观察者
            NSString *className = NSStringFromClass(self.class) == nil ? @"" : NSStringFromClass(self.class);
            NSString *reason = [NSString stringWithFormat:@"*** Crash Message: Cannot remove an observer %@ for the key path '%@' from %@ , because it is not registered as an observer ***", observer, keyPath, className];
            NSLog(@"%@",reason);
        }
    } else {
        [self ysc_removeObserver:observer forKeyPath:keyPath context:context];
    }
}

// 自定义 removeObserver:forKeyPath: 实现方法
- (void)ysc_removeObserver:(NSObject *)observer
                forKeyPath:(NSString *)keyPath {
    
    if (!isSystemClass(self.class)) {
        if ([self.yscKVOProxy removeInfoInMapWithObserver:observer forKeyPath:keyPath]) {
            // 如果移除 KVO 信息操作成功，则调用系统移除方法
            [self ysc_removeObserver:self.yscKVOProxy forKeyPath:keyPath];
        } else {
            // 移除 KVO 信息操作失败：移除了未注册的观察者
            NSString *className = NSStringFromClass(self.class) == nil ? @"" : NSStringFromClass(self.class);
            NSString *reason = [NSString stringWithFormat:@"*** Crash Message: Cannot remove an observer %@ for the key path '%@' from %@ , because it is not registered as an observer ***", observer, keyPath, className];
            NSLog(@"%@",reason);
        }
    } else {
        [self ysc_removeObserver:observer forKeyPath:keyPath];
    }
    
}

// 自定义 dealloc 实现方法
- (void)ysc_kvodealloc {
    @autoreleasepool {
        if (!isSystemClass(self.class)) {
            NSString *value = (NSString *)objc_getAssociatedObject(self, KVODefenderKey);
            if ([value isEqualToString:KVODefenderValue]) {
                NSArray *keyPaths =  [self.yscKVOProxy getAllKeyPaths];
                // 被观察者在 dealloc 时仍然注册着 KVO
                if (keyPaths.count > 0) {
                    NSString *reason = [NSString stringWithFormat:@"*** Crash Message: An instance %@ was deallocated while key value observers were still registered with it. The Keypaths is:'%@' ***", self, [keyPaths componentsJoinedByString:@","]];
                    NSLog(@"%@",reason);
                }
                
                // 移除多余的观察者
                for (NSString *keyPath in keyPaths) {
                    [self ysc_removeObserver:self.yscKVOProxy forKeyPath:keyPath];
                }
            }
        }
    }
    
    [self ysc_kvodealloc];
}

@end
