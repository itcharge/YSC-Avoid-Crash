//
//  BaseViewController.h
//  YSC-Avoid-Crash
//
//  Created by WalkingBoy on 2019/9/4.
//  Copyright © 2019 bujige. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

- (void)redirectSTD:(int)fd;

@end

NS_ASSUME_NONNULL_END
