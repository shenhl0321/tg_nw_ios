//
//  ProfilePhoto.h
//  GoChat
//
//  Created by wangyutao on 2020/11/7.
//

#import <Foundation/Foundation.h>

@interface ProfilePhoto : NSObject
@property (nonatomic, copy) NSString *_id;
@property (nonatomic, strong) FileInfo *small;
@property (nonatomic, strong) FileInfo *big;
@property (nonatomic) BOOL has_animation;

- (long)fileBigId;
- (long)fileSmallId;
- (BOOL)isSmallPhotoDownloaded;
- (BOOL)isBigPhotoDownloaded;
- (NSString *)localBigPath;
- (NSString *)localSmallPath;
@end
