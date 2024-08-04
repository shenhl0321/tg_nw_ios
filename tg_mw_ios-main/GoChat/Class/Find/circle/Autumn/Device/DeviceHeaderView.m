//
//  DeviceHeaderView.m
//  GoChat
//
//  Created by Autumn on 2022/2/16.
//

#import "DeviceHeaderView.h"
#import "MNScanVC.h"
#import "ComputerLoginViewController.h"

@interface DeviceHeaderView ()<MNScanVCDelegate>

@property (strong, nonatomic) IBOutlet UIButton *scanButton;

@property (strong, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation DeviceHeaderView

- (void)dy_initUI {
    [super dy_initUI];
    NSString *desktop = [localAppName.lv_localized stringByAppendingString:@" Desktop"],
    *web = [localAppName.lv_localized stringByAppendingString:@" Web"];
    _textLabel.text = [NSString stringWithFormat:@"通过 %@ 或 %@ 链接\n扫描二维码".lv_localized, desktop, web];
    NSRange dRange = [_textLabel.text rangeOfString:desktop];
    NSRange wRange = [_textLabel.text rangeOfString:web];
    [_textLabel xhq_AttributeTextAttributes:@{NSForegroundColorAttributeName: UIColor.colorMain}
                                      range:dRange];
    [_textLabel xhq_AttributeTextAttributes:@{NSForegroundColorAttributeName: UIColor.colorMain}
                                      range:wRange];
    [_scanButton xhq_cornerRadius:13];
}


- (IBAction)scanAction:(id)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self showNeedCameraAlert];
        return;
    }
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusAuthorized || authStatus == AVAuthorizationStatusNotDetermined) {
        MNScanVC *v = [[MNScanVC alloc] init];
        v.delegate = self;
        [self.xhq_currentController.navigationController pushViewController:v animated:YES];
    } else {
        [self showNeedCameraAlert];
    }
}


- (void)showNeedCameraAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法使用相机".lv_localized message:@"请在iPhone的\"设置-隐私-相机\"中允许访问相机".lv_localized preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelButton = [UIAlertAction actionWithTitle:@"确定".lv_localized style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancelButton];
    [self.xhq_currentController presentViewController:alert animated:YES completion:nil];
}

- (void)scanVC:(MNScanVC *)scanvc scanResult:(NSString *)result{
    NSLog(@"查找崩溃 - 01");
    [self ChatQrScanViewController_Result:result];
}

- (void)ChatQrScanViewController_Result:(NSString *)result {
    if(IsStrEmpty(result)) {
        [UserInfo showTips:nil des:@"无效二维码".lv_localized];
        return;
    }
    if ([result containsString:@"login?token"]) {//扫码登录
        ComputerLoginViewController *computerVC = [[ComputerLoginViewController alloc] init];
        computerVC.hidesBottomBarWhenPushed = YES;
        computerVC.link = result;
        [self.xhq_currentController.navigationController pushViewController:computerVC animated:YES];
        return;
    }
    [UserInfo showTips:nil des:@"非登录二维码".lv_localized];
}

@end
