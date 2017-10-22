//
//  PGGCodeScanning.m
//  PGGQRCode
//
//  Created by 陈鹏 on 2017/10/20.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//GitHub地址    https://github.com/penghero/PGGQRCode.git

#import "PGGCodeScanning.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "SacnView.h"
#import "ScanningResult.h"

#define    kScreen_Width [UIScreen mainScreen].bounds.size.width
#define    kScreen_Height [UIScreen mainScreen].bounds.size.height
@interface PGGCodeScanning ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    BOOL isopen;
}
@property ( strong , nonatomic ) AVCaptureDevice * device;                                      //捕获设备，默认后置摄像头
@property ( strong , nonatomic ) AVCaptureDeviceInput * input;                               //输入设备
@property ( strong , nonatomic ) AVCaptureMetadataOutput * output;                     //输出设备，需要指定他的输出类型及扫描范围
@property ( strong , nonatomic ) AVCaptureSession * session;                                   //AVFoundation框架捕获类的中心枢纽，协调输入输出设备以获得数据
@property ( strong , nonatomic ) AVCaptureVideoPreviewLayer * previewLayer;       //展示捕获图像的图层，是CALayer的子类
@property (nonatomic,strong)UIView *scanView ;                                                       //定位扫描框在哪个位置
@property (nonatomic,strong) UIButton *open;                                                           //打开手电按钮
@property (nonatomic,strong) UILabel *explainLabel;                                                  //说明Label
@property (nonatomic,strong) NSString *magString;
@end

@implementation PGGCodeScanning
-(UILabel *)explainLabel{
    if (_explainLabel == nil) {
        _explainLabel = [[UILabel alloc ] initWithFrame:CGRectMake(0,( kScreen_Height - 400)/2, kScreen_Width, 30)];
        _explainLabel.backgroundColor = [UIColor clearColor];
        _explainLabel.textColor = [UIColor whiteColor];
        _explainLabel.textAlignment = NSTextAlignmentCenter;
        _explainLabel.text = @"请将二维码／条形码放入扫描框内进行扫描";
    }
    return _explainLabel;
}

- (UIButton *)open{
    if (_open == nil) {
        _open = [[UIButton alloc] initWithFrame:CGRectMake((kScreen_Width - 200)/2, (self.view.frame.size.height-200), 200, 50)];
        if (isopen) {
            [_open setTitle:@"关闭手电" forState:UIControlStateNormal];
        } else {
            [_open setTitle:@"打开手电" forState:UIControlStateNormal];
        }
        _open.backgroundColor = [UIColor clearColor] ;
        [_open setTintColor:[UIColor whiteColor]];
        [_open addTarget:self action:@selector(openLighe) forControlEvents:UIControlEventTouchUpInside];
    }
    return _open;
}
- (void)openLighe{
    if (isopen == YES) {
        isopen = NO;
        [self openFlashlight];
        [_open setTitle:@"关闭手电" forState:UIControlStateNormal];
    } else {
        isopen = YES;
        [self CloseFlashlight];
        [_open setTitle:@"打开手电" forState:UIControlStateNormal];
    }
}
/** 打开手电筒 */
- (void)openFlashlight {
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    if ([captureDevice hasTorch]) {
        BOOL locked = [captureDevice lockForConfiguration:&error];
        if (locked) {
            captureDevice.torchMode = AVCaptureTorchModeOn;
            [captureDevice unlockForConfiguration];
        }
    }
}
/** 关闭手电筒 */
- (void)CloseFlashlight {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}
- (AVCaptureDevice *)device
{
    if (_device == nil) {
            // 设置AVCaptureDevice的类型为Video类型
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;
}

- (AVCaptureDeviceInput *)input
{
    if (_input == nil) {
            //输入设备初始化
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    return _input;
}
- (AVCaptureMetadataOutput *)output
{
    if (_output == nil) {
            //初始化输出设备
        _output = [[AVCaptureMetadataOutput alloc] init];
            // 1.获取屏幕的frame
        CGRect viewRect = self.view.frame;
            // 2.获取扫描容器的frame
        CGRect containerRect = self.scanView.frame;
        CGFloat x = containerRect.origin.y / viewRect.size.height;
        CGFloat y = containerRect.origin.x / viewRect.size.width;
        CGFloat width = containerRect.size.height / viewRect.size.height;
        CGFloat height = containerRect.size.width / viewRect.size.width;
            //rectOfInterest属性设置设备的扫描范围
        _output.rectOfInterest = CGRectMake(x, y, width, height);
    }
    return _output;
}
- (AVCaptureSession *)session
{
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if (_previewLayer == nil) {
            //负责图像渲染出来
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:(UIBarButtonItemStyleDone) target:self action:@selector(openXC)];
    self.navigationItem.title = @"二维码扫描";
    isopen = NO;
    //定位扫描框在屏幕正中央，并且宽高为200的正方形
    self.scanView = [[UIView alloc]initWithFrame:CGRectMake((kScreen_Width-200)/2, (self.view.frame.size.height-200)/2, 200, 200)];
    [self.view addSubview:self.scanView];
    //设置扫描界面（包括扫描界面之外的部分置灰，扫描边框等的设置）,后面设置
     SacnView *clearView = [[SacnView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:clearView];
    [self.view addSubview:self.explainLabel];
    [self.view addSubview:self.open];
    [self startScan];
}
    //打开相册方法
- (void)openXC{
    [self JudgmentAuthority];
}
- (void)JudgmentAuthority {
        // 1、 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
            // 判断授权状态
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) { // 用户还没有做出选择
                // 弹框请求用户授权
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) { // 用户第一次同意了访问相册权限
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self enterImagePickerController];
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
            [self enterImagePickerController];
        } else if (status == PHAuthorizationStatusDenied) { // 用户拒绝当前应用访问相册
            [self enterImagePickerController];
        } else if (status == PHAuthorizationStatusRestricted) {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"由于系统原因, 无法访问相册" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertC addAction:alertA];
            [self.navigationController presentViewController:alertC animated:YES completion:nil];
        }
    }
}
    // 进入 UIImagePickerController
- (void)enterImagePickerController {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

- (void)startScan
{
        // 1.判断输入能否添加到会话中
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
        // 2.判断输出能够添加到会话中
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
            //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        NSMutableArray *a = [[NSMutableArray alloc] init];
        if ([self.output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            [a addObject:AVMetadataObjectTypeQRCode];
        }
        if ([self.output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
            [a addObject:AVMetadataObjectTypeEAN13Code];
        }
        if ([self.output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
            [a addObject:AVMetadataObjectTypeEAN8Code];
        }
        if ([self.output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [a addObject:AVMetadataObjectTypeCode128Code];
        }
        self.output.metadataObjectTypes=a;
    }
    //  3. 设置精准识别
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    // 4.设置监听监听输出解析到的数据
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];    
    // 5.添加预览图层
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    self.previewLayer.frame = self.view.bounds;
    // 6.开始扫描
    [self.session startRunning];
}
//扫描结果处理
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    [self.session stopRunning];
    if (metadataObjects.count>0) {
        [self.session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex :0];
            //输出扫描字符串
        NSString *str_code = metadataObject.stringValue;
        ScanningResult *result = [ScanningResult new];
        result.result_URL = str_code;
        [self.navigationController pushViewController:result animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [self.session startRunning];
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
        // 对选取照片的处理，如果选取的图片尺寸过大，则压缩选取图片，否则不作处理
    UIImage *image = [PGGCodeScanning imageSizeWithScreenImage:info[UIImagePickerControllerOriginalImage]];
        // CIDetector(CIDetector可用于人脸识别)进行图片解析，从而使我们可以便捷的从相册中获取到二维码
        // 声明一个 CIDetector，并设定识别类型 CIDetectorTypeQRCode
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
        // 取得识别结果
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count == 0) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    } else {
        for (int index = 0; index < [features count]; index ++) {
            CIQRCodeFeature *feature = [features objectAtIndex:index];
            NSString *resultStr = feature.messageString;
            self.magString = resultStr;
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [self codeResultXC_url:self.magString];
        }];
    }
}
- (void)codeResultXC_url:(NSString *)str {
    ScanningResult *result = [ScanningResult new];
    result.result_URL = str;
    [self.navigationController pushViewController:result animated:YES];
}
+ (UIImage *)imageSizeWithScreenImage:(UIImage *)image {
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat screenWidth = kScreen_Width;
    CGFloat screenHeight = kScreen_Height;
    if (imageWidth <= screenWidth && imageHeight <= screenHeight) {
        return image;
    }
    CGFloat max = MAX(imageWidth, imageHeight);
    CGFloat scale = max / (screenHeight * 2.0);
    CGSize size = CGSizeMake(imageWidth / scale, imageHeight / scale);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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
