//
//  VideoCompress.m
//  GoChat
//
//  Created by Autumn on 2022/1/2.
//

#import "VideoCompress.h"

@implementation VideoCompress

+ (void)createVideoFileWithVideo:(id)video result:(void(^)(NSError *error, NSString *videoPath, CGSize size, int duration))block {
    NSURL *tempPrivateFileURL = nil;
    if([video isKindOfClass:[PHAsset class]]) {
        PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:video] firstObject];
        tempPrivateFileURL = [resource valueForKey:@"privateFileURL"];
    } else {
        tempPrivateFileURL = video;
    }
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:tempPrivateFileURL options:nil];
    [self createVideoFileWithAVURLAssert:avAsset result:block];
}

//本地视频处理
static AVAssetExportSession *videoExportSession = nil;
+ (void)createVideoFileWithAVURLAssert:(AVURLAsset *)asset result:(void(^)(NSError *error, NSString *videoPath, CGSize size, int duration))block {
    __block NSError *error = nil;
    
    NSString *quality = nil;
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        quality = AVAssetExportPresetHighestQuality;
    }
    else if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        quality = AVAssetExportPresetMediumQuality;
    }
    else if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality]) {
        quality = AVAssetExportPresetLowQuality;
    } else {
        if (block) {
            error = [NSError errorWithDomain:@"无质量".lv_localized code:101 userInfo:nil];
            block(error, nil, CGSizeZero, 0);
        }
        return;
    }
    
    int videoDuration = asset.duration.value*1.0/asset.duration.timescale;
    NSString *videoPath = [NSString stringWithFormat:@"%@/%@.mp4", UserVideoPath([UserInfo shareInstance]._id), [Common generateGuid]];
    videoExportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:quality];
    videoExportSession.outputURL = [NSURL fileURLWithPath:videoPath];
    videoExportSession.shouldOptimizeForNetworkUse = YES;
    videoExportSession.outputFileType = AVFileTypeMPEG4;
    [videoExportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([videoExportSession status]) {
            case AVAssetExportSessionStatusFailed: {
                if (block) {
                    block([videoExportSession error], nil, CGSizeZero, 0);
                }
                break;
            }
            case AVAssetExportSessionStatusCancelled: {
                if (block) {
                    error = [NSError errorWithDomain:@"取消".lv_localized code:102 userInfo:nil];
                    block(error, nil, CGSizeZero, 0);
                }
                break;
            }
            case AVAssetExportSessionStatusCompleted: {
                if (block)  {
                    AVURLAsset *convertAvAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
                    AVAssetTrack *track = [[convertAvAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
                    CGSize videoSize = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
                    block(nil, videoPath, videoSize, videoDuration);
                }
                break;
            }
            default: {
                if (block) {
                    error = [NSError errorWithDomain:@"未知".lv_localized code:103 userInfo:nil];
                    block(error, nil, CGSizeZero, 0);
                }
                break;
            }
        }
    }];
}

@end
