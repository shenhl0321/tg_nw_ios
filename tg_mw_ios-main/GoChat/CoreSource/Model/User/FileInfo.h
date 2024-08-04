//
//  FileInfo.h
//  GoChat
//
//  Created by wangyutao on 2020/11/8.
//

#import <Foundation/Foundation.h>

@interface FileInfoLocal : NSObject
@property (nonatomic, copy) NSString *path;
@property (nonatomic) BOOL can_be_downloaded;
@property (nonatomic) BOOL can_be_deleted;
@property (nonatomic) BOOL is_downloading_active;
@property (nonatomic) BOOL is_downloading_completed;
@property (nonatomic) long download_offset;
@property (nonatomic) long downloaded_prefix_size;
@property (nonatomic) long downloaded_size;

- (BOOL)isExist;
@end

@interface FileInfoRemote : NSObject
@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *unique_id;
@property (nonatomic) BOOL is_uploading_active;
@property (nonatomic) BOOL is_uploading_completed;
@property (nonatomic) long uploaded_size;
@end

@interface FileInfo : NSObject
@property (nonatomic) long _id;
@property (nonatomic) long size;
@property (nonatomic) long expected_size;
@property (nonatomic, strong) FileInfoLocal *local;
@property (nonatomic, strong) FileInfoRemote *remote;
@end
