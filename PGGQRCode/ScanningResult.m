//
//  ScanningResult.m
//  PGGQRCode
//
//  Created by 陈鹏 on 2017/10/22.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//GitHub地址    https://github.com/penghero/PGGQRCode.git

#import "ScanningResult.h"
#import "PGGWebView.h"
#define web_W  [UIScreen mainScreen].bounds.size.width
#define web_H  [UIScreen mainScreen].bounds.size.height


@interface ScanningResult ()<PGGWebViewDelegate>
@property (nonatomic,strong) PGGWebView *pggWebView;
@end

@implementation ScanningResult

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createNav];
    [self startResultURL];
}
- (PGGWebView *)pggWebView {
    if (_pggWebView == nil) {
        _pggWebView = [PGGWebView setWebViewWithFrame:CGRectMake(0, 0, web_W, web_H)];
        [_pggWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.result_URL]]];
        _pggWebView.PGGQRCodeDelegate = self;
    }
    return _pggWebView;
}
- (void)createNav{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    self.navigationItem.title = @"扫描结果";
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)refresh {
    [self.pggWebView reloadData];
}
- (void)startResultURL{
    if (![self.result_URL hasPrefix:@"http"]) {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"扫描结果" message:self.result_URL preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alertC addAction:alertA];
        [self.navigationController presentViewController:alertC animated:YES completion:nil];
    }else{
        [self.view addSubview:self.pggWebView];
    }
}
#pragma mark - PGGWebViewDelegate
- (void)webView:(PGGWebView *)webView didFinishWithURL:(NSURL *)url {
    NSLog(@"加载完成!");
    self.navigationItem.title = webView.navigationItemTitle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
