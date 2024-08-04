//
//  PhotoImageView.h
//  GoChat
//
//  Created by Autumn on 2021/11/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PhotoInfo, ThumbnailInfo;
@interface PhotoImageView : UIImageView

@property (nonatomic, strong) PhotoInfo *photo;

@property (nonatomic, strong) ThumbnailInfo *thumbnail;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
