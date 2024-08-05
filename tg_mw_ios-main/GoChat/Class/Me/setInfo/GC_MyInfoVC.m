//
//  GC_MyInfoVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/14.
//

#import "GC_MyInfoVC.h"

#import "GC_MySetCell.h"
#import "GC_MyHeaderCell.h"
#import "ModifyFieldViewController.h"
#import "PersonalizedSignatureViewController.h"
#import "MNChatViewController.h"
#import "GC_MyScanVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "GC_ModifyFieldVC.h"
#import "GC_PersonalizedSignatureVC.h"
#import "CountryCodeViewController.h"
#import "QTPickerView.h"
#import "QTSetInfoBottomView.h"
#import "HXPhotoPicker.h"

@interface GC_MyInfoVC ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong)NSArray *dataArr;

@property (nonatomic, strong)UIButton *saveBtn;

@property (nonatomic, strong)  UIImageView *headerImageView;
@property (nonatomic, strong)  UILabel *nickNameLabel;
@property (nonatomic, strong)  UILabel *userNameLabel;
@property (nonatomic, strong)  UILabel *phoneLabel;
@property (nonatomic, strong)  UILabel *markLabel;

@property (nonatomic, strong) NSString *sex;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSString *curCountryCode;
@property (nonatomic, strong) NSString *curCountryName;
@property (nonatomic, strong) NSDictionary *sortedNameDict;

@property (nonatomic,strong)QTPickerView *pickerView;

@property (nonatomic, strong) UserInfoExt *userinfoExt;

@property (strong, nonatomic) HXPhotoManager *photoManager;

@end

@implementation GC_MyInfoVC

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

- (void)dealloc
{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self getUserinfoExt];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    // Do any additional setup after loading the view.
}
- (NSArray *)dataArr{
    if (!_dataArr) {
        AppConfigInfo *config = [AppConfigInfo sharedInstance];
        if (config.can_see_qr_code) {
            NSArray *array0 = @[@"头像".lv_localized];
            NSArray *array01;
            if([AppConfigInfo sharedInstance].can_see_personal_qrcode){
                array01 = @[@"昵称".lv_localized,@"用户名".lv_localized,@"电话号码".lv_localized,@"二维码".lv_localized];
            }else{
                array01 = @[@"昵称".lv_localized,@"用户名".lv_localized,@"电话号码".lv_localized];
            }
           
            NSArray *array02 = @[@"签名".lv_localized,@"性别".lv_localized,@"生日".lv_localized,@"地区".lv_localized];
            
            _dataArr = @[array0, array01, array02];
        } else {
            NSArray *array0 = @[@"头像".lv_localized];
            NSArray *array01 = @[@"昵称".lv_localized,@"用户名".lv_localized,@"电话号码".lv_localized];
            NSArray *array02 = @[@"签名".lv_localized,@"性别".lv_localized,@"生日".lv_localized,@"地区".lv_localized];
            _dataArr = @[array0, array01, array02];
        }
        
    }
    return _dataArr;
}
- (QTPickerView *)pickerView{
    if (!_pickerView) {
        _pickerView = [[QTPickerView alloc]initWithFrame:self.view.bounds];
    }
    return _pickerView;
}

- (UIButton *)saveBtn{
    if (!_saveBtn) {
        _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveBtn setTitle:@"保存".lv_localized forState:UIControlStateNormal];
        [_saveBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
        _saveBtn.titleLabel.font = [UIFont semiBoldCustomFontOfSize:17];
        [_saveBtn addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveBtn;
}

- (void)initUI{
    [self.customNavBar setTitle:@"个人资料".lv_localized];
    self.customNavBar.backgroundColor = [UIColor clearColor];
    
    self.sex = @"";
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_MySetCell" bundle:nil] forCellReuseIdentifier:@"GC_MySetCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_MyHeaderCell" bundle:nil] forCellReuseIdentifier:@"GC_MyHeaderCell"];
    
//    self.tableView.backgroundColor = [UIColor colorForF5F9FA];
    self.tableView.backgroundColor = HEXCOLOR(0xF6F6F6);
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(kNavBarAndStatusBarHeight);
        make.bottom.mas_equalTo(0);
    }];
    self.view.backgroundColor = self.tableView.backgroundColor;
    
    //判断当前系统语言
    if (LanguageIsEnglish)
    {
        NSString *plistPathEN = [[NSBundle mainBundle] pathForResource:@"sortedNameEN" ofType:@"plist"];
        self.sortedNameDict = [[NSDictionary alloc] initWithContentsOfFile:plistPathEN];
        self.curCountryName = @"China";
    }
    else
    {
        NSString *plistPathCH = [[NSBundle mainBundle] pathForResource:@"sortedNameCH" ofType:@"plist"];
        self.sortedNameDict = [[NSDictionary alloc] initWithContentsOfFile:plistPathCH];
        self.curCountryName = @"中国";
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [TelegramManager.shareInstance requestContactFullInfo:UserInfo.shareInstance._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if (obj != nil && [obj isKindOfClass:[UserFullInfo class]]) {
            UserFullInfo *full = (UserFullInfo *)obj;
            self.markLabel.text = full.bio;
        }
    } timeout:nil];
}

- (void)getUserinfoExt {
    NSDictionary *parameters = @{
        @"@type": @"sendCustomRequest",
        @"method": @"users.getUserInfoExt"
    };
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        NSString *result = response[@"result"];
        if ([result isKindOfClass:NSString.class]) {
            NSDictionary *resp = result.mj_JSONObject;
            self.userinfoExt = [UserInfoExt mj_objectWithKeyValues:resp[@"data"]];
            [self.tableView reloadData];
        }
    } timeout:nil];
}

- (void)reloadUserinfoExt:(UserInfoExt *)ext {
    NSDictionary *parameters = @{
        @"@type": @"sendCustomRequest",
        @"method": @"users.setUserInfoExt",
        @"parameters": ext.jsonObject.mj_JSONString
    };
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        NSString *result = response[@"result"];
        if ([result isKindOfClass:NSString.class]) {
            NSDictionary *resp = result.mj_JSONObject;
            if ([resp[@"code"] integerValue] == 200) {
                self.userinfoExt = ext;
                [self.tableView reloadData];
            }
        }
    } timeout:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = self.dataArr[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *array = self.dataArr[indexPath.section];
    NSString *text = array[indexPath.row];
    if (indexPath.section == 0) {
        GC_MyHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_MyHeaderCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLab.text = text;
        cell.lineView.hidden = NO;
        [cell setImageV];
        return cell;
    }
   
    GC_MySetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_MySetCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLab.text = text;
    cell.lineView.hidden = array.count-1==indexPath.row;
    
    cell.erweimaImageV.hidden = YES;
    
    if ([text isEqualToString:@"头像".lv_localized]){

    }else if ([text isEqualToString:@"昵称".lv_localized]){
        cell.contentLab.text = IsStrEmpty([UserInfo shareInstance].displayName)==YES?@"未完善":[UserInfo shareInstance].displayName;
    }else if ([text isEqualToString:@"用户名".lv_localized]){
        cell.contentLab.text = IsStrEmpty([UserInfo shareInstance].username)==YES?@"未完善":[UserInfo shareInstance].username;
    }else if ([text isEqualToString:@"电话号码".lv_localized]){
       // NSString *phone = [UserInfo shareInstance].phone_number;
        if([UserInfo shareInstance].phone_number.length == 11){
            NSString *phone = [UserInfo shareInstance].phone_number;
            NSString *withStr = @"*****";
            NSInteger fromIndex = 3;
            NSRange range = NSMakeRange(fromIndex,  withStr.length);
            NSString *phoneNumber = [phone stringByReplacingCharactersInRange:range  withString:withStr];

            if(![phone hasPrefix:@"+"])
                phone = [NSString stringWithFormat:@"+%@", phone];
            cell.contentLab.text = phone;
        }else{
            cell.contentLab.text = @"未填写";
        }
        
    }else if ([text isEqualToString:@"二维码".lv_localized]){
        cell.contentLab.text = @"";
        cell.erweimaImageV.hidden = NO;
    }else if ([text isEqualToString:@"签名".lv_localized]){
        cell.contentLab.text = IsStrEmpty([UserInfo shareInstance].bio)==YES?@"未完善":[UserInfo shareInstance].bio;
    }else if ([text isEqualToString:@"性别".lv_localized]){
        cell.contentLab.text = self.userinfoExt.sex;
    }else if ([text isEqualToString:@"生日".lv_localized]){
        cell.contentLab.text = IsStrEmpty(self.userinfoExt.birthday)==YES?@"未完善":self.userinfoExt.birthday;
    }else if ([text isEqualToString:@"地区".lv_localized]){
        cell.contentLab.text = self.userinfoExt.countrys;
    }else {
        cell.contentLab.text = @"";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        return 80;
    }else{
        return 60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return section==0?0.01:10;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, section==0?0.01:10)];
    backView.backgroundColor = section==0?HEXCOLOR(0xFFFFFF):HEXCOLOR(0xF6F6F6);
    return backView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *array = self.dataArr[indexPath.section];
    NSString *text = array[indexPath.row];
    
    if ([text isEqualToString:@"头像".lv_localized]){
        [self click_header];
    }else if ([text isEqualToString:@"昵称".lv_localized]){
        [self click_nickname];
    }else if ([text isEqualToString:@"用户名".lv_localized]){
        [self click_username];
    }else if ([text isEqualToString:@"电话号码".lv_localized]){
        
    }else if ([text isEqualToString:@"二维码".lv_localized]){
        [self click_scan];
    }else if ([text isEqualToString:@"签名".lv_localized]){
        [self click_mark];
    }else if ([text isEqualToString:@"性别".lv_localized]){
        [self click_sex];
    }else if ([text isEqualToString:@"生日".lv_localized]){
        [self click_date];
    }else if ([text isEqualToString:@"地区".lv_localized]){
        [self click_country];
    }else {
        
    }
}
- (void)click_country{
    CountryCodeViewController *countryCodeVC = [[CountryCodeViewController alloc] init];
    countryCodeVC.sortedNameDict = self.sortedNameDict;
    countryCodeVC.modifyAreas = YES;
    countryCodeVC.areaBlock = ^(NSString * _Nullable countryName, NSString * _Nullable code, NSString * _Nullable province, NSString * _Nullable city, NSString * _Nullable cityCode) {
        UserInfoExt *ext = UserInfoExt.new;
        ext.birth = self.userinfoExt.birth;
        ext.gender = self.userinfoExt.gender;
        ext.country = countryName;
        ext.countryCode = code;
        ext.province = province;
        ext.city = city;
        ext.cityCode = cityCode;
        [self reloadUserinfoExt:ext];
    };
    __weak __typeof(self)weakSelf = self;
    countryCodeVC.returnCountryCodeBlock = ^(NSString *countryName, NSString *code) {
        weakSelf.curCountryName = countryName;
        NSString *str = [code stringByReplacingOccurrencesOfString:@"+" withString:@""];
        weakSelf.curCountryCode = str;
        [weakSelf.tableView reloadData];
        
        UserInfoExt *ext = UserInfoExt.new;
        ext.birth = self.userinfoExt.birth;
        ext.gender = self.userinfoExt.gender;
        ext.country = countryName;
        ext.countryCode = str;
        [self reloadUserinfoExt:ext];
    };
    [self.navigationController pushViewController:countryCodeVC animated:YES];
}

- (void)click_date {
    [self.pickerView appearWithTitle:@"出生日期".lv_localized selectedStr:IsStrEmpty(self.userinfoExt.birthday)==YES?@"":self.userinfoExt.birthday sureAction:^(NSInteger path, NSString *pathStr) {
        UserInfoExt *ext = UserInfoExt.new;
        NSString *birth = [pathStr stringByReplacingOccurrencesOfString:@"年".lv_localized withString:@"-"];
        birth = [birth stringByReplacingOccurrencesOfString:@"月".lv_localized withString:@"-"];
        birth = [birth stringByReplacingOccurrencesOfString:@"日".lv_localized withString:@""];
        ext.birth = birth;
        ext.country = self.userinfoExt.country;
        ext.countryCode = self.userinfoExt.countryCode;
        ext.gender = self.userinfoExt.gender;
        [self reloadUserinfoExt:ext];
    } cancleAction:^{
        
    }];
   
}

- (void)click_sex{
    UIAlertController *Sheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * manButton = [UIAlertAction actionWithTitle:@"男".lv_localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UserInfoExt *ext = UserInfoExt.new;
        ext.birth = self.userinfoExt.birth;
        ext.country = self.userinfoExt.country;
        ext.countryCode = self.userinfoExt.countryCode;
        ext.gender = 0;
        [self reloadUserinfoExt:ext];
    }];
    [Sheet addAction:manButton];
    UIAlertAction * womanButton = [UIAlertAction actionWithTitle:@"女".lv_localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UserInfoExt *ext = UserInfoExt.new;
        ext.birth = self.userinfoExt.birth;
        ext.country = self.userinfoExt.country;
        ext.countryCode = self.userinfoExt.countryCode;
        ext.gender = 1;
        [self reloadUserinfoExt:ext];
    }];
    [Sheet addAction:womanButton];
    UIAlertAction * cancelButton = [UIAlertAction actionWithTitle:@"取消".lv_localized style:UIAlertActionStyleCancel handler:nil];
    [Sheet addAction:cancelButton];
    [self presentViewController:Sheet animated:YES completion:nil];
}
- (void)click_header
{
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
            UIImage *thum_image = image;
            
            UIImage *toSendImage = thum_image;
            NSString *path = [MNChatViewController localPhotoPath:toSendImage];
            if(path != nil)
            {
                [self setPhoto:path];
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
        NSString *path = [MNChatViewController localPhotoPath:toSendImage];
        if(path != nil)
        {
            [self setPhoto:path];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)click_avatar{
    [self hx_presentSelectPhotoControllerWithManager:self.photoManager didDone:^(NSArray<HXPhotoModel *> * _Nullable allList, NSArray<HXPhotoModel *> * _Nullable photoList, NSArray<HXPhotoModel *> * _Nullable videoList, BOOL isOriginal, UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
        //
        HXPhotoModel *model = allList.firstObject;
        UIImage *image = [self getImageFromHXPhotoModel:model];
        if (image) {
//            UIImage *thum_image = [UIImage thumbnailWithImage:image size:CGSizeMake(200, 200)];
            UIImage *thum_image = image;
            
            UIImage *toSendImage = thum_image;
            NSString *path = [MNChatViewController localPhotoPath:toSendImage];
            if(path != nil)
            {
                [self setPhoto:path];
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
            NSString *path = [MNChatViewController localPhotoPath:toSendImage];
            if(path != nil)
            {
                [self setPhoto:path];
            }
        }
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}
- (void)click_scan{
    GC_MyScanVC *vc = [[GC_MyScanVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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
    MJWeakSelf
    [UserInfo show];
    [[TelegramManager shareInstance] setMyPhoto:localPath resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        [weakSelf.tableView reloadData];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"头像设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"头像设置失败，请稍后重试".lv_localized];
    }];
}

- (void)click_nickname
{
//    GC_ModifyFieldVC *vc = [[GC_ModifyFieldVC alloc] init];
//    vc.fieldType = ModifyFieldType_Set_My_Nickname;
//    [self.navigationController pushViewController:vc animated:YES];
    
    MJWeakSelf
    [[QTSetInfoBottomView sharedInstance] alertViewType:QT_Set_My_Nickname TitleStr:@"昵称" ContentStr:[UserInfo shareInstance].displayName PlaceStr:@"请输入昵称"];
    [[QTSetInfoBottomView sharedInstance] setSuccessBlock:^(NSString * _Nonnull contentStr) {
        //
        [weakSelf.tableView reloadData];
    }];
}

- (void)click_username
{
    GC_ModifyFieldVC *vc = [[GC_ModifyFieldVC alloc] init];
    vc.fieldType = ModifyFieldType_Set_My_Username;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)click_mark
{
    GC_PersonalizedSignatureVC *vc = [[GC_PersonalizedSignatureVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)saveAction{
    
}
#pragma mark BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_UpdateUserInfo):
        {
            [self.tableView reloadData];
            __block UserInfo *userInfo = [UserInfo shareInstance];
            [[TelegramManager shareInstance] requestOrgContactInfo:userInfo._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                if(obj != nil && [obj isKindOfClass:[OrgUserInfo class]])
                {
                    userInfo.orgUserInfo = obj;
                }
            } timeout:^(NSDictionary *request) {
            }];
        }
            break;
        case MakeID(EUserManager, EUser_Td_Contact_Photo_Ok):
        {
            UserInfo *updateUser = inParam;
            if(updateUser != nil && [updateUser isKindOfClass:[UserInfo class]] && updateUser._id == [UserInfo shareInstance]._id)
            {
                [self.tableView reloadData];
            }
        }
            break;
        default:
            break;
    }
}



@end
