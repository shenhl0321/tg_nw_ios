//
//  PhotoAVideoPreviewPagesViewController.m
//  GoChat
//
//  Created by wangyutao on 2020/12/28.
//

#import "PhotoAVideoPreviewPagesViewController.h"
#import "PhotoAVideoPreviewPagesViewController+Timeline.h"
#import "PhotoPreviewItemViewController.h"
#import "VideoPreviewItemViewController.h"
#import "ChatChooseViewController.h"
#import "GC_MyInfoVC.h"
#import "ComputerLoginViewController.h"
#import "MNContactDetailVC.h"
#import "QTGroupPersonInfoVC.h"

@interface PhotoAVideoPreviewPagesViewController ()<PhotoPreviewItemViewControllerDelegate>
@property (nonatomic, strong) UIView *customNavView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *rightbtn;

@end

@implementation PhotoAVideoPreviewPagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel = [self.customNavBar setTitle:@""];
    [self.customNavBar setLeftBtnWithImageName:@"NavBackWhite" title:nil highlightedImageName:@"NavBackWhite"];
    self.rightbtn = [self.customNavBar setRightBtnWithImageName:@"icon_more" title:nil highlightedImageName:@"icon_more"];
    self.customNavBar.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.view bringSubviewToFront:self.customNavBar];
    //初始显示
    if(self.curIndex>=0 && self.curIndex<self.previewList.count)
    {
        self.selectIndex = self.curIndex;
    }
    [self resetTitle];
    
    //self.view.backgroundColor = RGBA(0, 0, 0, 0.2);
//    self.customNavView.backgroundColor = [UIColor clearColor];//RGBA(0, 0, 0, 0.2);
//    [self.view bringSubviewToFront:self.customNavView];
    
    if (self.curIndex == 0) {
        MessageInfo *msg = [self.previewList objectAtIndex:0];
        if(msg.messageType == MessageType_Animation){
            self.rightbtn.hidden = YES;
        }
    }
    
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //隐藏导航栏
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
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

-(void)navigationBar:(MNNavigationBar *)navationBar didClickRightBtn:(UIButton *)btn{
    [self moreClick:nil];
}

- (void)resetTitle
{
    if(self.previewList.count == 1)
        self.titleLabel.text = @"";
    else
        self.titleLabel.text = [NSString stringWithFormat:@"%d/%lu", self.selectIndex+1, self.previewList.count];
}

#pragma mark - PhotoPreviewItemViewControllerDelegate
- (void)PhotoPreviewItemViewController_SingleTap:(PhotoPreviewItemViewController *)controller
{
    [self gotoBack];
}

- (void)PhotoPreviewItemViewController_LongPress:(PhotoPreviewItemViewController *)controller
{
    [self moreClick:nil];
}

#pragma mark - click
- (IBAction)gotoBack
{
    [self.navigationController popViewControllerAnimated:YES];
    !self.previewPopCallback ? : self.previewPopCallback();
}
- (void)handleLongPressGestures{
    [self moreClick:nil];
}

- (IBAction)moreClick:(UIView *)view {
    
    NSString *qrcode = [self qrcodeWithMessage];
    
    MMPopupItemHandler block = ^(NSInteger index) {
        if (index == 0) {
            [self saveToAlbum];
        } else if (index == 1) {
            [self share];
        } else if (index == 2) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self QrScanViewController_Result:qrcode];
            });
        }
    };
    NSMutableArray *items = @[MMItemMake(@"保存到相册".lv_localized, MMItemTypeNormal, block),
                       MMItemMake(@"分享".lv_localized, MMItemTypeNormal, block)].mutableCopy;
    if (qrcode) {
        [items addObject:MMItemMake(@"识别图中二维码".lv_localized, MMItemTypeNormal, block)];
    }
    [items addObjectsFromArray:self.timelineItems];
    
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:nil items:items];
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
}


/**
 *  转发回调，即长按菜单选择了转发消息
 *
 */
- (void)forwardMessage:(MessageInfo *)message
{
    
    ChatChooseViewController *chooseView = [[ChatChooseViewController alloc] init];
    chooseView.toSendMsgsList = @[message];
    chooseView.hidesBottomBarWhenPushed = YES;
    chooseView.delegate = self;
    [self.navigationController pushViewController:chooseView animated:YES];
}

/**
 *  收藏
 */
- (void)favorMessage:(MessageInfo *)message
{
    //
    //退出多选模式
   
    [[TelegramManager shareInstance] forwardMessage:[UserInfo shareInstance]._id msgs:@[message]];
    [UserInfo showTips:nil des:@"已收藏".lv_localized];
    
}
- (void)saveToAlbum
{//保存到相册
    if(self.previewList.count>self.selectIndex)
    {
        MessageInfo *msg = [self.previewList objectAtIndex:self.selectIndex];
        if(msg.messageType == MessageType_Photo)
        {
            NSString *localPath = [self imagePath:msg];
            if(!IsStrEmpty(localPath))
            {
                UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
            else
            {
                [UserInfo showTips:nil des:@"图片未准备好，无法保存到相册".lv_localized];
            }
        }
        if(msg.messageType == MessageType_Video)
        {
            NSString *localPath = [self videoPath:msg];
            if(!IsStrEmpty(localPath))
            {
                UISaveVideoAtPathToSavedPhotosAlbum(localPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            }
            else
            {
                [UserInfo showTips:nil des:@"视频未准备好，无法保存到相册".lv_localized];
            }
        }
        if(msg.messageType == MessageType_Document)
        {
            NSString *fileName = msg.content.document.file_name;
            if([DocumentInfo isImageFile:fileName])
            {//图片文件
                NSString *localPath = [self documentPath:msg];
                if(!IsStrEmpty(localPath))
                {
                    UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                }
                else
                {
                    [UserInfo showTips:nil des:@"图片未准备好，无法保存到相册".lv_localized];
                }
            }
            else
            {//视频文件
                NSString *localPath = [self documentPath:msg];
                if(!IsStrEmpty(localPath))
                {
                    UISaveVideoAtPathToSavedPhotosAlbum(localPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                }
                else
                {
                    [UserInfo showTips:nil des:@"视频未准备好，无法保存到相册".lv_localized];
                }
            }
        }
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(!error)
    {
        [UserInfo showTips:nil des:@"已保存".lv_localized];
    }
    else
    {
        [UserInfo showTips:nil des:@"保存失败".lv_localized];
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(!error)
    {
        [UserInfo showTips:nil des:@"已保存".lv_localized];
    }
    else
    {
        [UserInfo showTips:nil des:@"保存失败".lv_localized];
    }
}

- (void)share {//文件分享
    if(self.previewList.count>self.selectIndex)
    {
        MessageInfo *msg = [self.previewList objectAtIndex:self.selectIndex];
        if(msg.messageType == MessageType_Photo)
        {
            NSString *localPath = [self imagePath:msg];
            if(!IsStrEmpty(localPath))
            {
                UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"Image", [NSURL fileURLWithPath:localPath]] applicationActivities:nil];
                [self presentViewController:activityViewController animated:YES completion:nil];
            }
            else
            {
                [UserInfo showTips:nil des:@"图片未准备好，无法分享".lv_localized];
            }
        }
        if(msg.messageType == MessageType_Video)
        {
            NSString *localPath = [self videoPath:msg];
            if(!IsStrEmpty(localPath))
            {
                UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"Video", [NSURL fileURLWithPath:localPath]] applicationActivities:nil];
                [self presentViewController:activityViewController animated:YES completion:nil];
            }
            else
            {
                [UserInfo showTips:nil des:@"视频未准备好，无法分享".lv_localized];
            }
        }
        if(msg.messageType == MessageType_Document)
        {
            NSString *fileName = msg.content.document.file_name;
            if([DocumentInfo isImageFile:fileName])
            {//图片
                NSString *localPath = [self documentPath:msg];
                if(!IsStrEmpty(localPath))
                {
                    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"Image", [NSURL fileURLWithPath:localPath]] applicationActivities:nil];
                    [self presentViewController:activityViewController animated:YES completion:nil];
                }
                else
                {
                    [UserInfo showTips:nil des:@"图片未准备好，无法分享".lv_localized];
                }
            }
            else
            {//视频
                NSString *localPath = [self documentPath:msg];
                if(!IsStrEmpty(localPath))
                {
                    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"Video", [NSURL fileURLWithPath:localPath]] applicationActivities:nil];
                    [self presentViewController:activityViewController animated:YES completion:nil];
                }
                else
                {
                    [UserInfo showTips:nil des:@"视频未准备好，无法分享".lv_localized];
                }
            }
        }
    }
}

- (void)QrScanViewController_Result:(NSString *)result {
    if (!IsStrEmpty(result)) {
        if ([result containsString:@"login?token"]) {//扫码登录
            ComputerLoginViewController *computerVC = [[ComputerLoginViewController alloc] init];
            computerVC.hidesBottomBarWhenPushed = YES;
            computerVC.link = result;
            [self.navigationController pushViewController:computerVC animated:YES];
        } else {
            long userId = [[UserInfo shareInstance] userIdFromQrString:result];
            NSString *invitelink = [[UserInfo shareInstance] userIdFromInvitrLink:[NSURL URLWithString:result]];
            if(userId <= 0)
            {
                if(invitelink && invitelink.length > 5){
                    //链接进群
                    [UserInfo shareInstance].inviteLink = invitelink;
                    [((AppDelegate*)([UIApplication sharedApplication].delegate)) addGroupWithInviteLink];
                }else{
                    if ([result hasPrefix:@"http"]) {
                        NSURL *url = [NSURL URLWithString:result];
                        if ([UIApplication.sharedApplication canOpenURL:url]) {
                            [UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
                        }
                    } else {
                        [UserInfo showTips:nil des:@"无效二维码".lv_localized];
                    }
                }
            }
            else
            {
                [UserInfo show];
                [[TelegramManager shareInstance] requestContactInfo:userId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                    [UserInfo dismiss];
                    if(obj != nil && [obj isKindOfClass:UserInfo.class])
                    {
                        UserInfo *user = obj;
                        if(userId == [UserInfo shareInstance]._id)
                        {
                            
                            GC_MyInfoVC *vc = [[GC_MyInfoVC alloc] init];
                            [self.navigationController pushViewController:vc animated:YES];
                        }
                        else
                        {
//                            MNContactDetailVC *v = [[MNContactDetailVC alloc] init];
//                            v.user = user;
//                            [self.navigationController pushViewController:v animated:YES];
                            
                            if (user.is_contact){
                                QTGroupPersonInfoVC *vc = [[QTGroupPersonInfoVC alloc] init];
                                vc.user = user;
                                [self presentViewController:vc animated:YES completion:nil];
                            }else{
                                QTAddPersonVC *vc = [[QTAddPersonVC alloc] init];
                                vc.user = user;
                                [self presentViewController:vc animated:YES completion:nil];
                            }
                        }
                    }
                    else
                    {
                        [UserInfo showTips:nil des:@"获取联系人失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
                    }
                } timeout:^(NSDictionary *request) {
                    [UserInfo dismiss];
                    [UserInfo showTips:nil des:@"获取联系人失败，请稍后重试".lv_localized];
                }];
            }
        }
        }
        
    else
    {
        [UserInfo showTips:nil des:@"无效二维码".lv_localized];
    }
}


- (NSString *)imagePath:(MessageInfo *)photo_message
{
    PhotoSizeInfo *b_photoInfo = photo_message.content.photo.previewPhoto;
    if(b_photoInfo != nil && b_photoInfo.isPhotoDownloaded)
    {//首先加载大图
        return b_photoInfo.photo.local.path;
    }
    else
    {//大图没有下载，则加载小图
        PhotoSizeInfo *s_photoInfo = photo_message.content.photo.messagePhoto;
        if(s_photoInfo != nil && s_photoInfo.isPhotoDownloaded)
        {
            return s_photoInfo.photo.local.path;
        }
    }
    return nil;
}

- (NSString *)videoPath:(MessageInfo *)video_message
{
    VideoInfo *videoInfo = video_message.content.video;
    if(videoInfo.isVideoDownloaded)
    {
        return videoInfo.localVideoPath;
    }
    return nil;
}

- (NSString *)documentPath:(MessageInfo *)message
{
    if(message.content.document.isFileDownloaded)
    {
        return message.content.document.localFilePath;
    }
    return nil;
}

- (NSString *)qrcodeWithMessage {
    MessageInfo *msg = [self.previewList objectAtIndex:self.selectIndex];
    if (msg.messageType != MessageType_Photo) {
        return nil;
    }
    NSString *localPath = [self imagePath:msg];
    if (IsStrEmpty(localPath)) {
        return nil;
    }
    UIImage *newImage = [UIImage imageWithContentsOfFile:localPath];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    
    NSData * imageData =UIImagePNGRepresentation(newImage);
    CIImage * ciImage = [CIImage imageWithData:imageData];
    NSArray * features = [detector featuresInImage:ciImage];
    if (features.count == 0) {
        return nil;
    }
    CIQRCodeFeature*feature = [features objectAtIndex:0];
    NSString *scannedResult = feature.messageString;
    return scannedResult;
}

#pragma mark - WMPageControllerDelegate
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController
{
    return self.previewList.count;
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index
{
    if(self.previewList.count>index)
    {
        MessageInfo *msg = [self.previewList objectAtIndex:index];
        if(msg.messageType == MessageType_Photo)
        {
//            PhotoPreviewItemViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoPreviewItemViewController"];
            PhotoPreviewItemViewController *v = [[PhotoPreviewItemViewController alloc] init];
            v.photo_message = msg;
            v.delegate = self;
            return v;
        }
        else if(msg.messageType == MessageType_Video)
        {
            VideoPreviewItemViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"VideoPreviewItemViewController"];
            v.video_message = msg;
            v.longPressBlock = ^{
                [self handleLongPressGestures];
            };
            return v;
        }
        else if(msg.messageType == MessageType_Animation)
        {
            
            AnimationInfo *videoInfo = msg.content.animation;
            
            NSString *path = videoInfo.localVideoPath;
            
            if ([path hasSuffix:@".gif"]) {
                PhotoPreviewItemViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoPreviewItemViewController"];
                v.photo_message = msg;
                v.delegate = self;
                return v;
            } else {
                VideoPreviewItemViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"VideoPreviewItemViewController"];
                v.video_message = msg;
                v.longPressBlock = ^{
                    [self handleLongPressGestures];
                };
                return v;
            }
            
            
            
        }
        else if(msg.messageType == MessageType_Document)
        {
            NSString *fileName = msg.content.document.file_name;
            if([DocumentInfo isImageFile:fileName])
            {//图片
                PhotoPreviewItemViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoPreviewItemViewController"];
                v.photo_message = msg;
                v.delegate = self;
                return v;
            }
            else
            {//视频
                VideoPreviewItemViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"VideoPreviewItemViewController"];
                v.video_message = msg;
                v.longPressBlock = ^{
                    [self handleLongPressGestures];
                };
                return v;
            }
        }
        else
        {
            return [UIViewController new];
        }
    }
    else
    {
        return [UIViewController new];
    }
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index
{
    return @"";
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView
{
    CGFloat originY = 0;
    CGFloat sizeHeight = self.view.frame.size.height - originY;
    return CGRectMake(0, originY, self.view.frame.size.width, sizeHeight);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView
{
    return CGRectMake(0, 0, self.view.frame.size.width, 0.0f);
}

- (void)pageController:(WMPageController *)pageController didEnterViewController:(UIViewController *)viewController withInfo:(NSDictionary *)info
{
    [self resetTitle];
    NSNumber *index = info[@"index"];
    if (!index) {
        return;
    }
    MessageInfo *msg = self.previewList[index.intValue];
    if (!msg) {
        return;
    }
    self.rightbtn.hidden = msg.messageType == MessageType_Animation;
}

#pragma mark - 控制屏幕旋转方法
//是否自动旋转,返回YES可以自动旋转,返回NO禁止旋转
- (BOOL)shouldAutorotate
{
    return NO;
}

//返回支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

//由模态推出的视图控制器 优先支持的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
