//
//  SacnView.h
//  PGGQRCode
//
//  Created by 陈鹏 on 2017/10/21.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//GitHub地址    https://github.com/penghero/PGGQRCode.git


#import <UIKit/UIKit.h>

/**
 扫描框View
 */
@interface SacnView : UIView
{
    CGFloat sceenHeight;
    NSTimer *timer;
    CGRect  scanRect;
    CGFloat kScreen_Width;
    CGFloat kScreen_Height;
}

@property (nonatomic,assign)CGFloat lineWidth;
@property (nonatomic,assign)CGFloat height;
@property (nonatomic,strong)UIColor  *lineColor;
@property (nonatomic, assign)CGFloat scanTime;

@end
