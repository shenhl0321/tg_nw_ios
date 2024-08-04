//
//  DocumentInfo.h
//  GoChat
//
//  Created by wangyutao on 2021/6/2.
//

#import <Foundation/Foundation.h>

@interface DocumentInfo : NSObject
//@document
@property (nonatomic, copy) NSString *type;
//文件名称 - 不用于显示
@property (nonatomic, copy) NSString *file_name;
//文件类型
@property (nonatomic, copy) NSString *mime_type;
//文件
@property (nonatomic, strong) FileInfo *document;

- (NSString *)totalSize;
- (NSString *)localFilePath;
- (BOOL)isFileDownloaded;

+ (BOOL)isImageFile:(NSString *)fileName;
+ (BOOL)isVideoFile:(NSString *)fileName;
+ (NSString *)fileTypeIcon:(NSString *)fileName;
@end
