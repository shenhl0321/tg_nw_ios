//
//  XHQImagePicker.m
//  Julong
//
//  Created by 帝云科技 on 2017/7/20.
//  Copyright © 2017年 diyunkeji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHQImagePicker.h"
#import <AVFoundation/AVFoundation.h>

@interface XHQImagePicker ()<
UINavigationControllerDelegate,
UIImagePickerControllerDelegate>

@property (nonatomic, copy) XHQFinishedImageHandler handler;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) UIImagePickerController *picker;
@property (nonatomic, assign) BOOL allowsEditing;

@end

static XHQImagePicker *_xhqImagePicker = nil;

@implementation XHQImagePicker

- (void)dealloc {
    if (self.picker) {
        self.picker = nil;
    }
}

+ (void)xhq_imagePicker:(UIViewController *)viewController
          allowsEditing:(BOOL)edit
                 finish:(XHQFinishedImageHandler)handler {
    if (!_xhqImagePicker) {
        _xhqImagePicker = [[XHQImagePicker alloc]init];
    }
    [_xhqImagePicker xhq_imagePicker:viewController allowsEditing:edit finish:handler];
}

- (void)xhq_imagePicker:(UIViewController *)viewController
          allowsEditing:(BOOL)edit
                 finish:(XHQFinishedImageHandler)handler {
    _viewController = viewController;
    _allowsEditing = edit;
    _handler = handler;
    
    [self setActionSheetController];
}

- (void)setActionSheetController {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionPhoto = [UIAlertAction actionWithTitle:@"从手机相册选择".lv_localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self imagePickerControllerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:@"拍照".lv_localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([self checkCameraAuthority]) {
            _xhqImagePicker = nil;
            return ;
        }
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [self imagePickerControllerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        }else {
            NSLog(@"%@",@"模拟器无法打开拍照功能，请用真机打开".lv_localized);
        }
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消".lv_localized style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        _xhqImagePicker = nil;
    }];
    if (kDeviceSystemVersion > 8.4) {
        [actionCamera setValue:[UIColor xhq_aTitle] forKey:@"_titleTextColor"];
        [actionPhoto setValue:[UIColor xhq_aTitle] forKey:@"_titleTextColor"];
        [actionCancel setValue:[UIColor xhq_aTitle] forKey:@"_titleTextColor"];
    }
    [sheet addAction:actionCamera];
    [sheet addAction:actionPhoto];
    [sheet addAction:actionCancel];
    [self.viewController presentViewController:sheet animated:YES completion:nil];
}

- (void)imagePickerControllerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = sourceType;
    picker.delegate = self;
    picker.allowsEditing = _allowsEditing;
    self.picker = picker;
    [self.viewController presentViewController:picker animated:YES completion:nil];
}

#pragma mark - 检测相机是否有权限
- (BOOL)checkCameraAuthority {
    
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    BOOL res = (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied);
    if (res) {
        NSString *title = @"未开启权限".lv_localized;
        NSString *message = @"是否前往设置去开启相机权限？".lv_localized;
        UIAlertController *alert = [XHQAlertManager showTitle:title message:message enterTitle:@"打开".lv_localized cancelTitle:@"取消".lv_localized enterAction:^{
            [self openSetting];
        } cancelAction:nil];
        [self.viewController presentViewController:alert animated:YES completion:nil];
    }
    return res;
}

- (void)openSetting
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if (@available(iOS 10, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

//如果要上传到服务器，最好在压缩一下UIImageJPEGRepresentation(image, 0-1)
- (UIImage *)processImage:(UIImage *)image {
    CGFloat hFactor = image.size.width / kScreenWidth();
    CGFloat wFactor = image.size.height / kScreenHeight();
    CGFloat factor = fmaxf(hFactor, wFactor);
    CGFloat newW = image.size.width / factor;
    CGFloat newH = image.size.height / factor;
    CGSize newSize = CGSizeMake(newW, newH);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newW, newH)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = [self processImage:info[UIImagePickerControllerEditedImage]];
//    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    if (image) {
        if (self.handler) {
            self.handler(image);
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    _xhqImagePicker = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    _xhqImagePicker = nil;
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([navigationController isKindOfClass:[UIImagePickerController class]]) {
        viewController.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        viewController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        [viewController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor xhq_aTitle]}];
//        viewController.navigationController.dy_barStyle = UIStatusBarStyleLightContent;
    }
}

@end
