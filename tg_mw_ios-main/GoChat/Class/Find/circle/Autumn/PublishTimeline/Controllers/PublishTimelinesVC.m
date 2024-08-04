//
//  PublishTimelinesVC.m
//  GoChat
//
//  Created by Autumn on 2022/1/5.
//

#import "PublishTimelinesVC.h"
#import "PublishPrivacyVC.h"
#import "SelectMemberVC.h"
#import "TimelineLocationVC.h"
#import "PublishTopicSelectedVC.h"
#import "MNAddGroupVC.h"

#import "PublishTimeline.h"
#import "VideoCompress.h"
#import "TZVideoEditedPreviewController.h"

#import "HXPhotoPicker.h"

#import "PublishTimelineInputCell.h"
#import "PublishTimelineMediaCell.h"
#import "PublishTimelinePhotoCell.h"
#import "PublishTimelineRemindHeaderView.h"
#import "PublishTimelineRemindCell.h"
#import "PublishTimeLabelCell.h"
#import "PublishTimelineSelectedCell.h"
#import "PublishTimelineSectionFooterView.h"

#import <MobileCoreServices/MobileCoreServices.h>

/// 内容输入类型
typedef NS_ENUM(NSInteger, InputKey) {
    InputKey_Nil,
    InputKey_Topic,
    InputKey_At,
};

@interface PublishTimelinesVC ()<
TZImagePickerControllerDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
HXCustomNavigationControllerDelegate,
HXPhotoViewDelegate,
UITextViewDelegate,
MNChooseUserDelegate,
TopicSelectedDelegate>

@property (nonatomic, strong) NSArray *footerHeights;

@property (nonatomic, strong) UIImagePickerController *imagePickerVC;
@property (nonatomic, strong) PublishTopicSelectedVC *topicSelectedVC;

@property (nonatomic, strong) PublishTimeline *timeline;
@property (nonatomic, strong) NSMutableArray *selectedAssets;

@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, assign) InputKey inputKey;
/// 话题输入但还未确定的range
@property (nonatomic) NSRange topicUnSelectedRange;
@property (nonatomic, strong) NSDictionary *defaultInputAttributes;
@property (nonatomic, strong) NSDictionary *highAttributes;
/// 文本内容包含的高亮 range
@property (nonatomic, strong) NSMutableArray *inputRanges;

@property (nonatomic, strong) HXPhotoView *photoView;

@property (nonatomic, assign) CGFloat photoItemHeight;

@end



static NSInteger const maxVideoDuration = 180;

static NSString *const text_topic = @"#";
static NSString *const text_at = @"@";
static NSString *const text_space = @" ";
static NSString *const text_return = @"\n";
static NSString *const text_delete = @"";

@implementation PublishTimelinesVC

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
        [self.photoManager clearSelectedList];
    }
}

- (void)dealloc {
    [self xhq_removeAllObserveNotification];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.topicSelectedVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(0);
        make.top.mas_equalTo(kNavigationStatusHeight() + 120);
    }];
}

- (void)dy_initData {
    [super dy_initData];
    self.photoItemHeight = (kScreenWidth() - 50 - 20) / 3;
    self.defaultInputAttributes = @{NSFontAttributeName: UIFont.xhq_font16,
                                    NSForegroundColorAttributeName: XHQHexColor(0x04020C)};
    self.highAttributes = @{NSFontAttributeName: UIFont.xhq_font16,
                            NSForegroundColorAttributeName: UIColor.colorMain};
    self.inputRanges = NSMutableArray.array;
    [self xhq_addObserveNotification:UIKeyboardDidShowNotification];
    [self dy_configureData];
}


- (void)dy_initUI {
    [super dy_initUI];
    
  
    [self.customNavBar setTitle:@"朋友圈".lv_localized];
   
    [self setupNavigationItem];
    
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView xhq_registerCell:PublishTimelineInputCell.class];
    [self.collectionView xhq_registerCell:PublishTimelineMediaCell.class];
    [self.collectionView xhq_registerCell:PublishTimelinePhotoCell.class];
    [self.collectionView xhq_registerCell:PublishTimeLabelCell.class];
    [self.collectionView xhq_registerCell:PublishTimelineSelectedCell.class];
    [self.collectionView xhq_registerFooterView:PublishTimelineSectionFooterView.class];
    [self.collectionView xhq_registerHeaderView:PublishTimelineRemindHeaderView.class];
    
    [self addChildViewController:self.topicSelectedVC];
    [self.view addSubview:self.topicSelectedVC.view];
}

- (void)setupNavigationItem {
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:@"发布".lv_localized forState:UIControlStateNormal];
    [rightBtn xhq_cornerRadius:4];
    rightBtn.titleLabel.font = [UIFont helveticaFontOfSize:15];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBtn.backgroundColor = [UIColor colorMain];
    [rightBtn addTarget:self action:@selector(publishAction) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBar addSubview:rightBtn];
    
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.width.mas_equalTo(55);
        make.height.mas_equalTo(29);
        make.bottom.mas_equalTo(-8);
    }];
}

- (void)dy_configureData {
    [self.dataArray makeObjectsPerformSelector:@selector(removeAllObjects)];
    [self.dataArray removeAllObjects];
    PublishTimelineInputCellItem *iItem = PublishTimelineInputCellItem.item;
    iItem.cellModel = self.timeline;
    [self.sectionArray0 addObject: iItem];
    [self.dataArray addObject:self.sectionArray0];
    
    PublishTimelinePhotoCellItem *pItem = PublishTimelinePhotoCellItem.item;
    pItem.customView = self.photoView;
    pItem.cellSize = CGSizeMake(kScreenWidth() - 50, _photoItemHeight);
    [self.sectionArray1 addObject:pItem];
    [self.dataArray addObject:self.sectionArray1];
    
    PublishTimeLabelCellItem *litem = PublishTimeLabelCellItem.item;
    litem.label = PublishTimeLabelType_At;
    [self.sectionArray2 addObject:litem];
    
    litem = PublishTimeLabelCellItem.item;
    litem.label = PublishTimeLabelType_Topic;
    [self.sectionArray2 addObject:litem];
    [self.dataArray addObject:self.sectionArray2];
    
    PublishTimelineSelectedCellItem *sItem = PublishTimelineSelectedCellItem.item;
    sItem.title = @"谁可以看".lv_localized;
    sItem.content = self.timeline.visible.visibleTypeTitle;
    [self.sectionArray3 addObject:sItem];
    [self.dataArray addObject:self.sectionArray3];
    
    sItem = PublishTimelineSelectedCellItem.item;
    sItem.title = @"所在位置".lv_localized;
    if (self.timeline.location.address) {
        sItem.content = self.timeline.location.address;
        sItem.changeColor = YES;
    } else {
        sItem.content = @"点击选择".lv_localized;
    }
    [self.sectionArray4 addObject:sItem];
    [self.dataArray addObject:self.sectionArray4];
    
    self.footerHeights = @[@0, @40, @20, @1, @0];
}

#pragma mark - Noti
- (void)xhq_handleNotification:(NSNotification *)notification {
    if ([notification xhq_isNotification:UIKeyboardDidShowNotification]) {
        CGRect endFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        [self.topicSelectedVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-endFrame.size.height - kHomeIndicatorHeight());
        }];
    }
}

#pragma mark - Event
/// 公开性选择
- (void)privacySelected {
    PublishPrivacyVC *privacy = [[PublishPrivacyVC alloc] init];
    privacy.timeline = self.timeline;
    privacy.confirmBlock = ^{
        [self dy_configureData];
        [self.collectionView reloadData];
    };
    [self.navigationController pushViewController:privacy animated:YES];
}

- (void)remindSelected {
    SelectMemberVC *member = [[SelectMemberVC alloc] init];
    member.from = SelectMemberFromContact;
    member.selectedContacts = _timeline.metions.mutableCopy;
    [self.navigationController pushViewController:member animated:YES];
    member.contactBlock = ^(NSArray<UserInfo *> * _Nonnull contacts) {
        self.timeline.metions = contacts;
        [self dy_configureData];
        [self.collectionView reloadData];
    };
}


- (void)tzImagePicker {
    [self hx_presentSelectPhotoControllerWithManager:self.photoManager delegate:self];
}

/// 预览视频
- (void)previewMedia:(NSIndexPath *)indexPath {
    if ([_selectedAssets[indexPath.item] isKindOfClass:NSURL.class]) {
        TZVideoEditedPreviewController *vc = [[TZVideoEditedPreviewController alloc] init];
        vc.videoURL = _selectedAssets[indexPath.item];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        PHAsset *asset = _selectedAssets[indexPath.item];
        BOOL isVideo = asset.mediaType == PHAssetMediaTypeVideo;
        if (isVideo) {
            TZVideoPlayerController *vc = [[TZVideoPlayerController alloc] init];
            TZAssetModel *model = [TZAssetModel modelWithAsset:asset type:TZAssetModelMediaTypeVideo timeLength:@""];
            vc.model = model;
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:vc animated:YES completion:nil];
            return;
        }
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:_selectedAssets.mutableCopy selectedPhotos:_timeline.contents.images.mutableCopy index:indexPath.item];
        imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
        imagePickerVc.photoPreviewPageUIConfigBlock = ^(UICollectionView *collectionView, UIView *naviBar, UIButton *backButton, UIButton *selectButton, UILabel *indexLabel, UIView *toolBar, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIButton *editButton) {
            editButton.hidden = YES;
        };
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            self->_timeline.contents.images = [NSMutableArray arrayWithArray:photos];
            self->_selectedAssets = [NSMutableArray arrayWithArray:assets];
            [self dy_configureData];
            [self.collectionView reloadData];
        }];
        [self presentViewController:imagePickerVc animated:YES completion:nil];
    }
}

/// 位置选择
- (void)locationSelected {
    TimelineLocationVC *location = [[TimelineLocationVC alloc] init];
    location.location = self.timeline.location;
    location.block = ^{
        [self dy_configureData];
        [self.collectionView reloadData];
    };
    [self.navigationController pushViewController:location animated:YES];
}


- (void)publishAction {
    [self.view endEditing:YES];
    @weakify(self);
    [self exportMediaSuccess:^{
        @strongify(self);
        [UserInfo show:@"正在发布...".lv_localized];
        /// 如果有选中群组，则需要获取群组成员
        [self.timeline fetchSelectedGroupMembersCompletion:^{
            [TelegramManager.shareInstance publishTimeline:self.timeline.jsonObject result:^(NSDictionary *request, NSDictionary *response) {
                [UserInfo dismiss];
                if (![response[@"@type"] isEqualToString:@"blog"]) {
                    [UserInfo showTips:self.view des:response[@"message"]];
                    return;
                }
                [UserInfo showTips:nil des:@"发布成功".lv_localized];
                BlogInfo *blog = [BlogInfo mj_objectWithKeyValues:response];
                int noti = MakeID(EUserManager, EUser_Timeline_Publish_Success);
                [BusinessFramework.defaultBusinessFramework broadcastBusinessNotify:noti withInParam:blog];
                [self.navigationController popViewControllerAnimated:YES];
            } timeout:^(NSDictionary *request) {
                [UserInfo dismiss];
                [UserInfo showTips:self.view des:@"发布超时".lv_localized];
            }];
        }];
    }];
}

- (void)exportMediaSuccess:(dispatch_block_t)success {
    if (self.photoManager.afterSelectedArray.count == 0) {
        [UserInfo showTips:self.view des:@"请选择发布视频或图片".lv_localized];
        return;
    }
    HXPhotoModel *first = self.photoManager.afterSelectedArray.firstObject;
    BOOL isVideo = first.subType == HXPhotoModelMediaSubTypeVideo;
    if (isVideo) {
        [self exportVideoSuccess:success];
    } else {
        [self exportImagesSuccess:success];
    }
}

- (void)exportVideoSuccess:(dispatch_block_t)success {
    [UserInfo show:@"正在处理视频文件，请耐心等待".lv_localized];
    HXPhotoModel *videoModel = self.photoManager.afterSelectedArray.firstObject;
    @weakify(self);
    [videoModel getAssetURLWithVideoPresetName:AVAssetExportPresetHighestQuality success:^(NSURL * _Nullable URL, HXPhotoModelMediaSubType mediaType, BOOL isNetwork, HXPhotoModel * _Nullable model) {
        @strongify(self);
        self.timeline.contents.video.outputPath = URL.path;
        [videoModel getImageWithSuccess:^(UIImage * _Nullable image, HXPhotoModel * _Nullable model, NSDictionary * _Nullable info) {
            [UserInfo dismiss];
            self.timeline.contents.video.thumbnailImage = image;
            !success ? : success();
        } failed:^(NSDictionary * _Nullable info, HXPhotoModel * _Nullable model) {
            [UserInfo dismiss];
            self.timeline.contents.video.thumbnailImage = UIImage.new;
            !success ? : success();
        }];
    } failed:^(NSDictionary * _Nullable info, HXPhotoModel * _Nullable model) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"视频处理失败".lv_localized];
    }];
}

- (void)exportImagesSuccess:(dispatch_block_t)success {
    [UserInfo show];
    NSArray *selecteds = self.photoManager.afterSelectedArray;
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int idx = 0; idx < selecteds.count; idx ++) {
        [images addObject:UIImage.new];
    }
    dispatch_group_t group = dispatch_group_create();
    [selecteds enumerateObjectsUsingBlock:^(HXPhotoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_enter(group);
        if (obj.photoEdit) {
            [images replaceObjectAtIndex:idx withObject:obj.photoEdit.editPreviewImage];
            dispatch_group_leave(group);
        } else {
            [obj getImageWithSuccess:^(UIImage * _Nullable image, HXPhotoModel * _Nullable model, NSDictionary * _Nullable info) {
                dispatch_group_leave(group);
                [images replaceObjectAtIndex:idx withObject:image];
            } failed:^(NSDictionary * _Nullable info, HXPhotoModel * _Nullable model) {
                dispatch_group_leave(group);
            }];
        }
    }];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [UserInfo dismiss];
        self.timeline.contents.images = images.copy;
        !success ? : success();
    });
}

#pragma mark - UICollectionViewDataSource
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        return [super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    }
    if (indexPath.section == 0 || indexPath.section == self.dataArray.count - 1) {
        return [super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    }
    PublishTimelineSectionFooterView *footer = [collectionView xhq_dequeueFooterView:[PublishTimelineSectionFooterView class]
                                                                           indexPath:indexPath];
    return footer;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return section == 2 ? UIEdgeInsetsMake(0, 25, 0, 25) : UIEdgeInsetsMake(0, 25, 0, 25);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (section == 0 || section == self.dataArray.count - 1) {
        return CGSizeZero;
    }
    return CGSizeMake(kScreenWidth(), [self.footerHeights[section] floatValue]);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:PublishTimelineInputCell.class]) {
        PublishTimelineInputCell *inputCell = (PublishTimelineInputCell *)cell;
        self.textView = inputCell.textView;
        self.textView.delegate = self;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (section == 2) {
        return 10;
    }
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (section == 2) {
        return 10;
    }
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DYCollectionViewCellItem *item = self.dataArray[indexPath.section][indexPath.item];
    if ([item isKindOfClass:PublishTimelineRemindCellItem.class]) {
        [self remindSelected];
    } else if ([item isKindOfClass:PublishTimeLabelCellItem.class]) {
        PublishTimeLabelCellItem *m = (PublishTimeLabelCellItem *)item;
        [self.textView becomeFirstResponder];
        self.inputKey = InputKey_Nil;
        switch (m.label) {
            case PublishTimeLabelType_At: {
                [self textView:self.textView shouldChangeTextInRange:self.textView.selectedRange replacementText:text_at];
            }
                break;
            case PublishTimeLabelType_Topic: {
                if (self.timeline.entities.topicEntities.count >= 5) {
                    [UserInfo showTips:nil des:@"最多只能输入五个话题".lv_localized];
                    return;
                }
                [self textView:self.textView shouldChangeTextInRange:self.textView.selectedRange replacementText:text_topic];
                [self.textView insertText:text_topic];
            }
                break;
        }
    } else if ([item isKindOfClass:PublishTimelineSelectedCellItem.class]) {
        PublishTimelineSelectedCellItem *m = (PublishTimelineSelectedCellItem *)item;
        [m.title isEqualToString:@"谁可以看".lv_localized] ? [self privacySelected] : [self locationSelected];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:PublishTimelinePhotoCell.class]) {
        cell.layer.zPosition = 999;
    }
}

/// 本地视频处理
- (void)localVideoProcessing:(PHAsset *)asset coverImage:(UIImage *)coverImage {
    [UserInfo show:@"正在处理视频文件，请耐心等待".lv_localized];
    @weakify(self);
    [VideoCompress createVideoFileWithVideo:asset result:^(NSError * _Nonnull error, NSString * _Nonnull videoPath, CGSize size, int duration) {
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [UserInfo dismiss];
            if (error) {
                [UserInfo showTips:nil des:error.domain];
                return;
            }
            self.timeline.contents.video.thumbnailImage = coverImage;
            self.timeline.contents.video.outputPath = videoPath;
            self.selectedAssets = @[asset].mutableCopy;
            [self dy_configureData];
            [self.collectionView reloadData];
        });
    }];
}

#pragma mark - < HXCustomNavigationControllerDelegate >
- (void)photoNavigationViewControllerFinishDismissCompletion:(HXCustomNavigationController *)photoNavigationViewController {

}

- (void)photoNavigationViewController:(HXCustomNavigationController *)photoNavigationViewController
                       didDoneAllList:(NSArray<HXPhotoModel *> *)allList
                               photos:(NSArray<HXPhotoModel *> *)photoList
                               videos:(NSArray<HXPhotoModel *> *)videoList
                             original:(BOOL)original {

}

#pragma mark - HXPhotoViewDelegate
- (void)photoView:(HXPhotoView *)photoView updateFrame:(CGRect)frame {
    self.photoItemHeight = CGRectGetHeight(frame);
    PublishTimelinePhotoCellItem *item = self.sectionArray1.firstObject;
    item.cellSize = CGSizeMake(kScreenWidth() - 50, self.photoItemHeight);
    [self.collectionView reloadData];
}

- (void)photoViewDidAddCellClick:(HXPhotoView *)photoView {
    
}

#pragma mark - UIImagePickerController

- (void)takePhoto:(NSString *)mediaType {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        XHQAlertSingleAction(@"无法使用相机".lv_localized, @"请在iPhone的""设置-隐私-相机""中允许访问相机".lv_localized, @"设置".lv_localized, @"取消".lv_localized, ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        });
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self takePhoto:mediaType];
                });
            }
        }];
    } else if ([PHPhotoLibrary authorizationStatus] == 2) {
        XHQAlertSingleAction(@"无法访问相册".lv_localized, @"请在iPhone的""设置-隐私-相册""中允许访问相册".lv_localized, @"设置".lv_localized, @"取消".lv_localized, ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        });
    } else if ([PHPhotoLibrary authorizationStatus] == 0) {
        [[TZImageManager manager] requestAuthorizationWithCompletion:^{
            [self takePhoto:mediaType];
        }];
    } else {
        [self pushImagePickerController:mediaType];
    }
}

// 调用相机
- (void)pushImagePickerController:(NSString *)mediaType {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        self.imagePickerVC.sourceType = sourceType;
        _imagePickerVC.mediaTypes = @[mediaType];
        [self presentViewController:_imagePickerVC animated:YES completion:nil];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    [tzImagePickerVc showProgressHUD];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSDictionary *meta = [info objectForKey:UIImagePickerControllerMediaMetadata];
        [[TZImageManager manager] savePhotoWithImage:image meta:meta location:nil completion:^(PHAsset *asset, NSError *error){
            [tzImagePickerVc hideProgressHUD];
            if (error) {
                NSLog(@"图片保存失败 %@",error);
            } else {
                TZAssetModel *assetModel = [[TZImageManager manager] createModelWithAsset:asset];
                [self refreshCollectionViewWithAddedAsset:assetModel.asset image:image];
            }
        }];
    } else if ([type isEqualToString:@"public.movie"]) {
        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        if (videoUrl) {
            [[TZImageManager manager] saveVideoWithUrl:videoUrl location:nil completion:^(PHAsset *asset, NSError *error) {
                [tzImagePickerVc hideProgressHUD];
                if (!error) {
                    TZAssetModel *assetModel = [[TZImageManager manager] createModelWithAsset:asset];
                    [[TZImageManager manager] getPhotoWithAsset:assetModel.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                        if (!isDegraded && photo) {
                            [self refreshCollectionViewWithAddedAsset:assetModel.asset image:photo];
                        }
                    }];
                }
            }];
        }
    }
}

- (void)refreshCollectionViewWithAddedAsset:(PHAsset *)asset image:(UIImage *)image {
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        [self localVideoProcessing:asset coverImage:image];
        return;
    }
    [_selectedAssets addObject:asset];
    [_timeline.contents.images addObject:image];
    [self dy_configureData];
    [self.collectionView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    _timeline.contents.images = photos.mutableCopy;
    _selectedAssets = assets.mutableCopy;
    [self dy_configureData];
    [self.collectionView reloadData];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset {
    [self localVideoProcessing:asset coverImage:coverImage];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingAndEditingVideo:(UIImage *)coverImage outputPath:(NSString *)outputPath error:(NSString *)errorMsg {
    _timeline.contents.video.thumbnailImage = coverImage;
    _timeline.contents.video.outputPath = outputPath;
    _selectedAssets = @[[NSURL fileURLWithPath:outputPath]].mutableCopy;
    [self dy_configureData];
    [self.collectionView reloadData];
}

- (BOOL)isAssetCanBeSelected:(PHAsset *)asset {
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        NSTimeInterval duration = asset.duration;
       if (duration > maxVideoDuration) {
           NSString *text = [NSString stringWithFormat:@"不支持选择时长超过%lds的视频".lv_localized, maxVideoDuration];
           XHQAlertText(text);
           return NO;
       }
    }
    return YES;
}

#pragma mark - UITextDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.inputKey = InputKey_Nil;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (self.inputKey == InputKey_Topic) {
        [self textView:self.textView shouldChangeTextInRange:self.textView.selectedRange replacementText:text_space];
    }
    self.inputKey = InputKey_Nil;
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.timeline.text = textView.text;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    textView.typingAttributes = self.defaultInputAttributes;
    /// 高亮类型被选中了
    NSString *rangeString = NSStringFromRange(range);
    if ([self.inputRanges containString:rangeString]) {
        if ([text isEqualToString:text_delete]) {
            [self.inputRanges removeObject:rangeString];
            [self.timeline.entities removeEntityWithRange:range];
            [textView replaceRange:textView.selectedTextRange withText:@""];
            [self reloadInputRangesLocationWithRange:range text:text];
            return NO;
        } else {
            textView.selectedRange = NSMakeRange(range.location + range.length, 0);
            return NO;
        }
    }
    
    if ([text isEqualToString:text_delete]) {
        /// 是否选中高亮类型
        NSString *rangeString = [self isDeleteHighLightRange:range];
        if (rangeString) {
            textView.selectedRange = NSRangeFromString(rangeString);
            return NO;
        }
        /// 处理话题类型
        if (self.inputKey == InputKey_Topic) {
            if (self.topicSelectedVC.keyword.length == 0) {
                self.inputKey = InputKey_Nil;
            } else {
                NSString *keyword = self.topicSelectedVC.keyword;
                keyword = [keyword substringToIndex:keyword.length - 1];
                self.topicSelectedVC.keyword = keyword;
            }
        }
        [self reloadInputRangesLocationWithRange:range text:text];
        return YES;
    }
    
    /// 空格键作为终止话题的尾
//    if (([text isEqualToString:text_space] || [text isEqualToString:text_return]) && self.inputKey == InputKey_Topic) {
//        self.inputKey = InputKey_Nil;
//        [self reloadInputRangesLocationWithRange:range text:text];
//        return YES;
//    }
    /// 输入 `@` 弹出好友页面
    if ([text isEqualToString:text_at] && self.inputKey == InputKey_Nil) {
        self.inputKey = InputKey_At;
        [self reloadInputRangesLocationWithRange:range text:text];
        return YES;
    }
    
    /// 输入 `#` 弹出话题页面
    if ([text isEqualToString:text_topic] && self.inputKey == InputKey_Nil && self.timeline.entities.topicEntities.count < 5) {
        /// 标记输入话题的位置
        self.topicUnSelectedRange = range;
        self.inputKey = InputKey_Topic;
        [self reloadInputRangesLocationWithRange:range text:text];
        return YES;
    }
    
    /// 输入话题中...
    if (self.inputKey == InputKey_Topic) {
        /// 光标的位置小于记录值，说明光标被移动了
        if (self.topicUnSelectedRange.location > range.location) {
            self.inputKey = InputKey_Nil;
        } else {
            /// 获取 `#` 到当前光标的距离
            /// 优先处理 换行和空格，为选中话题
            if ([text isEqualToString:text_space] || [text isEqualToString:text_return]) {
                /// 有内容时，直接转为换题，没有内容时，默认输入#
                if (self.topicSelectedVC.keyword.length > 0) {
                    [self selectedTopic:[BlogTopic topicWithKeyword:self.topicSelectedVC.keyword]];
                } else {
                    self.inputKey = InputKey_Nil;
                }
                [self reloadInputRangesLocationWithRange:range text:text];
                return YES;
            }
            
            NSUInteger location = self.topicUnSelectedRange.location + 1;
            NSRange newRange = NSMakeRange(location, range.location - location);
            if (NSMaxRange(newRange) > textView.text.length) {
                self.inputKey = InputKey_Nil;
                [self reloadInputRangesLocationWithRange:range text:text];
                return YES;
            }
            NSString *keyword = [textView.text substringWithRange:newRange];
            keyword = [keyword stringByAppendingString:text];
            if (keyword.length > 10) {
                [self textView:self.textView shouldChangeTextInRange:self.textView.selectedRange replacementText:text_space];
                [self reloadInputRangesLocationWithRange:range text:text];
                return YES;
            }
            self.topicSelectedVC.keyword = keyword;
        }
        [self reloadInputRangesLocationWithRange:range text:text];
        return YES;
    }
    [self reloadInputRangesLocationWithRange:range text:text];
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSRange selectedRange = [self isInRange:textView];
    if (!NSEqualRanges(selectedRange, NSMakeRange(0, 0))) {
        textView.selectedRange = selectedRange;
        return;
    }
}

/// textView 删除时，检测当前光标是否在标签的尾部
/// 是的话直接选中标签，下次整体删除。
/// 而不是删除标签中的某个文字
- (NSString *)isDeleteHighLightRange:(NSRange)dRange {
    NSArray *ranges = self.inputRanges;
    for (NSString *r in ranges) {
        NSRange range = NSRangeFromString(r);
        if (NSMaxRange(range) == NSMaxRange(dRange)) {
            return NSStringFromRange(range);
        }
    }
    return nil;
}

/// 光标是否在标签的范围内
/// 在范围内则，直接选中标签。
/// 禁止对标签进行再编辑处理操作
- (NSRange)isInRange:(UITextView *)textView {
    NSAttributedString *text = _textView.attributedText;
    NSRange selectedRange = _textView.selectedRange;
    if (!text || text.length == 0) {
        return NSMakeRange(0, 0);
    }
    NSArray *ranges = self.inputRanges;
    if (ranges.count == 0) {
        return NSMakeRange(0, 0);
    }
    __block NSRange selected = NSMakeRange(0, 0);
    [ranges enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = NSRangeFromString(obj);
        if (NSLocationInRange(selectedRange.location, range)) {
            selected = range;
            *stop = YES;
        }
    }];
    return selected;
}

- (void)atSomeone {
    MNAddGroupVC *chooseView = [[MNAddGroupVC alloc] init];
    chooseView.chooseType = MNContactChooseType_Timeline_At_Someone;
    chooseView.delegate = self;
    [self.navigationController pushViewController:chooseView animated:YES];
}

/// 重新校正选中标签的 range.location 值
/// 用户操作时，可能会切换光标位置，进行增删改操作。
/// 这可能会导致之前加入的标签的 range 值发生变动，造成错位。
- (void)reloadInputRangesLocationWithRange:(NSRange)range text:(NSString *)text {
    if (self.inputRanges.count == 0) {
        return;
    }
    NSMutableArray *temps = NSMutableArray.array;
    for (NSString *rs in self.inputRanges) {
        NSRange r = NSRangeFromString(rs);
        if (range.location >= r.location) {
            [temps addObject:rs];
            continue;
        }
        /// 删除
        if ([text isEqualToString:@""]) {
            r.location = r.location - range.length;
        } else {
            r.location = r.location + text.length;
        }
        [temps addObject:NSStringFromRange(r)];
        [self.timeline.entities replaceRange:NSRangeFromString(rs) withNewRange:r];
    }
    self.inputRanges = temps.mutableCopy;
}

#pragma mark - MNChooseUserDelegate
- (void)chooseUser:(UserInfo *)user {
    NSRange preRange = NSMakeRange(self.textView.selectedRange.location - 1, 1);
    if (preRange.location >= 0) {
        NSString *text = [self.textView.text substringWithRange:preRange];
        if ([text isEqualToString:text_at]) {
            [self.textView deleteBackward];
        }
    }
    NSString *someone = [NSString stringWithFormat:@"@%@ ", user.displayName];
    [self.textView insertText:someone];
    NSMutableAttributedString *attributedText = self.textView.attributedText.mutableCopy;
    NSRange range = NSMakeRange(self.textView.selectedRange.location - someone.length, someone.length);
    if (range.location < 0) {
        return;
    }
    [attributedText setAttributes:self.highAttributes range:range];
    [self.inputRanges addObject:NSStringFromRange(range)];
    [self.timeline.entities addAtUser:user._id range:range];
    self.textView.attributedText = attributedText;
    self.textView.selectedRange = NSMakeRange(range.location + range.length, 0);
}

- (void)chooseClose {
    self.inputKey = InputKey_Nil;
}

#pragma mark - TopicSelectedDelegate
- (void)selectedTopic:(BlogTopic *)topic {
    NSRange preRange = NSMakeRange(self.topicUnSelectedRange.location, self.textView.selectedRange.location - self.topicUnSelectedRange.location);
    if (preRange.location >= 0) {
        NSString *text = [self.textView.text substringWithRange:preRange];
        if ([text hasPrefix:text_topic]) {
            self.textView.selectedRange = preRange;
            [self.textView insertText:@""];
        }
    }
    
    NSString *name = [NSString stringWithFormat:@"#%@ ", topic.name];
    [self.textView insertText:name];
    NSMutableAttributedString *attributedText = self.textView.attributedText.mutableCopy;
    NSRange range = NSMakeRange(self.textView.selectedRange.location - name.length, name.length);
    if (range.location < 0) {
        return;
    }
    [attributedText setAttributes:self.highAttributes range:range];
    [self.inputRanges addObject:NSStringFromRange(range)];
    [self.timeline.entities addTopic:topic.name range:range];
    self.textView.attributedText = attributedText;
    self.textView.selectedRange = NSMakeRange(range.location + range.length, 0);
    self.inputKey = InputKey_Nil;
}


#pragma mark - setter
- (void)setInputKey:(InputKey)inputKey {
    _inputKey = inputKey;
    switch (inputKey) {
        case InputKey_Nil: {
            [self.topicSelectedVC hide];
        }
            break;
        case InputKey_Topic: {
            self.topicSelectedVC.keyword = @"";
        }
            break;
        case InputKey_At: {
            [self atSomeone];
        }
            break;
    }
}


#pragma mark - getter
- (UIImagePickerController *)imagePickerVC {
    if (_imagePickerVC == nil) {
        _imagePickerVC = [[UIImagePickerController alloc] init];
        _imagePickerVC.delegate = self;
        _imagePickerVC.videoMaximumDuration = maxVideoDuration;
        _imagePickerVC.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVC.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
        BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVC;
}

- (NSMutableArray *)selectedAssets {
    if (!_selectedAssets) {
        _selectedAssets = NSMutableArray.array;
    }
    return _selectedAssets;
}

- (PublishTimeline *)timeline {
    if (!_timeline) {
        _timeline = [[PublishTimeline alloc] init];
    }
    return _timeline;
}

- (HXPhotoView *)photoView {
    if (!_photoView) {
        _photoView = [[HXPhotoView alloc] initWithManager:self.photoManager];
        _photoView.delegate = self;
        _photoView.outerCamera = YES;
        _photoView.previewShowDeleteButton = YES;
        _photoView.spacing = 10;
    }
    return _photoView;
}

- (PublishTopicSelectedVC *)topicSelectedVC {
    if (!_topicSelectedVC) {
        _topicSelectedVC = [[PublishTopicSelectedVC alloc] init];
        _topicSelectedVC.delegate = self;
        _topicSelectedVC.view.hidden = YES;
    }
    return _topicSelectedVC;
}

@end
