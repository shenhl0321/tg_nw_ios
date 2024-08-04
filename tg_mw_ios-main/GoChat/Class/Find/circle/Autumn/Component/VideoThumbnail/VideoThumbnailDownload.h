//
//  VideoThumbnailDownload.h
//  GoChat
//
//  Created by Autumn on 2021/12/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^VideoThumbnailResult)(UIImage * _Nullable image);

@interface VideoThumbnailDownload : NSObject

+ (VideoThumbnailDownload *)shared;

- (void)downloadThumbnailWithVideo:(VideoInfo *)video result:(VideoThumbnailResult)result;

@end

NS_ASSUME_NONNULL_END
