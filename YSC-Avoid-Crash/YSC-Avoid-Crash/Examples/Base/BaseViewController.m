//
//  BaseViewController.m
//  YSC-Avoid-Crash
//
//  Created by WalkingBoy on 2019/9/4.
//  Copyright © 2019 bujige. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

/* <#注释#> */
@property (nonatomic, strong) UIButton *backButton;

/* <#注释#> */
@property (nonatomic, strong) UITextView *logTextView;
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.logTextView];
    
    [self redirectSTD:STDOUT_FILENO];
    [self redirectSTD:STDERR_FILENO];
}

/**
 * backButton初始化
 */
- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(15, 12, 44, 40);
        _backButton.contentMode = UIViewContentModeLeft;
        [_backButton setTitle:@"返回" forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (void)backButtonClick:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 * logTextView初始化
 */
- (UITextView *)logTextView {
    if (!_logTextView) {
        _logTextView = [[UITextView alloc] initWithFrame:CGRectMake(30, UIScreenHeigh-170, UIScreenWidth-60, 150)];
        [_logTextView setEditable:NO];
        [_logTextView setBackgroundColor:[UIColor lightGrayColor]];
        [_logTextView setTextColor:[UIColor blackColor]];
        [_logTextView setFont:[UIFont systemFontOfSize:15]];
    }
    return _logTextView;
}


- (void)redirectNotificationHandle:(NSNotification *)nf{ // 通知方法
    NSData *data = [[nf userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    self.logTextView.text = [NSString stringWithFormat:@"%@\n\n%@",self.logTextView.text, str]; // logTextView 就是要将日志输出的视图（UITextView）
    NSRange range;
    range.location = [self.logTextView.text length] - 1;
    range.length = 0;
    [self.logTextView scrollRangeToVisible:range];
    [[nf object] readInBackgroundAndNotify];
}

- (void)redirectSTD:(int)fd {
    NSPipe * pipe = [NSPipe pipe] ;// 初始化一个NSPipe 对象
    NSFileHandle *pipeReadHandle = [pipe fileHandleForReading] ;
    dup2([[pipe fileHandleForWriting] fileDescriptor], fd) ;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redirectNotificationHandle:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:pipeReadHandle]; // 注册通知
    [pipeReadHandle readInBackgroundAndNotify];
}


@end
