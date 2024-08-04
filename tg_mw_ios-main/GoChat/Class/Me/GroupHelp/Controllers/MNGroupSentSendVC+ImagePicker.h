//
//  MNGroupSentSendVC+ImagePicker.h
//  GoChat
//
//  Created by Autumn on 2022/2/25.
//

#import "MNGroupSentSendVC.h"
#import "HXPhotoPicker.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ImagePickerSelectedResult)(NSArray *videos, NSArray *photos, NSArray *gifs);

@interface MNGroupSentSendVC (ImagePicker)

- (void)openAlbumResult:(ImagePickerSelectedResult)result;

@end

NS_ASSUME_NONNULL_END
