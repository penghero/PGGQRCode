//
//  PGGCodeGenerate.m
//  PGGQRCode
//
//  Created by 陈鹏 on 2017/10/20.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//GitHub地址    https://github.com/penghero/PGGQRCode.git

#import "PGGCodeGenerate.h"
#import "Masonry.h"
#import <Photos/Photos.h>

@interface PGGCodeGenerate ()
@property (nonatomic,strong) UITextView *input;
@property (nonatomic,strong) UIButton *generateCode;
@property (nonatomic,strong) UIImageView * codeImg;
@property (nonatomic,strong) UIView *codoBG;
@property (nonatomic,strong) UIImage *saveImg;
@end

@implementation PGGCodeGenerate

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"二维码生成";
    [self.view addSubview:self.input];
    [self.view addSubview:self.generateCode];
    [self ViewInit];

}
//将生成的二维码图片保存至本地相册中
- (void)save{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
//             判断授权状态
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) { // 用户还没有做出选择
//                 弹框请求用户授权
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) { // 用户第一次同意了访问相册权限
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self saveImageToPhotos:self.saveImg];
                    });
                } else { // 用户第一次拒绝了访问相机权限
                    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"由于您拒绝了访问, 故无法访问相册" preferredStyle:(UIAlertControllerStyleAlert)];
                    UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    [alertC addAction:alertA];
                    [self.navigationController presentViewController:alertC animated:YES completion:nil];
                }
            }];
        } else if (status == PHAuthorizationStatusAuthorized) { // 用户允许当前应用访问相册
            [self saveImageToPhotos:self.saveImg];
        } else if (status == PHAuthorizationStatusDenied) { // 用户拒绝当前应用访问相册
        } else if (status == PHAuthorizationStatusRestricted) {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"由于系统原因, 无法访问相册" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertC addAction:alertA];
            [self.navigationController presentViewController:alertC animated:YES completion:nil];
        }
    }
}
- (void)saveImageToPhotos:(UIImage*)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:msg preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alertC addAction:alertA];
    [self.navigationController presentViewController:alertC animated:YES completion:nil];
}
-(UIImage *)saveImg{
    if (_saveImg == nil) {
        _saveImg = [UIImage new];
    }
    return _saveImg;
}
- (UITextView *)input{
    if (_input == nil) {
        _input = [UITextView new];
        _input.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_input];
        
        [_input mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(300, 150));
        }];
    }
    return _input;
}

- (UIButton *)generateCode{
    if (_generateCode == nil) {
        _generateCode = [UIButton new];
        [_generateCode setTitle:@"确认生成" forState:UIControlStateNormal];
        [_generateCode setBackgroundColor:[UIColor lightGrayColor]];
        [_generateCode addTarget:self action:@selector(shengba:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_generateCode];
        
        [_generateCode mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.input);
            make.center.equalTo(self.input).with.offset(100);
        }];
    }
    return _generateCode;
}
- (void)shengba:(id)sender{
    self.codoBG.alpha = 1;
    if ([self.input.text isEqualToString:@""]) {
        self.codeImg.image = [self qrImageForString:@"您没有进行输入" imageSize:300 logoImageSize:1];
        self.saveImg = self.codeImg.image;
    }else{
        self.codeImg.image = [self qrImageForString:self.input.text imageSize:300 logoImageSize:1];
        self.saveImg = self.codeImg.image;
    }
}
-(void)ViewInit{
    self.codoBG = [[UIView alloc]initWithFrame:self.view.frame];
    self.codoBG.backgroundColor = [UIColor whiteColor];
    self.codoBG.alpha = 0;
    [self.view addSubview:self.codoBG];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenView)];
    [self.codoBG addGestureRecognizer:tapGestureRecognizer];
    self.codeImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
    self.codeImg.center = self.codoBG.center;
    self.codeImg.image = [self qrImageForString:self.input.text imageSize:300 logoImageSize:1];
    [self.codoBG addSubview:self.codeImg];
}
-(void)hiddenView{
    [UIView animateWithDuration:1 animations:^{
        self.codoBG.alpha = 0;
    }];
}
#pragma mark 生成二维码
/**
 *内容 string
 *大小 imagesize
 *中间logo大小 waterimagesize
 */
- (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)Imagesize logoImageSize:(CGFloat)waterImagesize{
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];//通过kvo方式给一个字符串，生成二维码
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];//设置二维码的纠错水平，越高纠错水平越高，可以污损的范围越大
    CIImage *outPutImage = [filter outputImage];//拿到二维码图片
    return [self  createNonInterpolatedUIImageFormCIImage:outPutImage withSize:Imagesize waterImageSize:waterImagesize];
}

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size waterImageSize:(CGFloat)waterImagesize{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
        // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
        //创建一个DeviceGray颜色空间
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
        //CGBitmapContextCreate(void * _Nullable data, size_t width, size_t height, size_t bitsPerComponent, size_t bytesPerRow, CGColorSpaceRef  _Nullable space, uint32_t bitmapInfo)
        //width：图片宽度像素
        //height：图片高度像素
        //bitsPerComponent：每个颜色的比特值，例如在rgba-32模式下为8
        //bitmapInfo：指定的位图应该包含一个alpha通道。
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
        //创建CoreGraphics image
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef); CGImageRelease(bitmapImage);
    UIImage *outputImage = [UIImage imageWithCGImage:scaledImage];
    [outputImage drawInRect:CGRectMake(0,0 , size, size)];
    UIGraphicsEndImageContext();
    return outputImage;
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
