//
//  ViewController.m
//  YSC-Avoid-Crash
//
//  Created by WalkingBoy on 2019/8/15.
//  Copyright © 2019 bujige. All rights reserved.
//

#import "ViewController.h"
#import "KVOCrashObjc.h"
#import "YSCObject.h"

@interface ViewController ()

/* <#注释#> */
@property (nonatomic, strong) KVOCrashObjc *objcc;

/* <#注释#> */
@property (nonatomic, copy) NSString *test;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [YSCObject aClassFunc];
    
    [[[YSCObject alloc] init] object];
    
    self.objcc = [[KVOCrashObjc alloc] init];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    
    [self func2];
    
}

/**
 观察者是局部变量，会崩溃
 */
- (void)func1 {
    // 崩溃日志：An -observeValueForKeyPath:ofObject:change:context: message was received but not handled.
    KVOCrashObjc *obj = [[KVOCrashObjc alloc] init];
    
    [self addObserver:obj  forKeyPath:@"test"  options:NSKeyValueObservingOptionNew
              context:nil];
    
    self.test = @"111";
}
/**
 被观察者是局部变量，会崩溃
 */
- (void)func2 {
    // 崩溃日志：An -observeValueForKeyPath:ofObject:change:context: message was received but not handled.
    KVOCrashObjc *obj = [[KVOCrashObjc alloc] init];
    [obj addObserver:self          forKeyPath:@"name" options:NSKeyValueObservingOptionNew
             context:nil];
    obj.name = @"";
}
/**
 没有实现observeValueForKeyPath:ofObject:changecontext:方法:，会崩溃
 */
- (void)func3 {
    // 崩溃日志：An -observeValueForKeyPath:ofObject:change:context: message was received but not handled.
    [self.objcc addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    self.objcc.name = @"0";
}
/**
 重复移除观察者，会崩溃
 */
- (void)func4 {
    // 崩溃日志：because it is not registered as an observer
    [self.objcc addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    self.objcc.name = @"0";
    [self.objcc removeObserver:self forKeyPath:@"name"];
    [self.objcc removeObserver:self forKeyPath:@"name"];
}
/**
 重复添加观察者，不会崩溃，但是添加多少次，一次改变就会被观察多少次
 */
- (void)func5 {
    [self.objcc addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    [self.objcc addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    self.objcc.name = @"0";
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context {


    NSLog(@"keyPath = %@", keyPath);
}


@end
