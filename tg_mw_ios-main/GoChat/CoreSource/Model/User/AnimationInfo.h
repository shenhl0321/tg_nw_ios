//
//  AnimationInfo.h
//  GoChat
//
//  Created by mac on 2021/7/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnimationInfo : NSObject

@property (nonatomic) int duration;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic, copy) NSString *mime_type;
@property (nonatomic, copy) NSString *file_name;
@property (nonatomic, strong) ThumbnailInfo *thumbnail;
@property (nonatomic, strong) FileInfo *animation;

- (NSString *)totalSize;
- (NSString *)donwloadSize;
- (NSString *)localVideoPath;
- (BOOL)isVideoDownloaded;

@end

NS_ASSUME_NONNULL_END
