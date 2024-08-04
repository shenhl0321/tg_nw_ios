//
//  VideoCompress.h
//  GoChat
//
//  Created by Autumn on 2022/1/2.
//
/// 本地视频压缩处理。源自：ChatViewController

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoCompress : NSObject

+ (void)createVideoFileWithVideo:(id)video result:(void(^)(NSError *error, NSString *videoPath, CGSize size, int duration))block;

+ (void)createVideoFileWithAVURLAssert:(AVURLAsset *)asset result:(void(^)(NSError *error, NSString *videoPath, CGSize size, int duration))block;

@end

NS_ASSUME_NONNULL_END
