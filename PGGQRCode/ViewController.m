//
//  ViewController.m
//  PGGQRCode
//
//  Created by 陈鹏 on 2017/10/20.
//  Copyright © 2017年 penggege.CP. All rights reserved.
    //GitHub地址    https://github.com/penghero/PGGQRCode.git


#import "ViewController.h"
#import "PGGCodeGenerate.h"
#import "PGGCodeScanning.h"
#import <AVFoundation/AVFoundation.h>

#define dataArr @[@"二维码生成",@"二维码扫描"]
static NSString *SSID = @"UITableViewCell_ID";
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self customNavigation];
    [self.view addSubview:self.tableView];
}
- (void)customNavigation{
    self.navigationItem.title =@"二维码";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    UIBarButtonItem * backButtonItem = [[UIBarButtonItem alloc] init];
    backButtonItem.title = nil;
    self.navigationItem.backBarButtonItem = backButtonItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor grayColor];
}
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = [UIColor whiteColor];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
#pragma 数据源
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SSID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SSID];
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor lightGrayColor];
    cell.textLabel.text = dataArr[indexPath.row];
    return cell;
}

#pragma 代理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:{
            PGGCodeGenerate *generate = [PGGCodeGenerate new];
            [self.navigationController pushViewController:generate animated:YES];
            break;
        }
        case 1:{
//             获取摄像设备
            AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            if (device) {
                AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                if (status == AVAuthorizationStatusNotDetermined) {
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                        if (granted) {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                PGGCodeScanning *scan = [PGGCodeScanning new];
                                [self.navigationController pushViewController:scan animated:YES];
                            });
                                // 用户第一次同意了访问相机权限
                            NSLog(@"用户第一次同意了访问相机权限 - - %@", [NSThread currentThread]);
                            
                        } else {
                                // 用户第一次拒绝了访问相机权限
                            NSLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
                        }
                    }];
                } else if (status == AVAuthorizationStatusAuthorized) { // 用户允许当前应用访问相机
                    PGGCodeScanning *scan = [PGGCodeScanning new];
                    [self.navigationController pushViewController:scan animated:YES];
                } else if (status == AVAuthorizationStatusDenied) { // 用户拒绝当前应用访问相机
                    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请去-> [设置 - 隐私 - 相机 - SGQRCodeExample] 打开访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
                    UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    [alertC addAction:alertA];
                    [self presentViewController:alertC animated:YES completion:nil];
                } else if (status == AVAuthorizationStatusRestricted) {
                    NSLog(@"因为系统原因, 无法访问相册");
                }
            } else {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alertC addAction:alertA];
                [self presentViewController:alertC animated:YES completion:nil];
            }
            break;
        }
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
