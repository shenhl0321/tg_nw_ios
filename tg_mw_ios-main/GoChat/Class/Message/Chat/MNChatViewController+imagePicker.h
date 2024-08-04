//
//  MNChatViewController+imagePicker.h
//  GoChat
//
//  Created by 许蒙静 on 2022/1/8.
//

#import "MNChatViewController.h"
#import "HXPhotoPicker.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^ImagePickerSelectedResult)(NSArray *videos, NSArray *photos, NSArray *gifs);

@interface MNChatViewController (imagePicker)

- (void)openAlbum:(BOOL)isGroupAdmin result:(ImagePickerSelectedResult)result;

- (void)openAlbumResult:(ImagePickerSelectedResult)result;

@end

NS_ASSUME_NONNULL_END
