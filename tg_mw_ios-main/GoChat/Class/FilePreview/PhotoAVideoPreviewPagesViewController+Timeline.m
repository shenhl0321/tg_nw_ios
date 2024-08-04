//
//  PhotoAVideoPreviewPagesViewController+Timeline.m
//  GoChat
//
//  Created by Autumn on 2022/1/3.
//

#import "PhotoAVideoPreviewPagesViewController+Timeline.h"

#pragma mark - 图片转发消息体
@interface PhotoInfo (RemoteMsg)

- (NSDictionary *)remoteContent;

@end

@implementation PhotoInfo (RemoteMsg)

- (NSDictionary *)remoteContent {
    NSDictionary *photoDic = @{
        @"@type" : @"inputFileRemote",
        @"id" : self.previewPhoto.photo.remote._id ? : @""
    };
    return @{
        @"@type" : @"inputMessagePhoto",
        @"width" : [NSNumber numberWithInt:fabs(self.previewPhoto.width)],
        @"height" : [NSNumber numberWithInt:fabs(self.previewPhoto.height)],
        @"photo" : photoDic
    };
}

@end

#pragma mark - 视频转发消息体
@interface VideoInfo (RemoteMsg)

- (NSDictionary *)remoteContent;

@end

@implementation VideoInfo (RemoteMsg)

- (NSDictionary *)remoteContent {
    NSDictionary *thumbnailFile = @{
        @"@type" : @"inputFileRemote",
        @"id" : self.thumbnail.file.remote._id ? : @""
    };
    NSDictionary *thumbnail = @{
        @"@type": @"inputThumbnail",
        @"thumbnail": thumbnailFile,
        @"width": @(self.width),
        @"height": @(self.height),
    };
    NSDictionary *video = @{
        @"@type" : @"inputFileRemote",
        @"id" : self.video.remote._id ? : @""
    };
    return @{
        @"@type" : @"inputMessageVideo",
        @"thumbnail" : thumbnail,
        @"video" : video,
        @"width" : @(self.width),
        @"height" : @(self.height),
        @"duration" : @(self.duration)
    };
}

@end


@implementation PhotoAVideoPreviewPagesViewController (Timeline)

- (BOOL)isFromTimeline {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setFromTimeline:(BOOL)fromTimeline {
    objc_setAssociatedObject(self, @selector(isFromTimeline), @(fromTimeline), OBJC_ASSOCIATION_ASSIGN);
}

- (NSArray *)timelineItems {
    if (!self.isFromTimeline) {
        return @[];
    }
    MMPopupItem *forward = MMItemMake(@"转发".lv_localized, MMItemTypeNormal, ^(NSInteger index) {
        [self forward];
    });
    MMPopupItem *collect = MMItemMake(@"收藏".lv_localized, MMItemTypeNormal, ^(NSInteger index) {
        [self collect];
    });
    return @[forward, collect];
}

#pragma mark 转发
- (void)forward {
    if (self.previewList.count < self.selectIndex) {
        [UserInfo showTips:nil des:@"转发失败, 数据源错误".lv_localized];
        return;
    }
    ChatChooseViewController *chooseView = [[ChatChooseViewController alloc] init];
    chooseView.delegate = self;
    [self.navigationController pushViewController:chooseView animated:YES];
    
}

#pragma mark 收藏
- (void)collect {
    if (self.previewList.count < self.selectIndex) {
        [UserInfo showTips:nil des:@"收藏失败, 数据源错误".lv_localized];
        return;
    }
    [UserInfo show];
    NSDictionary *parameters = [self msgParametersWithId:@(UserInfo.shareInstance._id)];
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if ([TelegramManager isResultError:response]) {
            [UserInfo showTips:nil des:[TelegramManager errorMsg:response]];
            return;
        }
        [UserInfo showTips:nil des:@"收藏成功".lv_localized];
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"收藏失败".lv_localized];
    }];
}

#pragma mark - ChatChooseViewControllerDelegate
// 群发
- (void)ChatChooseViewController_Chats_ChooseArr:(NSArray *)chatArr msg:(NSArray *)msgs{
    for (int i=0; i<chatArr.count; i++) {
        id chat = chatArr[i];
        [self ChatChooseViewController_Chat_Choose:chat msg:msgs];
    }
}
- (void)ChatChooseViewController_Chat_Choose:(id)chat msg:(NSArray *)msgs {
    [UserInfo show];
    @weakify(self);
    [self chatIdFromChooseChat:chat result:^(long chatId) {
        @strongify(self);
        if (chatId == 0) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"获取聊天信息失败".lv_localized];
            return;
        }
        NSDictionary *parameters = [self msgParametersWithId:@(chatId)];
        [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
            [UserInfo dismiss];
            if ([TelegramManager isResultError:response]) {
                [UserInfo showTips:nil des:[TelegramManager errorMsg:response]];
                return;
            }
            [UserInfo showTips:nil des:@"转发成功".lv_localized];
        } timeout:^(NSDictionary *request) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"转发失败".lv_localized];
        }];
    }];
}

#pragma mark 获取 chatId
- (void)chatIdFromChooseChat:(id)chat result:(void(^)(long))result {
    if ([chat isKindOfClass:[ChatInfo class]]) {
        ChatInfo *chatinfo = chat;
        !result ? :result(chatinfo._id);
        return;
    }
    UserInfo *user = chat;
    [[TelegramManager shareInstance] createPrivateChat:user._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if (obj != nil && [obj isKindOfClass:ChatInfo.class]) {
            ChatInfo *chatinfo = obj;
            !result ? :result(chatinfo._id);
            return;
        }
        !result ? :result(0);
    } timeout:^(NSDictionary *request) {
        !result ? :result(0);
    }];
}

- (NSDictionary *)msgParametersWithId:(NSNumber *)chatId {
    MessageInfo *msg = self.previewList[self.curIndex];
    NSDictionary *content = nil;
    if (msg.messageType == MessageType_Video) {
        content = msg.content.video.remoteContent;
    } else if (msg.messageType == MessageType_Photo) {
        content = msg.content.photo.remoteContent;
    } else if (msg.messageType == MessageType_Animation) {
//        content = msg.content.animation.remoteContent;
    }
    return @{
        @"@type" : @"sendMessage",
        @"chat_id" : chatId,
        @"input_message_content": content
    };
}

@end
