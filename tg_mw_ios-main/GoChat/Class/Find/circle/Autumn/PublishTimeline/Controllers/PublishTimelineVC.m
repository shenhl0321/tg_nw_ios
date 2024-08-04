//
//  PublishTimeLineVC.m
//  GoChat
//
//  Created by Autumn on 2021/11/4.
//

#import "PublishTimelineVC.h"
#import "PublishPrivacyVC.h"
#import "SelectMemberVC.h"
#import "TimelineLocationVC.h"

#import "PublishTimeline.h"
#import "TZVideoEditedPreviewController.h"

#import "PublishTimelineInputCell.h"
#import "PublishTimelineMediaCell.h"
#import "PublishTimelineRemindHeaderView.h"
#import "PublishTimelineRemindCell.h"
#import "PublishTimelineSelectedCell.h"
#import "PublishTimelineSectionFooterView.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface PublishTimelineVC ()<TZImagePickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSArray *footerHeights;

@property (nonatomic, strong) UIImagePickerController *imagePickerVC;

@end


static NSInteger const maxVideoDuration = 180;

@implementation PublishTimelineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)dy_initData {
    [super dy_initData];
    
    [self dy_configureData];
}

- (void)dy_initUI {
    [super dy_initUI];
    
    [self.customNavBar setTitle:@"朋友圈".lv_localized];
    [self setupNavigationItem];
    
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView xhq_registerCell:PublishTimelineInputCell.class];
    [self.collectionView xhq_registerCell:PublishTimelineMediaCell.class];
    [self.collectionView xhq_registerCell:PublishTimelineRemindCell.class];
    [self.collectionView xhq_registerCell:PublishTimelineSelectedCell.class];
    [self.collectionView xhq_registerFooterView:PublishTimelineSectionFooterView.class];
    [self.collectionView xhq_registerHeaderView:PublishTimelineRemindHeaderView.class];
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
    
    if (_timeline.contents.images.count > 0) {
        for (UIImage *image in _timeline.contents.images) {
            PublishTimelineMediaCellItem *item = PublishTimelineMediaCellItem.item;
            item.image = image;
            [self.sectionArray1 addObject:item];
        }
        if (self.sectionArray1.count < 9) {
            PublishTimelineMediaCellItem *mItem = PublishTimelineMediaCellItem.item;
            [self.sectionArray1 addObject:mItem];
        }
    } else if (_timeline.contents.video.isValid) {
        PublishTimelineMediaCellItem *mItem = PublishTimelineMediaCellItem.item;
        mItem.image = _timeline.contents.video.thumbnailImage;
        mItem.video = YES;
        [self.sectionArray1 addObject:mItem];
    } else {
        PublishTimelineMediaCellItem *mItem = PublishTimelineMediaCellItem.item;
        [self.sectionArray1 addObject:mItem];
    }
    [self.dataArray addObject:self.sectionArray1];
    
    for (UserInfo *member in _timeline.metions) {
        PublishTimelineRemindCellItem *item = PublishTimelineRemindCellItem.item;
        item.user = member;
        [self.sectionArray2 addObject:item];
    }
    PublishTimelineRemindCellItem *item = PublishTimelineRemindCellItem.item;
    [self.sectionArray2 addObject:item];
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

- (void)mediaSelected {
    
    BOOL isSelectPhoto = NO;
    if (self.selectedAssets.count > 0) {
        isSelectPhoto = YES;
    }
    
    @weakify(self);
    MMPopupItemHandler block = ^(NSInteger index) {
        @strongify(self);
        if (index == 0) {
            [self takePhoto:(NSString *)kUTTypeImage];
        } else if (index == 1) {
            if (isSelectPhoto) {
                [self tzImagePicker];
            } else {
                [self takePhoto:(NSString *)kUTTypeMovie];
            }
        } else {
            [self tzImagePicker];
        }
    };
    NSMutableArray *items = @[MMItemMake(@"拍摄-照片".lv_localized, MMItemTypeNormal, block),
                       MMItemMake(@"拍摄-视频".lv_localized, MMItemTypeNormal, block),
                       MMItemMake(@"从相册选择".lv_localized, MMItemTypeNormal, block)].mutableCopy;
    if (isSelectPhoto) {
        [items removeObjectAtIndex:1];
    }
    MMSheetView *view = [[MMSheetView alloc] initWithTitle:nil items:items];
    [view show];
}

- (void)tzImagePicker {
    TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    imagePicker.selectedAssets = self.selectedAssets.mutableCopy;
    imagePicker.videoMaximumDuration = maxVideoDuration;
    imagePicker.photoWidth = 1024;
    imagePicker.photoPreviewMaxWidth = 900;
    imagePicker.presetName = AVAssetExportPresetHighestQuality;
    imagePicker.allowTakeVideo = YES;
    imagePicker.allowTakePicture = YES;
    imagePicker.allowPickingOriginalPhoto = NO;
    imagePicker.allowEditVideo = YES;
    imagePicker.showSelectedIndex = YES;
    imagePicker.showPhotoCannotSelectLayer = YES;
    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    imagePicker.photoPreviewPageUIConfigBlock = ^(UICollectionView *collectionView, UIView *naviBar, UIButton *backButton, UIButton *selectButton, UILabel *indexLabel, UIView *toolBar, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIButton *editButton) {
        editButton.hidden = YES;
    };
    imagePicker.videoPreviewPageUIConfigBlock = ^(UIButton *playButton, UIView *toolBar, UIButton *editBtn, UIButton *doneButton) {
        editBtn.hidden = YES;
    };
    [self presentViewController:imagePicker animated:YES completion:nil];
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
    if (self.timeline.contents.images.count == 0 && !self.timeline.contents.video.isValid) {
        [UserInfo showTips:self.view des:@"请选择发布视频或图片".lv_localized];
        return;
    }
    
    [self.view makeToastActivity:CSToastPositionCenter];
    /// 如果有选中群组，则需要获取群组成员
    @weakify(self);
    [self.timeline fetchSelectedGroupMembersCompletion:^{
        @strongify(self);
        [TelegramManager.shareInstance publishTimeline:self.timeline.jsonObject result:^(NSDictionary *request, NSDictionary *response) {
            [self.view hideToastActivity];
            if (![response[@"@type"] isEqualToString:@"blog"]) {
                [self.view makeToast:response[@"message"]];
                return;
            }
            [self.view makeToast:@"发布成功".lv_localized];
            BlogInfo *blog = [BlogInfo mj_objectWithKeyValues:response];
            int noti = MakeID(EUserManager, EUser_Timeline_Publish_Success);
            [BusinessFramework.defaultBusinessFramework broadcastBusinessNotify:noti withInParam:blog];
            [self.navigationController popViewControllerAnimated:YES];
        } timeout:^(NSDictionary *request) {
            [UserInfo dismiss];
            [UserInfo showTips:self.view des:@"发布超时".lv_localized];
        }];
    }];
}

#pragma mark - UICollectionViewDataSource
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        if (indexPath.section != 2) {
            return [super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
        }
        PublishTimelineRemindHeaderView *header = [collectionView xhq_dequeueHeaderView:PublishTimelineRemindHeaderView.class
                                                                              indexPath:indexPath];
        return header;
    }
    if (indexPath.section == 0 || indexPath.section == self.dataArray.count - 1) {
        return [super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    }
    PublishTimelineSectionFooterView *footer = [collectionView xhq_dequeueFooterView:[PublishTimelineSectionFooterView class]
                                                                           indexPath:indexPath];
    return footer;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section != 2) {
        return CGSizeZero;
    }
    return CGSizeMake(kScreenWidth(), 40);
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

#pragma mark - UICollectionViewDelegate
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (section == 2 || section == 1) {
        return 10;
    }
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (section == 2 || section == 1) {
        return 10;
    }
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DYCollectionViewCellItem *item = self.dataArray[indexPath.section][indexPath.item];
    if ([item isKindOfClass:PublishTimelineRemindCellItem.class]) {
        [self remindSelected];
    } else if ([item isKindOfClass:PublishTimelineMediaCellItem.class]) {
        PublishTimelineMediaCellItem *m = (PublishTimelineMediaCellItem *)item;
        if (!m.image) {
            [self mediaSelected];
        } else {
            [self previewMedia:indexPath];
        }
    } else if ([item isKindOfClass:PublishTimelineSelectedCellItem.class]) {
        PublishTimelineSelectedCellItem *m = (PublishTimelineSelectedCellItem *)item;
        [m.title isEqualToString:@"谁可以看".lv_localized] ? [self privacySelected] : [self locationSelected];
    }
}

#pragma mark - CollectionViewCellBlock
- (void)dy_cellResponse:(__kindof DYCollectionViewCellItem *)item indexPath:(NSIndexPath *)indexPath {
    if ([item isKindOfClass:PublishTimelineMediaCellItem.class]) {
        PublishTimelineMediaCellItem *m = (PublishTimelineMediaCellItem *)item;
        if (m.isVideo) {
            _timeline.contents.video = nil;
            [_selectedAssets removeAllObjects];
        } else if (_timeline.contents.images.count > 0) {
            [_timeline.contents.images removeObjectAtIndex:indexPath.item];
            [_selectedAssets removeObjectAtIndex:indexPath.item];
        }
        [self dy_configureData];
        [self.collectionView reloadData];
    }
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
        NSLog(@"模拟器中无法打开照相机,请在真机中使用".lv_localized);
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
                NSLog(@"图片保存失败 %@".lv_localized,error);
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
    [_selectedAssets addObject:asset];
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        _timeline.contents.video.thumbnailImage = image;
        [[TZImageManager manager] getVideoOutputPathWithAsset:asset presetName:AVAssetExportPresetHighestQuality success:^(NSString *outputPath) {
            self.timeline.contents.video.outputPath = outputPath;
        } failure:^(NSString *errorMessage, NSError *error) {
            NSLog(@"视频导出失败:%@,error:%@".lv_localized,errorMessage, error);
        }];
    } else {
        [_timeline.contents.images addObject:image];
    }
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

@end
