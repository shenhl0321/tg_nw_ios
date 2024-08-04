//
//  PhotoInfo.h
//  GoChat
//
//  Created by wangyutao on 2020/11/26.
//

#import <Foundation/Foundation.h>
#import "FileInfo.h"

//图片消息
@interface PhotoSizeInfo : NSObject
//@photoSize
@property (nonatomic, copy) NSString *type;
//s\m\i\x\y
@property (nonatomic, copy) NSString *size_type;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic, strong) FileInfo *photo;
- (BOOL)isPhotoDownloaded;
@end

@interface PhotoInfo : NSObject
//@photo
@property (nonatomic, copy) NSString *type;
//PhotoSizeInfo
@property (nonatomic, strong) NSArray *sizes;

- (PhotoSizeInfo *)messagePhoto;
- (PhotoSizeInfo *)previewPhoto;
@end

@interface ThumbnailFormatInfo : NSObject
//@thumbnailFormatGif, thumbnailFormatJpeg, thumbnailFormatMpeg4, thumbnailFormatPng, thumbnailFormatTgs, and thumbnailFormatWebp.
@property (nonatomic, copy) NSString *type;
@end

@interface ThumbnailInfo : NSObject
//@thumbnail
@property (nonatomic, copy) NSString *type;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic, strong) FileInfo *file;
@property (nonatomic, strong) ThumbnailFormatInfo *format;
- (BOOL)isThumbnailDownloaded;
@end
