 //
//  NSObject+KVODefender.h
//  YSC-Avoid-Crash
//
//  Created by WalkingBoy on 2019/8/19.
//  Copyright © 2019 bujige. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KVODefenderEasy)

@property (nonatomic,strong) NSHashTable *kvoHashTable;

@end

NS_ASSUME_NONNULL_END
