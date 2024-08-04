//
//  MNScanVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/5.
//

#import "MNScanVC.h"
#import <AVFoundation/AVFoundation.h>
#import "GC_MyScanVC.h"

#define kQRWith 280
@interface MNScanVC ()
<AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic)AVCaptureDevice *device;
@property (strong, nonatomic)AVCaptureDeviceInput *input;
@property (strong, nonatomic)AVCaptureMetadataOutput *output;
@property (strong, nonatomic)AVCaptureSession *session;
@property (strong, nonatomic)AVCaptureVideoPreviewLayer *preview;

@property(nonatomic,strong)UIImageView* scaningView;
@property(nonatomic)BOOL scaning;

@property (strong, nonatomic)UIView* topMaskView;
@property (strong, nonatomic)UIView* bottomMaskView;
@property (strong, nonatomic)UIView* leftMaskView;
@property (strong, nonatomic)UIView* rightMaskView;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (strong, nonatomic)UILabel* tipsLabel;
@property (strong, nonatomic)UIButton* btnInput;

@property (strong, nonatomic)UILabel* flashlightLabel;
@property (strong, nonatomic)UIButton* btnFlashlight;

@property (strong, nonatomic)UILabel* phoneLabel;
@property (strong, nonatomic)UIButton* phoneBtn;
@property (strong, nonatomic)NSString* codeStr;

@property (nonatomic, assign) CGRect scanRect;



@end

@implementation MNScanVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scanRect = CGRectMake((APP_SCREEN_WIDTH-kQRWith)*0.5, (APP_SCREEN_HEIGHT-kQRWith)*0.5, kQRWith, kQRWith);
    [self configBasicDevice];
    MJWeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //
        [weakSelf.session startRunning];
    });
    self.scaning = NO;
    
    self.customNavBar.backgroundColor = [UIColor clearColor];
    self.customNavBar.contentView.backgroundColor = [UIColor clearColor];
    [self.customNavBar setRightBtnWithImageName:nil title:@"相册".lv_localized highlightedImageName:nil];
    [self.view bringSubviewToFront:self.customNavBar];
    [self.backBtn setImage:[UIImage imageNamed:@"NavBackWhite"] forState:UIControlStateNormal];
}

-(void)navigationBar:(MNNavigationBar *)navationBar didClickRightBtn:(UIButton *)btn{
    [self openLocalPhoto:YES];
}

-(CAShapeLayer *)shapeLayer{
    if (!_shapeLayer) {
        _shapeLayer = [[CAShapeLayer alloc] init];
        _shapeLayer.fillColor = [UIColor whiteColor].CGColor;
        _shapeLayer.fillRule = kCAFillRuleEvenOdd;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.view.bounds];
        UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:CGRectMake((APP_SCREEN_WIDTH-kQRWith)*0.5, (APP_SCREEN_HEIGHT-kQRWith)*0.5, kQRWith, kQRWith)];
        [path appendPath:rectPath];
        _shapeLayer.path = path.CGPath;
    }
    return _shapeLayer;
}

- (void)configBasicDevice{
    //默认使用后置摄像头进行扫描,使用AVMediaTypeVideo表示视频
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //设备输入 初始化
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    //设备输出 初始化，并设置代理和回调，当设备扫描到数据时通过该代理输出队列，一般输出队列都设置为主队列，也是设置了回调方法执行所在的队列环境
    self.output = [[AVCaptureMetadataOutput alloc]init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //会话 初始化，通过 会话 连接设备的 输入 输出，并设置采样质量为 高
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    //会话添加设备的 输入 输出，建立连接
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    //指定设备的识别类型 这里只指定二维码识别这一种类型 AVMetadataObjectTypeQRCode
    //指定识别类型这一步一定要在输出添加到会话之后，否则设备的课识别类型会为空，程序会出现崩溃
    [self.output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    //设置扫描信息的识别区域，本文设置正中央的一块正方形区域，该区域宽度是scanRegion_W
    //这里考虑了导航栏的高度，所以计算有点麻烦，识别区域越小识别效率越高，所以不设置整个屏幕
    [self.output setRectOfInterest:CGRectMake(self.scanRect.origin.y/APP_SCREEN_HEIGHT, self.scanRect.origin.x/APP_SCREEN_WIDTH, self.scanRect.size.height/APP_SCREEN_HEIGHT, self.scanRect.size.width/APP_SCREEN_WIDTH)];
    //预览层 初始化，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    //预览层的区域设置为整个屏幕，这样可以方便我们进行移动二维码到扫描区域,在上面我们已经对我们的扫描区域进行了相应的设置
    self.preview = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.preview.frame = self.view.bounds;
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.preview];
    //扫描框 和扫描线的布局和设置，模拟正在扫描的过程，这一块加不加不影响我们的效果，只是起一个直观的作用
   
    
    UIView *aView = [[UIView alloc] initWithFrame:self.view.bounds];
  
    aView.backgroundColor = HexRGBAlpha(0x000000, 0.3);
    aView.layer.mask = self.shapeLayer;
    [self.view addSubview:aView];
    self.scaningView = [[UIImageView alloc] initWithFrame:CGRectMake(self.scanRect.origin.x, self.scanRect.origin.y, kQRWith, 30)];
    
//    self.scaningView.backgroundColor = [UIColor redColor];
    [self.scaningView setImage:[UIImage imageNamed:@"QRScanLine"]];
    [self.view addSubview:self.scaningView];
    
    
    [self startScaningView];
    //扫描框下面的信息label布局
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scanRect)+25, APP_SCREEN_WIDTH, 20.0f)];
    label.text = @"将二维码放入框内,即可快速扫描".lv_localized;
    label.font = fontRegular(15);
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    AppConfigInfo *config = [AppConfigInfo sharedInstance];
    if (config.can_see_qr_code) {
        UILabel *bottomLabel = [[UILabel alloc] init];
        bottomLabel.text = @"我的二维码名片".lv_localized;
        bottomLabel.font = fontRegular(15);
        bottomLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:bottomLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goMyScan)];
        [bottomLabel addGestureRecognizer:tap];
        bottomLabel.userInteractionEnabled = YES;
        
        UIImageView *scanImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ScanQRCode"]];
        [self.view addSubview:scanImgV];
        [bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(-15);
            make.bottom.mas_equalTo(-(kBottom34()+25));
        }];
        [scanImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(bottomLabel.mas_right).with.offset(10);
            make.size.mas_equalTo(CGSizeMake(20, 20));
            make.centerY.equalTo(bottomLabel);
        }];
        UITapGestureRecognizer *scanTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goMyScan)];
        [scanImgV addGestureRecognizer:scanTap];
        scanImgV.userInteractionEnabled = YES;
        
        
    }
    UIImageView *scanBgImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ScanQRCodeBg"]];
    scanBgImg.frame = self.scanRect;
    [self.view addSubview:scanBgImg];
    
    
}
#pragma mark -------action

- (void)goMyScan{
    GC_MyScanVC *vc = [[GC_MyScanVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
//后置摄像头扫描到二维码的信息
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    [self.session stopRunning];   //停止扫描
    self.scaning = NO;
    if ([metadataObjects count] >= 1) {
        //数组中包含的都是AVMetadataMachineReadableCodeObject 类型的对象，该对象中包含解码后的数据
        AVMetadataMachineReadableCodeObject *qrObject = [metadataObjects lastObject];
        //拿到扫描内容在这里进行个性化处理
        NSString *result = qrObject.stringValue;
        NSLog(@"result --- %@",result);
        //解析数据进行处理并实现相应的逻辑
        //代码省略
        [self.navigationController popViewControllerAnimated:YES];
        if (self.delegate && [self.delegate respondsToSelector:@selector(scanVC:scanResult:)]) {
            [self.delegate scanVC:self scanResult:result];
        }
        
    }else{
        //重新扫码或者返回失败
        [SVProgressHUD showErrorWithStatus:@"读取失败"];
        [self performSelector:@selector(startScan) withObject:nil afterDelay:3];
        return;
    }
        
}

- (void)startScan{
    self.scaning = YES;
    [self.session startRunning];
}
-(void)startScaningView{
    
    self.scaning = YES;
    self.scaningView.alpha = 1.0f;
    self.scaningView.frame = CGRectMake(self.scanRect.origin.x,self.scanRect.origin.y, kQRWith, 3);
    
    MJWeakSelf
    [UIView animateWithDuration:2.0
                     animations:^{
                         weakSelf.scaningView.alpha = 1.0f;
        weakSelf.scaningView.frame = CGRectMake(weakSelf.scanRect.origin.x,CGRectGetMaxY(weakSelf.scanRect)-3, kQRWith, 3);;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3
                                          animations:^{
                             weakSelf.scaningView.alpha = 0.0f;
                                          }
                                          completion:^(BOOL finished) {
//                                              if (self.scaning) {
//                                                  [self startScaningView];
//                                              }
                             [weakSelf startScaningView];
                                          }];
                     }];
}


#pragma mark --打开相册并识别图片
/*!
 *  打开本地照片，选择图片识别
 */
- (void)openLocalPhoto:(BOOL)allowsEditing
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    picker.delegate = self;
   
    //部分机型有问题
    picker.allowsEditing = allowsEditing;
    
    [self presentViewController:picker animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image)
    {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        [self paserCodeImage:image];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"cancel");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 相册内扫码
-(void)paserCodeImage:(UIImage *)image
{
    UIImage * newImage = [self compressionImgae:image];
    
    CIDetector * detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    
    NSData * imageData =UIImagePNGRepresentation(newImage);
    CIImage * ciImage = [CIImage imageWithData:imageData];
    NSArray * features = [detector featuresInImage:ciImage];
    if (features.count == 0)
    {
        [self getScanDataString:@""];
        return;
    }
    CIQRCodeFeature*feature = [features objectAtIndex:0];
    NSString * scannedResult = feature.messageString;
    [self getScanDataString:scannedResult];

}
//压缩图片
-(UIImage *)compressionImgae:(UIImage *)theImage{
    UIImage* bigImage = theImage;
    float actualHeight = bigImage.size.height;
    float actualWidth = bigImage.size.width;
    float newWidth =0;
    float newHeight =0;
    if(actualWidth > actualHeight) {
        newHeight =256.0f;
        newWidth = actualWidth / actualHeight * newHeight;
    }else{
        newWidth =256.0f;
        newHeight = actualHeight / actualWidth * newWidth;
    }
    CGRect rect =CGRectMake(0.0,0.0, newWidth, newHeight);
    UIGraphicsBeginImageContext(rect.size);
    [bigImage drawInRect:rect];// scales image to rect
    theImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

-(void)getScanDataString:(NSString *)scanDataString{
    if (scanDataString.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"读取失败".lv_localized];
        [self performSelector:@selector(startScan) withObject:nil afterDelay:3];
        return;
    }
    
//    if ([self.delegate respondsToSelector:@selector(wpscanResult:)])
//    {
//        [self.delegate wpscanResult:scanDataString];
//    }
    [self.navigationController popViewControllerAnimated:YES];
    if([self.delegate respondsToSelector:@selector(scanVC:scanResult:)])
    {
        [self.delegate scanVC:self scanResult:scanDataString];
    }
    
}
@end
