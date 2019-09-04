//
//  ViewController.m
//  YSC-Avoid-Crash
//
//  Created by WalkingBoy on 2019/8/15.
//  Copyright © 2019 bujige. All rights reserved.
//

#import "ViewController.h"
#import "BaseDefine.h"
#import "NotificationReceiver.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

/* tableView */
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController
{
    NSArray *_titleArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _titleArray = @[
                    @{
                        @"title" : @"Unrecognized Selector Crash",
                        @"class" : @"TestUnrecognizedSelVC"
                        },
                    @{
                        @"title" : @"KVO Crash",
                        @"class" : @"TestKVOCrashVC"
                        },
                    @{
                        @"title" : @"KVC Crash",
                        @"class" : @"TestKVCCrashVC"
                        },
                    @{
                        @"title" : @"Notification Crash",
                        @"class" : @"TestNotificationCrashVC"
                        },
                    @{
                        @"title" : @"NSTimer Crash",
                        @"class" : @"TestTimerCrashVC"
                        },
                    @{
                        @"title" : @"Containers Crash",
                        @"class" : @"TestContainersVC"
                        },
                    @{
                        @"title" : @"NSNull Crash",
                        @"class" : @"TestNullVC"
                        }
                    ];
    
    [self.view addSubview:self.tableView];
    
    @autoreleasepool {
        NotificationReceiver *receiver = [[NotificationReceiver alloc] init];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadingCompelete" object:nil userInfo:@{@"page":@(1)}];
        
        NSLog(@"%@",receiver);
    }

}

/**
 * tableView初始化
 */
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenHeigh) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellID = @"mainCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    }
    cell.textLabel.text = [_titleArray[indexPath.row] objectForKey:@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item =  _titleArray[indexPath.row];
    Class cls = NSClassFromString([item objectForKey:@"class"]);
    [self presentViewController:[[cls alloc] init] animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadingCompelete" object:nil userInfo:@{@"page":@(2)}];
}



@end
