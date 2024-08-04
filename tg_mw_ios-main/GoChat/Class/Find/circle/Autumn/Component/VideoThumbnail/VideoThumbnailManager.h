//
//  VideoThumbnailManager.h
//  GoChat
//
//  Created by Autumn on 2021/12/25.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef void(^VideoThumbnailResult)(UIImage * _Nullable thumbnail);

@interface VideoThumbnailManager : NSObject

+ (VideoThumbnailManager *)manager;

/// 异步获取视频封面
/// @param video 视频信息
/// @param result 回调结果
- (void)thumbnailForVideo:(VideoInfo *)video result:(VideoThumbnailResult)result;

/// 根据名称获取本地已经保存的视频封面
/// @param name 视频名称
- (UIImage *)localThumbnailForVideoName:(NSString *)name;

/// 保存视频封面
/// @param image 封面
/// @param name 保存名称
- (void)saveThumbnail:(UIImage *)image forVideoName:(NSString *)name;

/// 通过 AVURLAsset 保存视频封面
/// 异步获取视频封面有时会不成功。
/// 这种方式是通过视频播放时获取封面。然后保存起来
///
/// @param asset AVURLAsset
/// @param name 保存名称
/// @param completion 回调
- (void)saveThumbnailAsset:(AVURLAsset *)asset forVideoName:(NSString *)name completion:(dispatch_block_t)completion;

@end

NS_ASSUME_NONNULL_END
