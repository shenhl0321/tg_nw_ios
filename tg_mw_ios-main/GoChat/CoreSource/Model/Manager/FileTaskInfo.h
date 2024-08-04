//
//  FileTaskInfo.h
//  GoChat
//
//  Created by wangyutao on 2020/11/7.
//

#import <Foundation/Foundation.h>

@interface FileTaskInfo : NSObject
//头像时，对应userid
//后续补充
@property (nonatomic, copy) NSString *_id;
@property (nonatomic) long file_id;
@property (nonatomic) FileType fileType;

- (int)priority;
- (NSString *)fileTaskKey;
+ (NSString *)fileTaskKey:(FileType)type file_id:(long)file_id;
@end
