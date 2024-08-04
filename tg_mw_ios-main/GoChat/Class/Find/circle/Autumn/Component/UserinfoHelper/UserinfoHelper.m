//
//  UserinfoHelper.m
//  GoChat
//
//  Created by Autumn on 2021/11/21.
//

#import "UserinfoHelper.h"

@implementation UserinfoHelper

+ (void)setUsername:(NSInteger)userid inLabel:(UILabel *)label {
    UserInfo *userInfo = [TelegramManager.shareInstance contactInfo:userid];
    if (!userInfo) {
        [TelegramManager.shareInstance getUserSimpleInfo_inline:userid resultBlock:^(NSDictionary *request, NSDictionary *response) {
            if ([response[@"@type"] isEqualToString:@"user"]) {
                [self setUsername:userid inLabel:label];
            }
        } timeout:nil];
        return;
    }
    NSString *name = userInfo.displayName;
    if (name.length > 12) {
        label.text = [NSString stringWithFormat:@"%@...", [name substringToIndex:11]];
    } else {
        label.text = name;
    }
}

+ (void)setUserAvatar:(NSInteger)userid inImageView:(UIImageView *)imageView {
    UserInfo *userInfo = [TelegramManager.shareInstance contactInfo:userid];
    if (!userInfo) {
        [TelegramManager.shareInstance getUserSimpleInfo_inline:userid resultBlock:^(NSDictionary *request, NSDictionary *response) {
            if ([response[@"@type"] isEqualToString:@"user"]) {
                [self setUserAvatar:userid inImageView:imageView];
            }
        } timeout:nil];
        return;
    }
    if (!userInfo.profile_photo) {
        [self loadTextImage:userInfo.displayName inImageView:imageView];
        return;
    }
    if (!userInfo.profile_photo.isSmallPhotoDownloaded) {
        [[FileDownloader instance] downloadImage:[NSString stringWithFormat:@"%ld", userInfo._id] fileId:userInfo.profile_photo.fileSmallId type:FileType_Photo];
        [self loadTextImage:userInfo.displayName inImageView:imageView];
        return;
    }
    [UserInfo cleanColorBackgroundWithView:imageView];
    imageView.image = [UIImage imageWithContentsOfFile:userInfo.profile_photo.localSmallPath];
}

+ (void)loadTextImage:(NSString *)name inImageView:(UIImageView *)imageView {
    imageView.image = nil;
    unichar text = [@" " characterAtIndex:0];
    if(name.length > 0) {
        text = [[name uppercaseString] characterAtIndex:0];
    }
    [UserInfo setColorBackgroundWithView:imageView withSize:CGSizeMake(42, 42) withChar:text];
}


+ (void)getUsernames:(NSArray *)ids completion:(void(^)(NSArray *names))completion {
    NSMutableArray *names = NSMutableArray.array;
    for (NSNumber *num in ids) {
        [names addObject:num.stringValue];
    }
    dispatch_group_t group = dispatch_group_create();
    [ids enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_enter(group);
        UserInfo *userInfo = [TelegramManager.shareInstance contactInfo:obj.intValue];
        if (userInfo) {
            [names replaceObjectAtIndex:idx withObject:userInfo.displayName];
            dispatch_group_leave(group);
        } else {
            [TelegramManager.shareInstance getUserSimpleInfo_inline:obj.intValue resultBlock:^(NSDictionary *request, NSDictionary *response) {
                if ([response[@"@type"] isEqualToString:@"user"]) {
                    UserInfo *userInfo = [TelegramManager.shareInstance contactInfo:obj.intValue];
                    [names replaceObjectAtIndex:idx withObject:userInfo.displayName];
                }
                dispatch_group_leave(group);
            } timeout:^(NSDictionary *request) {
                dispatch_group_leave(group);
            }];
        }
    }];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        !completion ? : completion(names);
    });
}

+ (void)getUserinfos:(NSArray *)ids completion:(void(^)(NSArray *userinfos))completion {
    NSMutableArray *userinfos = NSMutableArray.array;
    for (NSNumber *num in ids) {
        [userinfos addObject:UserInfo.new];
    }
    dispatch_group_t group = dispatch_group_create();
    [ids enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_enter(group);
        UserInfo *userInfo = [TelegramManager.shareInstance contactInfo:obj.intValue];
        if (userInfo) {
            [userinfos replaceObjectAtIndex:idx withObject:userInfo];
            dispatch_group_leave(group);
        } else {
            [TelegramManager.shareInstance getUserSimpleInfo_inline:obj.intValue resultBlock:^(NSDictionary *request, NSDictionary *response) {
                if ([response[@"@type"] isEqualToString:@"user"]) {
                    UserInfo *userInfo = [TelegramManager.shareInstance contactInfo:obj.intValue];
                    [userinfos replaceObjectAtIndex:idx withObject:userInfo];
                }
                dispatch_group_leave(group);
            } timeout:^(NSDictionary *request) {
                dispatch_group_leave(group);
            }];
        }
    }];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        !completion ? : completion(userinfos);
    });
}


+ (void)getUserExtInfo:(long)userid completion:(void(^)(UserInfoExt *ext))completion {
    NSDictionary *parameters = @{
        @"@type": @"sendCustomRequest",
        @"method": @"users.getUserInfoExt",
        @"parameters": @{@"userid": @(userid)}.mj_JSONString
    };
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        NSString *result = response[@"result"];
        if ([result isKindOfClass:NSString.class]) {
            NSDictionary *resp = result.mj_JSONObject;
            UserInfoExt *ext = [UserInfoExt mj_objectWithKeyValues:resp[@"data"]];
            !completion ? : completion(ext);
            return;
        }
        !completion ? : completion(nil);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(nil);
    }];
}

@end
