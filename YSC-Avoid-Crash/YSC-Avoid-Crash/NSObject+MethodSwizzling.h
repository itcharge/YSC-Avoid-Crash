//
//  NSObject+MethodSwizzling.h
//  YSC-Avoid-Crash
//
//  Created by WalkingBoy on 2019/8/19.
//  Copyright © 2019 bujige. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MethodSwizzling)

/** 交换两个类方法的实现
 * @param originalSelector  原始方法的 SEL
 * @param swizzledSelector  交换方法的 SEL
 * @param targetClass  类
 */
+ (void)yscDefenderSwizzlingClassMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector withClass:(Class)targetClass;

/** 交换两个对象方法的实现
 * @param originalSelector  原始方法的 SEL
 * @param swizzledSelector 交换方法的 SEL
 * @param targetClass  类
 */
+ (void)yscDefenderSwizzlingInstanceMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector withClass:(Class)targetClass;

@end

NS_ASSUME_NONNULL_END
