//
//  MNTabFindVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/21.
//

#import "MNTabFindVC.h"
#import "GC_FindCell.h"
#import "ComputerLoginViewController.h"
#import "TimelineVC.h"
#import "GC_ExpressionVC.h"
#import "MNScanVC.h"
#import "MNContactDetailVC.h"
#import "TimelineHelper.h"
#import "VideoThumbnailManager.h"
#import "VideoThumbnailDownload.h"
#import "VideoThumbnailStore.h"
#import "TelegramManager.h"
#import "BaseWebViewController.h"
#import "QTTopCell.h"
#import "QTBottomCell.h"
#import "QTGroupPersonInfoVC.h"
#import "QTAddPersonVC.h"

@interface MNTabFindVC ()<UITableViewDelegate,UITableViewDataSource,MNScanVCDelegate>

@property (nonatomic, strong)NSMutableArray *dataArr;

@end

#define kQTTopCell @"QTTopCell"
#define kQTBottomCell @"QTBottomCell"
@implementation MNTabFindVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    // Do any additional setup after loading the view.
    
    [self preloadTimeData];
    
    [[TelegramManager shareInstance] queryDiscoverSections:^(NSDictionary *request, NSDictionary *response, NSArray<DiscoverMenuSectionInfo *> *list) {
        for (DiscoverMenuSectionInfo *info in list) {
            [self.dataArr addObjectsFromArray:info.menus];
        }
        [self.tableView reloadData];
    } timeout:^(NSDictionary *request) {
        
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadMessage];
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
        AppConfigInfo *config = [AppConfigInfo sharedInstance];
        if (config.can_see_blog) {
            [_dataArr addObject:@{@"title": @"朋友圈".lv_localized, @"image": @"icon_find_p"}];
        }
//        [_dataArr addObject:@{@"title": @"扫一扫".lv_localized, @"image": @"icon_find_s"}];
        if (config.can_see_emoji_shop) {
            [_dataArr addObject:@{@"title": @"表情商店".lv_localized, @"image":@"icon_find_b"}];
        }
    }
    return _dataArr;
}
// 预加载朋友圈数据，主要是为了提前下载图片
- (void)preloadTimeData{
    
    [TimelineHelper queryTimelineList:TimelineType_Hot offset:0 completion:^(NSArray<BlogInfo *> * _Nonnull blogs) {
        for (BlogInfo *info in blogs) {
            [self autoDownloadMedia:info];
        }
    }];
    
    [TimelineHelper queryTimelineList:TimelineType_Follow offset:0 completion:^(NSArray<BlogInfo *> * _Nonnull blogs) {
        for (BlogInfo *info in blogs) {
            [self autoDownloadMedia:info];
        }
    }];
    
    [TimelineHelper queryTimelineList:TimelineType_Friend offset:0 completion:^(NSArray<BlogInfo *> * _Nonnull blogs) {
        for (BlogInfo *info in blogs) {
            [self autoDownloadMedia:info];
        }
    }];
}

// 自动下载图片或者视频
-(void)autoDownloadMedia:(BlogInfo *)model{
    if (model.content.isVideoContent) { // 视频
        VideoInfo *video = model.content.video;
        [VideoThumbnailManager.manager thumbnailForVideo:video result:nil];
        
//        [VideoThumbnailDownload.shared downloadThumbnailWithVideo:video result:^(UIImage * _Nullable image) {
//            if (image) {
//                [VideoThumbnailStore storeImage:image withVideoName:video.file_name];
//            }
//        }];
    } else { // 图片
        NSArray<PhotoInfo *> *photos = model.content.photos;
        for (PhotoInfo *photo in photos) {
            if (!photo.messagePhoto.isPhotoDownloaded) {
                long photoId = photo.messagePhoto.photo._id;
                if([[TelegramManager shareInstance] isFileDownloading:photoId type:FileType_Message_Photo]) {
                    return;
                }
                NSString *key = [NSString stringWithFormat:@"timeline_photo_%ld", photoId];
                [[FileDownloader instance] downloadImage:key fileId:photoId type:FileType_Message_Photo];
            }
        }
    }
}

- (void)reloadMessage {
    [TimelineHelper queryUnreadCountCompletion:^(NSInteger count) {
        NSDictionary *first = self.dataArr.firstObject;
        if (first) {
            NSMutableDictionary *list = first.mutableCopy;
            list[@"num"] = @(count);
            [self.dataArr replaceObjectAtIndex:0 withObject:list.copy];
        }
        [self.tableView reloadData];
    }];
}

- (void)initUI{
    [self.customNavBar style_GoChatMessage];
    self.customNavBar.backgroundColor = HEXCOLOR(0xF6F6F6);
    
    [self refreshCustonNavBarFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_STATUS_BAR_HEIGHT+64)];
    
    self.contentView.backgroundColor = HEXCOLOR(0xF6F6F6);
    
    [self.customNavBar setTitle:@"探索".lv_localized];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.contentView.backgroundColor;
    [self.tableView registerClass:[GC_FindCell class] forCellReuseIdentifier:@"cell"];
    [self.tableView registerNib:[UINib nibWithNibName:kQTTopCell bundle:nil] forCellReuseIdentifier:kQTTopCell];
    [self.tableView registerNib:[UINib nibWithNibName:kQTBottomCell bundle:nil] forCellReuseIdentifier:kQTBottomCell];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
    }];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){ // 第一个
        return 20;
    }else if (indexPath.row == self.dataArr.count+1){ // 最后一个
        return 20;
    }else{
        return 70;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){ // 第一个
        QTTopCell *cell = [tableView dequeueReusableCellWithIdentifier:kQTTopCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.shadowView yc_cornerRadius:10 byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
        return cell;
    }else if (indexPath.row == self.dataArr.count+1){ // 最后一个
        QTBottomCell *cell = [tableView dequeueReusableCellWithIdentifier:kQTBottomCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.shadowView yc_cornerRadius:10 byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight];
        return cell;
    }else{
        GC_FindCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        id model = self.dataArr[indexPath.row-1];
        if ([model isKindOfClass:[NSDictionary class]]) {
            cell.dataDic = model;
        } else {
            cell.model = self.dataArr[indexPath.row-1];
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){ // 第一个
        
    }else if (indexPath.row == self.dataArr.count+1){ // 最后一个
        
    }else{
        id model = self.dataArr[indexPath.row-1];
        if ([model isKindOfClass:[NSDictionary class]]) {
            NSDictionary *list = (NSDictionary *)model;
            NSString *title = list[@"title"];
            if ([title isEqualToString:@"朋友圈".lv_localized]) {
                TimelineVC *vc = [[TimelineVC alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            } else if ([title isEqualToString:@"扫一扫".lv_localized]) {
                [self toScan];
            } else if ([title isEqualToString:@"表情商店".lv_localized]) {
                GC_ExpressionVC *vc = [[GC_ExpressionVC alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }else {
            DiscoverMenuInfo *model = self.dataArr[indexPath.row-1];
            BaseWebViewController *v = [BaseWebViewController new];
            v.hidesBottomBarWhenPushed = YES;
            v.isNoZoom = YES;
            v.titleString = model.title;
            v.urlStr = model.url;
            v.type = WEB_LOAD_TYPE_URL;
            [self.navigationController pushViewController:v animated:YES];
        }
    }
}

- (void)toScan{
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self showNeedCameraAlert];
        return;
    }
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized || authStatus == AVAuthorizationStatusNotDetermined)
    {
        MNScanVC *v = [[MNScanVC alloc] init];
//        v.hidesBottomBarWhenPushed = YES;
        v.delegate = self;
        [self.navigationController pushViewController:v animated:YES];
    }
    else
    {
        [self showNeedCameraAlert];
    }
}

-(void)scanVC:(MNScanVC *)scanvc scanResult:(NSString *)result{
    [self ChatQrScanViewController_Result:result];
}

- (void)ChatQrScanViewController_Result:(NSString *)result{
    if(!IsStrEmpty(result))
    {
        
        if ([result containsString:@"login?token"]) {//扫码登录
            ComputerLoginViewController *computerVC = [[ComputerLoginViewController alloc] init];
            computerVC.hidesBottomBarWhenPushed = YES;
            computerVC.link = result;
            [self.navigationController pushViewController:computerVC animated:YES];
            return;
        }
        
        long userId = [[UserInfo shareInstance] userIdFromQrString:result];
        NSString *invitelink = [[UserInfo shareInstance] userIdFromInvitrLink:[NSURL URLWithString:result]];
        if(userId <= 0)
        {
            if(invitelink && invitelink.length > 5){
                //链接进群
                [UserInfo shareInstance].inviteLink = invitelink;
                [((AppDelegate*)([UIApplication sharedApplication].delegate)) addGroupWithInviteLink];
            }else{
                [UserInfo showTips:nil des:@"无效二维码".lv_localized];
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
                        UIViewController *v = [[UIStoryboard storyboardWithName:@"Me" bundle:nil] instantiateViewControllerWithIdentifier:@"MyProfileViewController"];
                        v.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:v animated:YES];
                    }
                    else
                    {
//                        MNContactDetailVC *v = [[MNContactDetailVC alloc] init];
//                        v.user = user;
//                        [self.navigationController pushViewController:v animated:YES];
//
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
    else
    {
        [UserInfo showTips:nil des:@"无效二维码".lv_localized];
    }
}

- (void)showNeedCameraAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法使用相机".lv_localized message:@"请在iPhone的\"设置-隐私-相机\"中允许访问相机".lv_localized preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelButton = [UIAlertAction actionWithTitle:@"确定".lv_localized style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancelButton];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
