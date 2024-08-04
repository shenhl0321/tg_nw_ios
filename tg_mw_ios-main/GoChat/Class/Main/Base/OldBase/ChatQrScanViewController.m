//
//  ChatQrScanViewController.m
//  GoChat
//
//  Created by wangyutao on 2021/1/5.
//

#import "ChatQrScanViewController.h"
#import "LBXScanZXingViewController.h"
#import "StyleDIY.h"
#import "WPScanView.h"
@interface ChatQrScanViewController ()<LBXScanBaseViewControllerDelegate,WPScanViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) LBXScanZXingViewController *zxingVc;
@property (nonatomic, weak) IBOutlet UIView *customNavView;
@property (nonatomic, weak) IBOutlet UIView *toolbarView;

@property (nonatomic, weak) IBOutlet UIButton *flashBtn;
@property (nonatomic, strong) WPScanView * scanV;
@property (nonatomic, strong) AVCaptureDevice * device;

@end

@implementation ChatQrScanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [self.flashBtn setImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
    [self.flashBtn setImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_down"] forState:UIControlStateSelected];
    //qr
//    self.zxingVc = [LBXScanZXingViewController new];
//    self.zxingVc.style = [StyleDIY wwxxStyle];
//    self.zxingVc.cameraInvokeMsg = @"加载中...";
//    self.zxingVc.delegate = self;
//
//    [self addChildViewController:self.zxingVc];
//    self.zxingVc.view.frame = self.view.bounds;
//    [self.view addSubview:self.zxingVc.view];
//    [self.zxingVc didMoveToParentViewController:self];
    self.scanV = [[WPScanView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.scanV];
    self.scanV.delegate = self;
    
    //nav
    self.customNavView.backgroundColor = [UIColor clearColor];
    [self.view bringSubviewToFront:self.customNavView];
    self.toolbarView.backgroundColor = [UIColor clearColor];
    [self.view bringSubviewToFront:self.toolbarView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //白色标题
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //恢复
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
}

#pragma mark - LBXScanBaseViewControllerDelegate
- (void)LBXScanBaseViewController_Result:(NSString *)result
{
    [self.navigationController popViewControllerAnimated:YES];
    if([self.delegate respondsToSelector:@selector(ChatQrScanViewController_Result:)])
    {
        [self.delegate ChatQrScanViewController_Result:result];
    }
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
    if([self.delegate respondsToSelector:@selector(ChatQrScanViewController_Result:)])
    {
        [self.delegate ChatQrScanViewController_Result:scanDataString];
    }
    
}
-(void)startScan
{
    __weak typeof(self) weak_self =self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weak_self.scanV startRunning];
    });
}
//打开手电筒
- (void)turnOnLight:(UIButton *)btn {
    if ([_device hasTorch]) {
        [_device lockForConfiguration:nil];
        if (!btn.selected) {
            [_device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [_device setTorchMode:AVCaptureTorchModeOff];
        }
        btn.selected = !btn.selected;
        [_device unlockForConfiguration];
    }
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
-(void)becomeActive
{
    if (_device.torchMode == AVCaptureTorchModeOn) {
        self.flashBtn.selected = YES;
    }
    else if (_device.torchMode == AVCaptureTorchModeOff){
        self.flashBtn.selected = NO;
    }
}



-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - click
- (IBAction)gotoBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)click_flash
{
//    [self.zxingVc openOrCloseFlash];
//    if(self.zxingVc.isOpenFlash)
//    {
//        [self.flashBtn setImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_down"] forState:UIControlStateNormal];
//    }
//    else
//    {
//        [self.flashBtn setImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
//    }
    [self turnOnLight:self.flashBtn];
}

- (IBAction)click_photo
{
    [self openLocalPhoto:NO];
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
@end
