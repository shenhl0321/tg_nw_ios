//
//  MNChatViewController+imagePicker.m
//  GoChat
//
//  Created by 许蒙静 on 2022/1/8.
//

#import "MNChatViewController+imagePicker.h"
#import <IJSFoundation/IJSFoundation.h>

@implementation MNChatViewController (imagePicker)

- (void)openAlbum:(BOOL)isGroupAdmin result:(ImagePickerSelectedResult)result {
    self.photoManager.configuration.canSendAD = isGroupAdmin;
    [self openAlbumResult:result];
}

- (void)openAlbumResult:(ImagePickerSelectedResult)result {
    self.selectMediaResult = result;
    [self hx_presentSelectPhotoControllerWithManager:self.photoManager delegate:self];
}

- (void)photoNavigationViewController:(HXCustomNavigationController *)photoNavigationViewController didDoneAllList:(NSArray<HXPhotoModel *> *)allList photos:(NSArray<HXPhotoModel *> *)photoList videos:(NSArray<HXPhotoModel *> *)videoList original:(BOOL)original {
    
    if (videoList.count > 0) {
        HXPhotoModel *video = videoList.firstObject;
        [UserInfo show];
        [video getImageWithSuccess:^(UIImage * _Nullable image, HXPhotoModel * _Nullable model, NSDictionary * _Nullable info) {
            [UserInfo dismiss];
            !self.selectMediaResult ? : self.selectMediaResult(@[video], @[], @[]);
        } failed:^(NSDictionary * _Nullable info, HXPhotoModel * _Nullable model) {
            [UserInfo dismiss];
            !self.selectMediaResult ? : self.selectMediaResult(@[video], @[], @[]);
        }];
        return;
    }
    NSMutableArray *photos = NSMutableArray.array;
    NSMutableArray *gifs = NSMutableArray.array;
    [UserInfo show];
    dispatch_group_t group = dispatch_group_create();
    for (HXPhotoModel *model in photoList) {
        dispatch_group_enter(group);
        [model getImageWithSuccess:^(UIImage * _Nullable image, HXPhotoModel * _Nullable model, NSDictionary * _Nullable info) {
            if (model.type == HXPhotoModelMediaTypePhotoGif) {
                [gifs addObject:model];
            } else {
                [photos addObject:model];
            }
            dispatch_group_leave(group);
        } failed:^(NSDictionary * _Nullable info, HXPhotoModel * _Nullable model) {
            if (model.type == HXPhotoModelMediaTypePhotoGif) {
                [gifs addObject:model];
            } else {
                [photos addObject:model];
            }
            dispatch_group_leave(group);
        }];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [UserInfo dismiss];
        !self.selectMediaResult ? : self.selectMediaResult(videoList, photos, gifs);
    });
}

- (void)photoNavigationViewControllerFinishDismissCompletion:(HXCustomNavigationController *)photoNavigationViewController {
    [self.photoManager clearSelectedList];
}

- (void)photoNavigationViewControllerCancelDismissCompletion:(HXCustomNavigationController *)photoNavigationViewController {
    [self.photoManager clearSelectedList];
}

- (HXPhotoManager *)photoManager {
    HXPhotoManager *manager = objc_getAssociatedObject(self, _cmd);
    if (!manager) {
        manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhotoAndVideo];
        manager.configuration.type = HXConfigurationTypeWXMoment;
        manager.configuration.videoCanEdit = NO;
        manager.configuration.videoMaximumSelectDuration = 1000000;
        manager.configuration.themeColor = UIColor.whiteColor;
        manager.configuration.openCamera = NO;
        manager.configuration.hideOriginalBtn = NO;
        manager.configuration.saveSystemAblum = YES;
//        manager.configuration.requestImageAfterFinishingSelection = YES;
        
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"JSPhotoSDK" ofType:@"bundle"];
        NSString *filePath = [bundlePath stringByAppendingString:@"/Expression"];
        [IJSFFilesManager ergodicFilesFromFolderPath:filePath completeHandler:^(NSInteger fileCount, NSInteger fileSzie, NSMutableArray *filePath) {
            HXPhotoEditChartletTitleModel *netModel = [HXPhotoEditChartletTitleModel modelWithImageNamed:@"hx_sticker_cover"];
            NSMutableArray *models = [NSMutableArray array];
            for (NSString *path in filePath) {
                UIImage *image = [UIImage imageWithContentsOfFile:path];
                HXPhotoEditChartletModel *subModel = [HXPhotoEditChartletModel modelWithImage:image];
                [models addObject:subModel];
            }
            netModel.models = models.copy;
            manager.configuration.photoEditConfigur.chartletModels = @[netModel];
        }];
        objc_setAssociatedObject(self, @selector(photoManager), manager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return manager;
}

- (ImagePickerSelectedResult)selectMediaResult {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSelectMediaResult:(ImagePickerSelectedResult)selectMediaResult {
    objc_setAssociatedObject(self, @selector(selectMediaResult), selectMediaResult, OBJC_ASSOCIATION_COPY_NONATOMIC);
}



@end
