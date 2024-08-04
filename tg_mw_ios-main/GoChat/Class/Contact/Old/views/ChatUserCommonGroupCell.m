//
//  ChatUserCommonGroupCell.m
//  GoChat
//
//  Created by apple on 2021/12/24.
//

#import "ChatUserCommonGroupCell.h"

@interface ChatUserCommonGroupCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;

@end

@implementation ChatUserCommonGroupCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.iconV setClipsToBounds:YES];
    [self.iconV setContentMode:UIViewContentModeScaleAspectFill];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setChatInfo:(ChatInfo *)chatInfo{
    _chatInfo = chatInfo;
    
    self.nameL.text = self.chatInfo.title;
    if(self.chatInfo.photo != nil)
    {
        if(!self.chatInfo.photo.isSmallPhotoDownloaded && self.chatInfo.photo.small.remote.unique_id.length > 1)
        {
            [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", self.chatInfo._id] fileId:self.chatInfo.photo.fileSmallId download_offset:0 type:FileType_Group_Photo];
            //本地头像
            self.iconV.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(self.chatInfo.title.length>0)
            {
                text = [[self.chatInfo.title uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.iconV withSize:CGSizeMake(42, 42) withChar:text];
        }
        else
        {
            [UserInfo cleanColorBackgroundWithView:self.iconV];
            self.iconV.image = [UIImage imageWithContentsOfFile:self.chatInfo.photo.localSmallPath];
        }
    }
    else
    {
        //本地头像
        self.iconV.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if(self.chatInfo.title.length>0)
        {
            text = [[self.chatInfo.title uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.iconV withSize:CGSizeMake(42, 42) withChar:text];
    }
}


@end
