//
//  TestUnrecognizedSelVC.m
//  YSC-Avoid-Crash
//
//  Created by WalkingBoy on 2019/9/4.
//  Copyright © 2019 bujige. All rights reserved.
//

#import "TestUnrecognizedSelVC.h"
#import "SelectorObject.h"

@interface TestUnrecognizedSelVC ()

@end

@implementation TestUnrecognizedSelVC
{
    NSArray *_titleArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDataSource];
    
    [self setupUI];
}

- (void)setupDataSource {
    _titleArray = @[
                    @"找不到 button 响应事件",
                    @"找不到控制器中的方法",
                    @"找不到对象方法",
                    @"找不到类方法",
                    @"调用 null 对象的方法",
                    ];
}

- (void)setupUI {
    CGFloat buttonWidth = (UIScreenWidth-60);
    CGFloat buttonHeight = 44;
    CGFloat buttonSpace = 30;
    CGFloat buttonGap = 10;
    for (int i = 0; i < _titleArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 1000+i;
        [button setTitle:_titleArray[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        button.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        button.frame = CGRectMake(buttonSpace, 60+(buttonHeight+buttonGap)*i, buttonWidth, buttonHeight);
        if (i == 0) {
            [button addTarget:self action:@selector(undefinedButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        button.layer.cornerRadius = 5;
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.backgroundColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        [self.view addSubview:button];
    }
}

- (void)buttonClick:(UIButton *)button {
    NSInteger buttonTag = button.tag;
    switch (buttonTag) {
        case 1000: {
            
        }
            break;
        case 1001: {
            [self performSelector:@selector(undefinedVCSelector)];
        }
            break;
        case 1002: {
            SelectorObject *object = [[SelectorObject alloc] init];
            [object instanceFunc];
        }
            break;
        case 1003: {
            [SelectorObject classFunc];
        }
            break;
        case 1004: {
            [[NSNull null] performSelector:@selector(undefinedSelector)];
        }
            break;
        default:
            break;
    }
}


@end
