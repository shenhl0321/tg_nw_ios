//
//  DocumentInfo.m
//  GoChat
//
//  Created by wangyutao on 2021/6/2.
//

#import "DocumentInfo.h"

@implementation DocumentInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"type" : @"@type"};
}

- (NSString *)totalSize
{
    return [Common bytesToAvaiUnit:self.document.expected_size showDecimal:YES];
}

- (NSString *)localFilePath
{
    //
    if(self.document.local.isExist)
    {
        return self.document.local.path;
    }
    //
    if(self.file_name.length>0)
    {
        NSString *path = [NSString stringWithFormat:@"%@/%@", UserFilePath([UserInfo shareInstance]._id), self.file_name];
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
            return path;
    }
    return nil;
}

- (BOOL)isFileDownloaded
{
    //
    if(self.document.local.isExist)
    {
        return YES;
    }
    //
    if(self.file_name.length>0)
    {
        NSString *path = [NSString stringWithFormat:@"%@/%@", UserFilePath([UserInfo shareInstance]._id), self.file_name];
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
            return YES;
    }
    return NO;
}

+ (BOOL)isImageFile:(NSString *)fileName
{
    if(!IsStrEmpty(fileName))
    {
        NSString *suffix = [[fileName pathExtension] lowercaseString];
        if([@"jpg" isEqualToString:suffix] || [@"jpeg" isEqualToString:suffix] || [@"png" isEqualToString:suffix])
        {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isVideoFile:(NSString *)fileName
{
    if(!IsStrEmpty(fileName))
    {
        NSString *suffix = [[fileName pathExtension] lowercaseString];
        if([@"mp4" isEqualToString:suffix] || [@"avi" isEqualToString:suffix] || [@"mov" isEqualToString:suffix] ||
           [@"wmv" isEqualToString:suffix] || [@"asf" isEqualToString:suffix] || [@"navi" isEqualToString:suffix] ||
           [@"3gp" isEqualToString:suffix] || [@"mkv" isEqualToString:suffix] || [@"f4v" isEqualToString:suffix] ||
           [@"rmvb" isEqualToString:suffix] || [@"webm" isEqualToString:suffix])
        {
            return YES;
        }
    }
    return NO;
}

+ (NSString *)fileTypeIcon:(NSString *)fileName
{
    if(!IsStrEmpty(fileName))
    {
        NSString *suffix = [[fileName pathExtension] lowercaseString];
        if([@"txt" isEqualToString:suffix])
        {
            return @"file_type_txt";
        }
        else if([@"docx" isEqualToString:suffix] || [@"doc" isEqualToString:suffix])
        {
            return @"file_type_word";
        }
        else if([@"xls" isEqualToString:suffix] || [@"xlsx" isEqualToString:suffix])
        {
            return @"file_type_excel";
        }
        else if([@"ppt" isEqualToString:suffix] || [@"pptx" isEqualToString:suffix])
        {
            return @"file_type_ppt";
        }
        else if([@"pdf" isEqualToString:suffix])
        {
            return @"file_type_pdf";
        }
        else if([@"psd" isEqualToString:suffix])
        {
            return @"file_type_psd";
        }
        else if([@"jpg" isEqualToString:suffix] || [@"jpeg" isEqualToString:suffix] || [@"png" isEqualToString:suffix])
        {
            return @"file_type_image";
        }
        else if([@"mp4" isEqualToString:suffix] || [@"avi" isEqualToString:suffix] || [@"mov" isEqualToString:suffix] ||
                [@"wmv" isEqualToString:suffix] || [@"asf" isEqualToString:suffix] || [@"navi" isEqualToString:suffix] ||
                [@"3gp" isEqualToString:suffix] || [@"mkv" isEqualToString:suffix] || [@"f4v" isEqualToString:suffix] ||
                [@"rmvb" isEqualToString:suffix] || [@"webm" isEqualToString:suffix])
        {
            return @"file_type_video";
        }
        else if([@"mp3" isEqualToString:suffix] || [@"wma" isEqualToString:suffix] || [@"wav" isEqualToString:suffix] ||
                [@"mod" isEqualToString:suffix] || [@"ra" isEqualToString:suffix] || [@"cd" isEqualToString:suffix] ||
                [@"md" isEqualToString:suffix] || [@"asf" isEqualToString:suffix] || [@"aac" isEqualToString:suffix] ||
                [@"vqf" isEqualToString:suffix] || [@"mid" isEqualToString:suffix] || [@"ogg" isEqualToString:suffix])
        {
            return @"file_type_audio";
        }
        else if([@"rar" isEqualToString:suffix] || [@"zip" isEqualToString:suffix] || [@"7z" isEqualToString:suffix] ||
                [@"gz" isEqualToString:suffix] || [@"tar" isEqualToString:suffix])
        {
            return @"file_type_zip";
        }
        else if([@"html" isEqualToString:suffix] || [@"htm" isEqualToString:suffix] || [@"shtml" isEqualToString:suffix] ||
                [@"shtm" isEqualToString:suffix])
        {
            return @"file_type_web";
        }
        else if([@"exe" isEqualToString:suffix])
        {
            return @"file_type_exe";
        }
        else
        {
            return @"file_type_default";
        }
    }
    return @"file_type_default";
}

@end
