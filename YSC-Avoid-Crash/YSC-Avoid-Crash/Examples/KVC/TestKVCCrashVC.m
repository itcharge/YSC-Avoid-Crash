//
//  TestKVCCrashVC.m
//  YSC-Avoid-Crash
//
//  Created by WalkingBoy on 2019/9/4.
//  Copyright © 2019 bujige. All rights reserved.
//

#import "TestKVCCrashVC.h"
#import "KVCCrashObject.h"

@interface TestKVCCrashVC ()

@end

@implementation TestKVCCrashVC
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
                    @"1. key 不是对象的属性",
                    @"2. keyPath 不正确",
                    @"3. key 为 nil",
                    @"4. value 为 nil，为非对象设值"
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
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
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
            [self testKVCCrash1];
        }
            break;
        case 1001: {
            [self testKVCCrash2];
        }
            break;
        case 1002: {
            [self testKVCCrash3];
        }
            break;
        case 1003: {
            [self testKVCCrash4];
        }
            break;
        default:
            break;
    }
}

/**
 1. key 不是对象的属性，造成崩溃
 */
- (void)testKVCCrash1 {
    // 崩溃日志：[<KVCCrashObject 0x600000d48ee0> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key XXX.;
    
    KVCCrashObject *objc = [[KVCCrashObject alloc] init];
    [objc setValue:@"value" forKey:@"address"];
}

/**
 2. keyPath 不正确，造成崩溃
 */
- (void)testKVCCrash2 {
    // 崩溃日志：[<KVCCrashObject 0x60000289afb0> valueForUndefinedKey:]: this class is not key value coding-compliant for the key XXX.
    
    KVCCrashObject *objc = [[KVCCrashObject alloc] init];
    [objc setValue:@"后厂村路" forKeyPath:@"address.street"];
}

/**
 3. key 为 nil，造成崩溃
 */
- (void)testKVCCrash3 {
    // 崩溃日志：'-[KVCCrashObject setValue:forKey:]: attempt to set a value for a nil key
    
    NSString *keyName;
    // key 为 nil 会崩溃，如果传 nil 会提示警告，传空变量则不会提示警告
    
    KVCCrashObject *objc = [[KVCCrashObject alloc] init];
    [objc setValue:@"value" forKey:keyName];
}

/**
 4. value 为 nil，造成崩溃
 */
- (void)testKVCCrash4 {
    // 崩溃日志：[<KVCCrashObject 0x6000028a6780> setNilValueForKey]: could not set nil as the value for the key XXX.
    
    // value 为 nil 会崩溃
    KVCCrashObject *objc = [[KVCCrashObject alloc] init];
    [objc setValue:nil forKey:@"age"];
}

@end
