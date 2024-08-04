//
//  MNChatUtil.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/6.
//

#import "MNChatUtil.h"

@implementation MNChatUtil
//重复代码给它整理出来。比较乱。方便也方便复用
+ (void)headerImgV:(UIImageView *)headerImgV chat:(ChatInfo *)chat size:(CGSize)size{
   
    if(chat.isGroup)
    {
        //群组头像
        if(chat.photo != nil)
        {
            if(!chat.photo.isSmallPhotoDownloaded && chat.photo.small.remote.unique_id.length > 1)
            {
                [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", chat._id] fileId:chat.photo.fileSmallId download_offset:0 type:FileType_Group_Photo];
                //本地头像
                unichar text = [@" " characterAtIndex:0];
                if(chat.title.length>0)
                {
                    text = [[chat.title uppercaseString] characterAtIndex:0];
                }
                [UserInfo setColorBackgroundWithView:headerImgV withSize:size withChar:text];
            }
            else
            {
                [UserInfo cleanColorBackgroundWithView:headerImgV];
                headerImgV.image = [UIImage imageWithContentsOfFile:chat.photo.localSmallPath];
            }
        }
        else
        {
            //本地头像
            headerImgV.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(chat.title.length>0)
            {
                text = [[chat.title uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:headerImgV withSize:CGSizeMake(52, 52) withChar:text];
        }
    }
    else
    {
        UserInfo *user = [[TelegramManager shareInstance] contactInfo:chat.userId];
        if(user != nil)
        {
            if(user.profile_photo != nil)
            {
                if(!user.profile_photo.isSmallPhotoDownloaded && user.profile_photo.small.remote.unique_id.length > 1)
                {
                    [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", user._id] fileId:user.profile_photo.fileSmallId download_offset:0 type:FileType_Photo];
                    //本地头像
                    headerImgV.image = nil;
                    unichar text = [@" " characterAtIndex:0];
                    if(user.displayName.length>0)
                    {
                        text = [[user.displayName uppercaseString] characterAtIndex:0];
                    }
                    [UserInfo setColorBackgroundWithView:headerImgV withSize:CGSizeMake(52, 52) withChar:text];
                }
                else
                {
                    [UserInfo cleanColorBackgroundWithView:headerImgV];
                    headerImgV.image = [UIImage imageWithContentsOfFile:user.profile_photo.localSmallPath];
                }
            }
            else
            {
                //本地头像
                headerImgV.image = nil;
                unichar text = [@" " characterAtIndex:0];
                if(user.displayName.length>0)
                {
                    text = [[user.displayName uppercaseString] characterAtIndex:0];
                }
                [UserInfo setColorBackgroundWithView:headerImgV withSize:CGSizeMake(52, 52) withChar:text];
            }
        }
        else
        {
            //本地头像
            headerImgV.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(chat.title.length>0)
            {
                text = [[chat.title uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:headerImgV withSize:CGSizeMake(52, 52) withChar:text];
        }
    }

}

+ (NSString *)titleFromChat:(ChatInfo *)chat{
    NSString *title = @"";
    if (chat.isGroup) {
        title = chat.title;
    }else{
        UserInfo *user = [[TelegramManager shareInstance] contactInfo:chat.userId];
        if (user != nil) {
            title = user.displayName;
        }else{
            title = chat.title;
        }
    }
    return title;
}

+ (NSMutableAttributedString *)contentFromChat:(ChatInfo *)chat{
    NSMutableAttributedString *mutabOfferStr;
    if (chat.lastMessage) {
        BOOL issetting = NO;
        if(chat.unread_count>0){//有未读的时候的处理方式
            UserInfo *user = [[TelegramManager shareInstance] contactInfo:chat.lastMessage.sender.user_id];
            if (chat.isGroup && user != nil && !chat.lastMessage.is_outgoing && !chat.lastMessage.isTipMessage) {//群聊
                NSDictionary *textdic = chat.lastMessage.content.text;
                NSArray *entitiesArr = [textdic objectForKey:@"entities"];
                if (entitiesArr && entitiesArr.count > 0) {
                    for (NSDictionary *itemdic in entitiesArr) {
                        NSDictionary *dicLim = [itemdic objectForKey:@"type"];
                        if (dicLim) {
                            long idlin = [[dicLim objectForKey:@"user_id"] longValue];
                            if (idlin == [UserInfo shareInstance]._id) {//@我
                                issetting = YES;
                                NSString *prestr = @"[有人@我]".lv_localized;
                                NSString *str = [NSString stringWithFormat:@"%@ %@",prestr,[NSString stringWithFormat:@"%@:%@", chat.groupLastSenderNickname, [chat.lastMessage description]]];
                                mutabOfferStr = [[NSMutableAttributedString alloc]initWithString:str];
                                NSDictionary *attributeDict1 = @{NSForegroundColorAttributeName: [UIColor colorTextForFD4E57],NSFontAttributeName: fontRegular(15)};
                                [mutabOfferStr addAttributes:attributeDict1 range:[str rangeOfString:prestr]];
                                break;
                            }
                        }
                    }
                }
                else if (chat.unread_mention_count>0){//@未读数大于0
                    issetting = YES;
                    NSString *prestr = @"[有人@我]".lv_localized;
                    NSString *str = [NSString stringWithFormat:@"%@ %@",prestr,[NSString stringWithFormat:@"%@:%@", chat.groupLastSenderNickname, [chat.lastMessage description]]];
                    mutabOfferStr = [[NSMutableAttributedString alloc]initWithString:str];
                    NSDictionary *attributeDict1 = @{NSForegroundColorAttributeName: [UIColor colorforFD4E57],NSFontAttributeName: fontRegular(15)};
                    [mutabOfferStr addAttributes:attributeDict1 range:[str rangeOfString:prestr]];
                    return mutabOfferStr;
                }
            }
        }
        if (!issetting) {
            //副标题
            NSString *text = [CZCommonTool getdraftchatid:chat._id];
            if (text && text.length > 0) {
                NSString *prestr = @"[草稿]".lv_localized;
                NSString *str = [NSString stringWithFormat:@"%@ %@",prestr,text];
                mutabOfferStr = [[NSMutableAttributedString alloc]initWithString:str];
                NSDictionary *attributeDict1 = @{NSForegroundColorAttributeName: [UIColor colorforFD4E57],NSFontAttributeName: fontRegular(15)};
                [mutabOfferStr addAttributes:attributeDict1 range:[str rangeOfString:prestr]];
            }else{
                if(chat.isGroup)
                {
                    UserInfo *user = [[TelegramManager shareInstance] contactInfo:chat.lastMessage.sender.user_id];
                    if(user != nil && !chat.lastMessage.is_outgoing && !chat.lastMessage.isTipMessage)
                    {
                        NSString *str = [NSString stringWithFormat:@"%@:%@", chat.groupLastSenderNickname, [chat.lastMessage description]];
                        mutabOfferStr = [[NSMutableAttributedString alloc]initWithString:str];
                    }
                    else
                    {
                        NSString *str = [chat.lastMessage description];
                        mutabOfferStr = [[NSMutableAttributedString alloc]initWithString:str];
                       
                    }
                }
                else
                {
                    NSString *str = [chat.lastMessage description];
                    mutabOfferStr = [[NSMutableAttributedString alloc]initWithString:str];
                }
            }
        }
    }
    return mutabOfferStr;
}

@end
