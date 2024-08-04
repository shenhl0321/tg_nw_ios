//
//  VideoInfo.h
//  GoChat
//
//  Created by wangyutao on 2020/11/30.
//

#import <Foundation/Foundation.h>
#import "PhotoInfo.h"

@interface VideoInfo : NSObject
//@video
@property (nonatomic, copy) NSString *type;
//file_name : "BA1E621DF2C34C3092D9410FAAB32DE3.mp4"
@property (nonatomic, copy) NSString *file_name;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) ThumbnailInfo *thumbnail;
@property (nonatomic, strong) FileInfo *video;

@property (nonatomic, copy) NSString *mime_type;

/// 封面图片
@property (nonatomic,strong) UIImage *coverImg;
/// 持续时间 时分秒
@property (nonatomic,copy) NSString *durationTime;

- (NSString *)totalSize;
- (NSString *)donwloadSize;
- (NSString *)localVideoPath;
- (BOOL)isVideoDownloaded;
@end
