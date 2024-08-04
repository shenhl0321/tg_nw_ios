//
//  MNNickNameVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/25.
//

#import "MNNickNameVC.h"
#import "TfRow.h"
#import "MNSetPwdVC.h"
#import "TfRow.h"
#import "MNChatViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "HXPhotoPicker.h"

@interface MNNickNameVC ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImageView *iconImgV;
@property (nonatomic, copy) NSString *photoPath;
@property (strong, nonatomic) UIView *editView;
@property (strong, nonatomic) UIImageView *editImageV;

@property (nonatomic, strong) UITextField *nameTf;

@property (nonatomic, strong) UIImageView *sepImgV;

@property (strong, nonatomic) UIButton *confirmBtn;

@property (strong, nonatomic) HXPhotoManager *photoManager;


@end

@implementation MNNickNameVC

- (HXPhotoManager *)photoManager {
    if (!_photoManager) {
        _photoManager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
        _photoManager.configuration.customCameraType = HXPhotoCustomCameraTypePhoto;
        _photoManager.configuration.albumShowMode = HXPhotoAlbumShowModePopup;
        _photoManager.configuration.singleSelected = YES;
        _photoManager.configuration.singleJumpEdit = YES;
        _photoManager.configuration.cameraPhotoJumpEdit = YES;
        _photoManager.configuration.movableCropBox = YES;
        _photoManager.configuration.movableCropBoxEditSize = YES;
        _photoManager.configuration.movableCropBoxCustomRatio = CGPointMake(1, 1);
    }
    return _photoManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:@"完善资料"];
    [self.customNavBar setLeftBtnWithImageName:@"" title:@"退出" highlightedImageName:@""];
    
    [self initUI];
    
    [self.view insertSubview:self.customNavBar atIndex:100];
    self.customNavBar.backgroundColor = [UIColor clearColor];
    [self showLogoUI];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}
- (void)nameTFChange{
    self.confirmBtn.enabled = !IsStrEmpty(self.nameTf.text);
}
- (void)initUI{
    
    [self.contentView addSubview:self.iconImgV];
    [self.contentView addSubview:self.sepImgV];
    [self.iconImgV addSubview:self.editView];
    [self.editView addSubview:self.editImageV];
    
    TfRow *nameRow = [[TfRow alloc] init];
    [nameRow.lineView removeFromSuperview];
    nameRow.backgroundColor = [UIColor clearColor];
    self.nameTf = nameRow.tf;
    [self.nameTf addTarget:self action:@selector(nameTFChange) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:nameRow];
    self.confirmBtn = [UIButton mn_loginStyleWithTitle:@"完成"];
    self.confirmBtn.enabled = NO;
    [self.confirmBtn addTarget:self action:@selector(commitAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.confirmBtn];
    
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(70);
        make.size.mas_equalTo(CGSizeMake(90, 90));
        make.centerX.mas_equalTo(0);
    }];
    [self.editView mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.bottom.right.equalTo(self.iconImgV);
        make.height.mas_offset(20);
    }];
    [self.editImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.center.equalTo(self.editView);
        make.width.height.mas_offset(15);
    }];
    [nameRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.editImageV.mas_bottom).offset(40);
        make.left.mas_equalTo(left_margin40());
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(55);
    }];
    [self.sepImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.width.mas_offset(150);
        make.height.mas_equalTo(1);
        make.top.mas_equalTo(nameRow.mas_bottom);
    }];
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.centerX.mas_equalTo(0);
        make.top.equalTo(self.sepImgV.mas_bottom).offset(50);
        make.height.mas_equalTo(55);
    }];
    self.nameTf.font = fontSemiBold(16);
    self.nameTf.textAlignment = NSTextAlignmentCenter;
    self.nameTf.placeholder = @"请输入您的昵称";
}

- (void)commitAction{
    [self regiseterNickName];
}

- (void)regiseterNickName{
    NSString *firstName = self.nameTf.text;
    firstName = [firstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(firstName.length<=0)
    {
        [UserInfo showTips:self.view des:LocalString(localPlsEnterYourNickName)];
        return;
    }
    if (IsStrEmpty(self.photoPath)) {
        [UserInfo showTips:self.view des:@"请选择用户头像".lv_localized];
        return;
    }
    [UserInfo show];
    [[TelegramManager shareInstance] registerUser:firstName lastName:@"" result:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if(![TelegramManager isResultOk:response])
        {
            NSLog(@"registerUser fail......");
            [UserInfo showTips:self.view des:@"设置昵称失败".lv_localized];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        NSLog(@"registerUser timeout......");
        [UserInfo showTips:self.view des:@"请求超时，请检查网络是否正常".lv_localized];
    }];
}

- (void)setUserPassword
{
    [[TelegramManager shareInstance] checkAuthenticationPassword:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultOk:response])
        {
            NSLog(@"setUserPassword fail......");
        }
    } timeout:^(NSDictionary *request) {
        NSLog(@"setUserPassword timeout......");
    }];
}

#pragma mark BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Register)://手机号注册的
        {
            [self regiseterNickName];
            break;
        }
        case MakeID(EUserManager, EUser_Td_Input_Password):
        {
            [self setUserPassword];
            break;
        }
        case MakeID(EUserManager, EUser_Td_Ready):
        {
            //清理数据
            [AuthUserManager cleanDestroyFolder];
            //登录
            if([UserInfo shareInstance].isPasswordLoginType)
            {
                if(!IsStrEmpty([UserInfo shareInstance].phone_number))
                {
                    [[AuthUserManager shareInstance] login:[UserInfo shareInstance].phone_number data_directory:[UserInfo shareInstance].data_directory];
                }
                else
                {
                    [[AuthUserManager shareInstance] login:self.curUsername data_directory:[UserInfo shareInstance].data_directory];
                }
            }
            else
            {
                [[AuthUserManager shareInstance] login:[NSString stringWithFormat:@"%@%@", self.curCountryCode, self.curPhone] data_directory:[UserInfo shareInstance].data_directory];
            }
            //goto home view
            [((AppDelegate*)([UIApplication sharedApplication].delegate)) gotoHomeView];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self setPhoto:self.photoPath];
            });
            
            break;
        }
        default:
            break;
    }
}

- (void)changeIcon{
    MMPopupItemHandler block = ^(NSInteger index){
        if(index == 0)
        {//拍照
//            [self click_camera];
            [self click_xiangji];
        }
        if(index == 1)
        {//从手机相册选择
//            [self click_photo];
            [self click_avatar];
        }
    };
    NSArray *items =
    @[MMItemMake(@"拍照".lv_localized, MMItemTypeNormal, block),
      MMItemMake(@"从手机相册选择".lv_localized, MMItemTypeNormal, block)];
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:nil
                                                          items:items];
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
}
- (void)click_avatar{
    [self hx_presentSelectPhotoControllerWithManager:self.photoManager didDone:^(NSArray<HXPhotoModel *> * _Nullable allList, NSArray<HXPhotoModel *> * _Nullable photoList, NSArray<HXPhotoModel *> * _Nullable videoList, BOOL isOriginal, UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
        //
        HXPhotoModel *model = allList.firstObject;
        UIImage *image = [self getImageFromHXPhotoModel:model];
        if (image) {
//            UIImage *thum_image = [UIImage thumbnailWithImage:image size:CGSizeMake(200, 200)];
//            UIImage *thum_image = image;
            
            UIImage *toSendImage = [Common fixOrientation:image];
            NSString *path = [self writeImage:toSendImage path:nil];
            if(path != nil)
            {
                self.photoPath = path;
                self.iconImgV.image = toSendImage;
            }
            
        }
    } cancel:^(UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
        //
    }];
}
/// 从HXPhotoModel获取图片
- (UIImage *)getImageFromHXPhotoModel:(HXPhotoModel *)model {
    
    if (model.asset) {
        
        PHImageManager *manager = [PHImageManager defaultManager];
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.synchronous = YES;
        
        __block UIImage *image;
        [manager requestImageForAsset:model.asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            image = result;
        }];
        
        return image;
        
    } else if (model.previewPhoto) {
        return model.previewPhoto;
    } else {
        return model.thumbPhoto;
    }
}
- (void)click_xiangji{
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self showNeedCameraAlert];
        return;
    }
    
    [self hx_presentCustomCameraViewControllerWithManager:self.photoManager done:^(HXPhotoModel *model, HXCustomCameraViewController *viewController) {
        //
        
        UIImage *image = [self getImageFromHXPhotoModel:model];
        if (image) {
//            UIImage *thum_image = [UIImage thumbnailWithImage:image size:CGSizeMake(200, 200)];
//            UIImage *toSendImage = [Common fixOrientation:image];
            UIImage *toSendImage = image;
            NSString *path = [self writeImage:toSendImage path:nil];
            if(path != nil)
            {
                self.photoPath = path;
                self.iconImgV.image = toSendImage;
            }
            
        }
    } cancel:^(HXCustomCameraViewController *viewController) {
        //
    }];
}

- (void)click_camera
{
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self showNeedCameraAlert];
        return;
    }
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized || authStatus == AVAuthorizationStatusNotDetermined)
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = YES;
        [self presentViewController:picker animated:YES completion:nil];
    }
    else
    {
        [self showNeedCameraAlert];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info
{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *toSendImage = [Common fixOrientation:image];
        NSString *path = [self writeImage:toSendImage path:nil];
        if(path != nil)
        {
            self.photoPath = path;
            self.iconImgV.image = toSendImage;
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)click_photo
{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    imagePickerVc.allowCrop = YES;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingGif = NO;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if(photos.count>0)
        {
            UIImage *toSendImage = [Common fixOrientation:[photos firstObject]];
            NSString *path = [self writeImage:toSendImage path:nil];
            if(path != nil)
            {
                self.photoPath = path;
                self.iconImgV.image = toSendImage;
            }
        }
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}


- (NSString *)writeImage:(UIImage *)image path:(NSString *)imagePath
{
    if (IsStrEmpty(imagePath)) {
        imagePath = [NSString stringWithFormat:@"%@/%@.jpg", [self photoSavePath], [Common generateGuid]];
    }
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSData *imageData = UIImagePNGRepresentation(image);
    if ([fileManage createFileAtPath:imagePath contents:imageData attributes:nil])
    {
        return imagePath;
    }
    return nil;
}


- (NSString *)photoSavePath{
    NSString *mediaPath = [NSSearchPathForDirectoriesInDomains
                           (NSLibraryDirectory, NSUserDomainMask, YES)
                           objectAtIndex:0];
    mediaPath = [mediaPath stringByAppendingPathComponent:@"cache"];
    mediaPath = [mediaPath stringByAppendingPathComponent:[NSString stringWithFormat:@"media/images"]];
    CreateDirectory(mediaPath);
    return mediaPath;
}


- (void)showNeedCameraAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法使用相机".lv_localized message:@"请在iPhone的\"设置-隐私-相机\"中允许访问相机".lv_localized preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelButton = [UIAlertAction actionWithTitle:@"确定".lv_localized style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancelButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setPhoto:(NSString *)localPath
{
//    [UserInfo show];
    [[TelegramManager shareInstance] setMyPhoto:localPath resultBlock:^(NSDictionary *request, NSDictionary *response) {
//        [UserInfo dismiss];
//        if([TelegramManager isResultError:response])
//        {
//            [UserInfo showTips:nil des:@"头像设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
//        }
        ChatLog(@"头像设置失败+++++%@", response)
    } timeout:^(NSDictionary *request) {
//        [UserInfo dismiss];
//        [UserInfo showTips:nil des:@"头像设置失败，请稍后重试".lv_localized];
    }];
}


- (UIImageView *)iconImgV{
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] init];
        _iconImgV.image = [UIImage imageNamed:@"default_head"];
        _iconImgV.userInteractionEnabled = YES;
        _iconImgV.layer.cornerRadius = 45;
        _iconImgV.clipsToBounds = YES;
        MJWeakSelf
        [_iconImgV xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [weakSelf changeIcon];
        }];
    }
    return _iconImgV;
}

- (UIImageView *)sepImgV{
    if (!_sepImgV) {
        _sepImgV = [[UIImageView alloc] init];
        _sepImgV.backgroundColor = XHQHexColor(0xE5EAF0);
    }
    return _sepImgV;
}

- (UIView *)editView{
    if (!_editView){
        _editView = [[UIView alloc] init];
        _editView.backgroundColor = [UIColor blackColor];
        _editView.alpha = 0.3;
    }
    return _editView;
}
- (UIImageView *)editImageV{
    if (!_editImageV){
        _editImageV = [[UIImageView alloc] init];
        _editImageV.image = [UIImage imageNamed:@"icon_photo"];
    }
    return _editImageV;
}

@end
