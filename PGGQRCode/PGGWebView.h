//
//  PGGWebView.h
//  PGGQRCode
//
//  Created by 陈鹏 on 2017/10/22.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//GitHub地址    https://github.com/penghero/PGGQRCode.git
/*
 对WKWebView二次封装
 */
#import <UIKit/UIKit.h>
@class PGGWebView;
@protocol PGGWebViewDelegate <NSObject>
@optional
// 开始加载
- (void)webViewDidStartLoad:(PGGWebView *)webView;
//开始返回
- (void)webView:(PGGWebView *)webView didCommitWithURL:(NSURL *)url;
 //加载完成
- (void)webView:(PGGWebView *)webView didFinishWithURL:(NSURL *)url;
//加载失败
- (void)webView:(PGGWebView *)webView didFailWithError:(NSError *)error;

@end

@interface PGGWebView : UIView

//Delegate
@property (nonatomic, weak) id<PGGWebViewDelegate> PGGQRCodeDelegate;
//进度条颜色
@property (nonatomic, strong) UIColor *progressViewColor;
//导航栏标题
@property (nonatomic, copy) NSString *navigationItemTitle;
//判断是否存在导航控制器
@property (nonatomic,assign) BOOL isExistenceNav;
//创建
+ (instancetype)setWebViewWithFrame:(CGRect)frame;
//加载 web
- (void)loadRequest:(NSURLRequest *)request;
//加载 HTML
- (void)loadHTMLString:(NSString *)HTMLString;
//刷新数据
- (void)reloadData;

@end
