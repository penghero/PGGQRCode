//
//  PGGWebView.m
//  PGGQRCode
//
//  Created by 陈鹏 on 2017/10/22.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//GitHub地址    https://github.com/penghero/PGGQRCode.git

#import "PGGWebView.h"
#import <WebKit/WebKit.h>
@interface PGGWebView()<WKUIDelegate,WKNavigationDelegate>
//WKWebView
@property (nonatomic, strong) WKWebView *wkWebView;
//进度条
@property (nonatomic, strong) UIProgressView *progressView;

@end
static NSUInteger const navHeight = 64;
static NSInteger const progressViewWeight = 2;
@implementation PGGWebView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.wkWebView];
        [self addSubview:self.progressView];
    }
    return self;
}
+(instancetype)setWebViewWithFrame:(CGRect)frame {
    return [[self alloc] initWithFrame:frame];
}
- (WKWebView *)wkWebView {
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc] initWithFrame:self.bounds];
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
        [self.wkWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:nil];
    }
    return _wkWebView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.trackTintColor = [UIColor clearColor];
        _progressView.frame = CGRectMake(0, navHeight, self.frame.size.width, progressViewWeight);
        _progressView.tintColor = [UIColor redColor];
    }
    return _progressView;
}
- (void)setProgressViewColor:(UIColor *)progressViewColor {
    _progressViewColor = progressViewColor;
    if (progressViewColor) {
        _progressView.tintColor = progressViewColor;
    }
}
- (void)setIsExistenceNav:(BOOL)isExistenceNav {
    _isExistenceNav = isExistenceNav;
    if (isExistenceNav) {
        _progressView.frame = CGRectMake(0, navHeight, self.frame.size.width, progressViewWeight);
    }else{
        _progressView.frame = CGRectMake(0, 0, self.frame.size.width, progressViewWeight);
    }
}
//监听进度
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.wkWebView) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.wkWebView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.wkWebView.estimatedProgress animated:animated];
        if (self.wkWebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.2f delay:0.2f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.progressView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark -WKNavigationDelegate
//     页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if (self.PGGQRCodeDelegate && [self.PGGQRCodeDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.PGGQRCodeDelegate webViewDidStartLoad:self];
    }
    self.progressView.alpha = 1.0f;
}
//     当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    if (self.PGGQRCodeDelegate && [self.PGGQRCodeDelegate respondsToSelector:@selector(webView:didCommitWithURL:)]) {
        [self.PGGQRCodeDelegate webView:self didCommitWithURL:self.wkWebView.URL];
    }
    self.navigationItemTitle = self.wkWebView.title;
}
//     页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.navigationItemTitle = self.wkWebView.title;
    if (self.PGGQRCodeDelegate && [self.PGGQRCodeDelegate respondsToSelector:@selector(webView:didFinishLoadWithURL:)]) {
        [self.PGGQRCodeDelegate webView:self didFinishWithURL:self.wkWebView.URL];
    }
    
    self.progressView.alpha = 0.0f;
}
//     页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (self.PGGQRCodeDelegate && [self.PGGQRCodeDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.PGGQRCodeDelegate webView:self didFailWithError:error];
    }
    self.progressView.alpha = 0.0f;
}
//    加载 web
- (void)loadRequest:(NSURLRequest *)request {
    [self.wkWebView loadRequest:request];
}
//     加载 HTML
- (void)loadHTMLString:(NSString *)HTMLString {
    [self.wkWebView loadHTMLString:HTMLString baseURL:nil];
}
//     刷新数据
- (void)reloadData {
    [self.wkWebView reload];
}

    /// dealloc
- (void)dealloc {
    [self.wkWebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
}

@end
