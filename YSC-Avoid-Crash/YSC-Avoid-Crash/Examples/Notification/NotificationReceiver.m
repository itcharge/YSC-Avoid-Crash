//
//  NotificationReceiver.m
//  YSC-Avoid-Crash
//
//  Created by WalkingBoy on 2019/9/3.
//  Copyright © 2019 bujige. All rights reserved.
//

#import "NotificationReceiver.h"

@implementation NotificationReceiver

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"loadingCompelete" object:nil];
    }
    return self;
}

- (void)receiveNotification:(NSNotification*)noti {
    int page = [noti.userInfo[@"page"] intValue];
    NSLog(@"%d",page);
}

- (void)dealloc {
    NSLog(@"dealloc");
}
@end
