//
//  GroupSentMessage.m
//  GoChat
//
//  Created by Autumn on 2022/2/22.
//

#import "GroupSentMessage.h"

@interface GroupSentMessage ()

@property (nonatomic, strong) NSMutableArray<NSNumber *> *chatIds;

@end

@implementation GroupSentMessage

- (NSString *)mediaPath {
    switch (self.type) {
        case GroupSentMsgType_Text:
            return @"";
        case GroupSentMsgType_Voice:
            return [UserVideoPath(UserInfo.shareInstance._id) stringByAppendingPathComponent:self.message];
        case GroupSentMsgType_Photo:
            return [UserImagePath(UserInfo.shareInstance._id) stringByAppendingPathComponent:self.message];
        case GroupSentMsgType_Gif:
            return [UserImagePath(UserInfo.shareInstance._id) stringByAppendingPathComponent:self.message];
        case GroupSentMsgType_Video:
            return [UserVideoPath(UserInfo.shareInstance._id) stringByAppendingPathComponent:self.message];
    }
}

- (void)fetchChatIds:(GroupSentChatIdsCompletion)completion {
    
    if (self.chatIds.count > 0) {
        completion ? : completion(self.chatIds);
        return;
    }
    self.chatIds = NSMutableArray.array;
    dispatch_group_t group = dispatch_group_create();
    for (NSNumber *_id in _users) {
        dispatch_group_enter(group);
        ChatInfo *chat = [[TelegramManager shareInstance] getChatInfo:_id.longValue];
        if (!chat) {
            [[TelegramManager shareInstance] createPrivateChat:_id.longValue resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                if (obj != nil && [obj isKindOfClass:ChatInfo.class]) {
                    [self.chatIds addObject:@(((ChatInfo *)obj)._id)];
                }
                dispatch_group_leave(group);
            } timeout:^(NSDictionary *request) {
                dispatch_group_leave(group);
            }];
        } else {
            [self.chatIds addObject:@(chat._id)];
            dispatch_group_leave(group);
        }
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        !completion ? : completion(self.chatIds);
    });
    
}

- (void)fetchForwadingChatIds:(GroupSentForwardingChatIdsCompletion)completion {
    [self fetchChatIds:^(NSArray<NSNumber *> * _Nonnull chatIds) {
        __block NSNumber *chatId;
        NSMutableArray *fChatIds = NSMutableArray.array;
        [chatIds enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                chatId = obj;
                return;
            }
            [fChatIds addObject:obj];
        }];
        
        !completion ? : completion(chatId, fChatIds);
    }];
}

@end
