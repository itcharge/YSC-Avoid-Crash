//
//  TestKVOCrashVC.m
//  YSC-Avoid-Crash
//
//  Created by WalkingBoy on 2019/9/4.
//  Copyright © 2019 bujige. All rights reserved.
//

#import "TestKVOCrashVC.h"
#import "KVOCrashObject.h"

@interface TestKVOCrashVC ()

@property (nonatomic, strong) KVOCrashObject *objc;

@end

@implementation TestKVOCrashVC
{
    NSArray *_titleArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupDataSource];
    
    [self setupUI];
    
}


- (void)setupDataSource {
    _titleArray = @[
                    @"1.1 移除了未注册的观察者",
                    @"1.2 重复移除多次，移除次数多于添加次数",
                    @"1.3 重复添加多次，被观察多次。",
                    @"2. 被观察者 dealloc 时仍然注册着 KVO",
                    @"3. 观察者没有实现观察方法",
                    @"4. 添加或者移除时 keypath == nil"
                    ];
    
    self.objc = [[KVOCrashObject alloc] init];
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
            [self testKVOCrash11];
        }
            break;
        case 1001: {
            [self testKVOCrash12];
        }
            break;
        case 1002: {
            [self testKVOCrash13];
        }
            break;
        case 1003: {
            [self testKVOCrash2];
        }
            break;
        case 1004: {
            [self testKVOCrash3];
        }
            break;
        case 1005: {
            [self testKVOCrash4];
        }
        default:
            break;
    }
}


/**
 1.1 移除了未注册的观察者，导致崩溃
 */
- (void)testKVOCrash11 {
    // 崩溃日志：Cannot remove an observer XXX for the key path "xxx" from XXX because it is not registered as an observer.
    [self.objc removeObserver:self forKeyPath:@"name"];
}

/**
 1.2 重复移除多次，移除次数多于添加次数，导致崩溃
 */
- (void)testKVOCrash12 {
    // 崩溃日志：Cannot remove an observer XXX for the key path "xxx" from XXX because it is not registered as an observer.
    [self.objc addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    self.objc.name = @"0";
    [self.objc removeObserver:self forKeyPath:@"name"];
    [self.objc removeObserver:self forKeyPath:@"name"];
}

/**
 1.3 重复添加多次，虽然不会崩溃，但是发生改变时，也同时会被观察多次。
 */
- (void)testKVOCrash13 {
    [self.objc addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    [self.objc addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    self.objc.name = @"0";
}

/**
 2. 被观察者 dealloc 时仍然注册着 KVO，导致崩溃
 */
- (void)testKVOCrash2 {
    // 崩溃日志：An instance xxx of class xxx was deallocated while key value observers were still registered with it.
    // iOS 10 及以下会导致崩溃，iOS 11 之后就不会崩溃了
    KVOCrashObject *obj = [[KVOCrashObject alloc] init];
    [obj addObserver: self
          forKeyPath: @"name"
             options: NSKeyValueObservingOptionNew
             context: nil];
}

/**
 3. 观察者没有实现 -observeValueForKeyPath:ofObject:change:context:导致崩溃
 */
- (void)testKVOCrash3 {
    // 崩溃日志：An -observeValueForKeyPath:ofObject:change:context: message was received but not handled.
    KVOCrashObject *obj = [[KVOCrashObject alloc] init];
    
    [self addObserver: obj
           forKeyPath: @"title"
              options: NSKeyValueObservingOptionNew
              context: nil];
    
    self.title = @"111";
}

/**
 4. 添加或者移除时 keypath == nil，导致崩溃。
 */
- (void)testKVOCrash4 {
    // 崩溃日志： -[__NSCFConstantString characterAtIndex:]: Range or index out of bounds
    KVOCrashObject *obj = [[KVOCrashObject alloc] init];
    
    [self addObserver: obj
           forKeyPath: @""
              options: NSKeyValueObservingOptionNew
              context: nil];
    
    //    [self removeObserver:obj forKeyPath:@""];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context {
    
    NSLog(@"object = %@, keyPath = %@", object, keyPath);
}

@end
