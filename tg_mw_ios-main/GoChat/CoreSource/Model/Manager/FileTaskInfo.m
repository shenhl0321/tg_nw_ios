//
//  FileTaskInfo.m
//  GoChat
//
//  Created by wangyutao on 2020/11/7.
//

#import "FileTaskInfo.h"

@implementation FileTaskInfo

- (int)priority
{
    switch (self.fileType) {
        case FileType_Photo:
            return 32;
        case FileType_Group_Photo:
            return 32;
        case FileType_Message_Photo:
            return 32;
        case FileType_Message_Preview_Photo:
            return 32;
        case FileType_Message_Video:
            return 32;
        case FileType_Message_Voice:
            return 32;
        case FileType_Message_Document:
            return 32;
        case FileType_Message_Animation:
            return 32;
        default:
            return 0;
    }
}

- (NSString *)fileTaskKey
{
    return [FileTaskInfo fileTaskKey:self.fileType file_id:self.file_id];
}

+ (NSString *)fileTaskKey:(FileType)type file_id:(long)file_id
{
    switch (type) {
        case FileType_Photo:
            return [NSString stringWithFormat:@"photo_%ld", file_id];
        case FileType_Group_Photo:
            return [NSString stringWithFormat:@"group_photo_%ld", file_id];
        case FileType_Message_Photo:
            return [NSString stringWithFormat:@"message_photo_%ld", file_id];
        case FileType_Message_Animation:
            return [NSString stringWithFormat:@"message_animation_%ld", file_id];
        case FileType_Message_Preview_Photo:
            return [NSString stringWithFormat:@"message_preview_photo_%ld", file_id];
        case FileType_Message_Video:
            return [NSString stringWithFormat:@"message_video_%ld", file_id];
        case FileType_Message_Audio:
            return [NSString stringWithFormat:@"message_audio_%ld", file_id];
        case FileType_Message_Voice:
            return [NSString stringWithFormat:@"message_voice_%ld", file_id];
        case FileType_Message_Document:
            return [NSString stringWithFormat:@"message_document_%ld", file_id];
        default:
            return @"";
    }
}

@end
