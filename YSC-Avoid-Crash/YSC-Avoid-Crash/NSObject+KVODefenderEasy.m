//
//  NSObject+KVODefender.m
//  YSC-Avoid-Crash
//
//  Created by WalkingBoy on 2019/8/19.
//  Copyright © 2019 bujige. All rights reserved.
//

#import "NSObject+KVODefenderEasy.h"
#import "NSObject+MethodSwizzling.h"
#import <objc/runtime.h>

static char KVOHashTableKey;

@implementation NSObject (KVODefenderEasy)


//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        
//        // 拦截 `addObserver:forKeyPath:options:context:` 方法，替换自定义实现
//        [NSObject yscDefenderSwizzlingInstanceMethod: @selector(addObserver:forKeyPath:options:context:) withMethod: @selector(ysc_easy_addObserver:forKeyPath:options:context:) withClass: [NSObject class]];
//        
//        // 拦截 `removeObserver:forKeyPath:` 方法，替换自定义实现
//        [NSObject yscDefenderSwizzlingInstanceMethod: @selector(removeObserver:forKeyPath:) withMethod:@selector(ysc_easy_removeObserver:forKeyPath:) withClass: [NSObject class]];
//        
//        // 拦截 `removeObserver:forKeyPath:context:` 方法，替换自定义实现
//        [NSObject yscDefenderSwizzlingInstanceMethod: @selector(removeObserver:forKeyPath:context:) withMethod: @selector(ysc_easy_removeObserver:forKeyPath:context:) withClass: [NSObject class]];
//        
//        // 拦截 `observeValueForKeyPath:ofObject:change:context:` 方法，替换自定义实现
//        [NSObject yscDefenderSwizzlingInstanceMethod: @selector(observeValueForKeyPath:ofObject:change:context:) withMethod: @selector(ysc_easy_observeValueForKeyPath:ofObject:change:context:) withClass:[NSObject class]];
//    });
//}

- (void)ysc_easy_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    if (!observer || !keyPath ||
        ([keyPath isKindOfClass:[NSString class]] && keyPath.length <= 0)) {
        return;
    }
    
    @synchronized (self) {
        NSUInteger KVOHash = [self ysc_easy_hashOfObserver:observer keyPath:keyPath];
        if (!self.kvoHashTable) {
            self.kvoHashTable = [NSHashTable hashTableWithOptions:(NSPointerFunctionsStrongMemory)];
        }
        
        if (![self.kvoHashTable containsObject:@(KVOHash)]) {
            [self.kvoHashTable addObject:@(KVOHash)];
            [self ysc_easy_addObserver:observer forKeyPath:keyPath options:options context:context];
        }
    }
}

- (void)ysc_easy_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context {
    [self removeObserver:observer forKeyPath:keyPath];
}

- (void)ysc_easy_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    if (!observer || !keyPath ||
        ([keyPath isKindOfClass:[NSString class]] && keyPath.length <= 0)) {
        return;
    }
    
    @synchronized (self) {
        NSUInteger KVOHash = [self ysc_easy_hashOfObserver:observer keyPath:keyPath];
        NSHashTable *hashTable = [self kvoHashTable];
        if (!hashTable) {
            return;
        }
        if ([hashTable containsObject:@(KVOHash)]) {
            [self ysc_easy_removeObserver:observer forKeyPath:keyPath];
            [hashTable removeObject:@(KVOHash)];
        }
    }
}

- (NSInteger)ysc_easy_hashOfObserver:(NSObject *)observer keyPath:(NSString *)keyPath {
    NSArray *KVOContentArr = @[observer,keyPath];
    NSInteger hash = [KVOContentArr hash];
    
    return hash;
}

- (void)ysc_easy_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    @try {
        [self ysc_easy_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    } @catch (NSException *exception) {
        NSString *reason = [NSString stringWithFormat:@"non fatal Error%@",[exception description]];
        NSLog(@"reson = %@",reason);
    }
}

- (void)setKvoHashTable:(NSHashTable *)kvoHashTable {
    objc_setAssociatedObject(self, &KVOHashTableKey, kvoHashTable, OBJC_ASSOCIATION_RETAIN);
}


- (NSHashTable *)kvoHashTable {
    return objc_getAssociatedObject(self, &KVOHashTableKey);
}

@end
