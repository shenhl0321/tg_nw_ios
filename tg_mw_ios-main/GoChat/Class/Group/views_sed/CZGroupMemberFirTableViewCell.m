//
//  CZGroupMemberFirTableViewCell.m
//  GoChat
//
//  Created by mac on 2021/7/24.
//

#import "CZGroupMemberFirTableViewCell.h"

@interface CZGroupMemberFirTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *managerMarkLabel;
@property (weak, nonatomic) IBOutlet UILabel *latelyOnlineLabel;

@end

@implementation CZGroupMemberFirTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.leftImageView mn_iconStyleWithRadius:21];
    self.nameLabel.font = fontRegular(16);
    self.nameLabel.textColor = [UIColor colorTextFor23272A];
    self.latelyOnlineLabel.textColor = [UIColor colorTextForA9B0BF];
    self.latelyOnlineLabel.font = fontRegular(14);
    self.managerMarkLabel.layer.cornerRadius = 5.5;
    self.managerMarkLabel.backgroundColor = [UIColor colorMain];
    self.managerMarkLabel.font = fontRegular(11);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellModel:(NSObject *)cellModel{
    if (cellModel) {
        _cellModel = cellModel;
        if([cellModel isKindOfClass:[GroupMemberInfo class]])
        {
            GroupMemberInfo *info = (GroupMemberInfo *)cellModel;
            UserInfo *user = [[TelegramManager shareInstance] contactInfo:info.user_id];
            if(user != nil)
            {
                if(user.profile_photo != nil)
                {
                    if(!user.profile_photo.isSmallPhotoDownloaded && user.profile_photo.small.remote.unique_id.length > 1){
                        [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", user._id] fileId:user.profile_photo.fileSmallId download_offset:0 type:FileType_Photo];
                        //本地头像
                        _leftImageView.image = nil;
                        unichar text = [@" " characterAtIndex:0];
                        if(user.displayName.length>0)
                        {
                            text = [[user.displayName uppercaseString] characterAtIndex:0];
                        }
                        CGFloat cellWidth = (SCREEN_WIDTH - 30 - 20*4)/5;
                        [UserInfo setColorBackgroundWithView:_leftImageView withSize:CGSizeMake(cellWidth, cellWidth) withChar:text];
                    }else{
                        [UserInfo cleanColorBackgroundWithView:_leftImageView];
                        _leftImageView.image = [UIImage imageWithContentsOfFile:user.profile_photo.localSmallPath];
                    }
                }else{
                    //本地头像
                    _leftImageView.image = nil;
                    unichar text = [@" " characterAtIndex:0];
                    if(user.displayName.length>0)
                    {
                        text = [[user.displayName uppercaseString] characterAtIndex:0];
                    }
                    CGFloat cellWidth = (SCREEN_WIDTH - 30 - 20*4)/5;
                    [UserInfo setColorBackgroundWithView:_leftImageView withSize:CGSizeMake(cellWidth, cellWidth) withChar:text];
                }
                _nameLabel.text = user.displayName;
            }else{
                _nameLabel.text = [NSString stringWithFormat:@"u%ld", info.user_id];
                //本地头像
                _leftImageView.image = nil;
                unichar text = [@" " characterAtIndex:0];
                if(_nameLabel.text.length>0)
                {
                    text = [[_nameLabel.text uppercaseString] characterAtIndex:0];
                }
                CGFloat cellWidth = (SCREEN_WIDTH - 30 - 20*4)/5;
                [UserInfo setColorBackgroundWithView:_leftImageView withSize:CGSizeMake(cellWidth, cellWidth) withChar:text];
            }
            if ([NSString xhq_notEmpty:info.nickname]) {
                _nameLabel.text = info.nickname;
            }
            //权限  在线时间
            _managerMarkLabel.hidden = ![info isManagerRole];
            
            if(user != nil){
                NSString *subtitleStr = nil;
                NSString *onlineStyle = [user.status objectForKey:@"@type"];
                if ([onlineStyle isEqualToString:@"userStatusEmpty"]) {
                    subtitleStr = @"";
                }else if ([onlineStyle isEqualToString:@"userStatusLastMonth"]){
                    subtitleStr = @"一月前上线".lv_localized;
                }else if ([onlineStyle isEqualToString:@"userStatusLastWeek"]){
                    subtitleStr = @"一周前上线".lv_localized;
                }else if ([onlineStyle isEqualToString:@"userStatusOffline"]){//计算时间
                    NSString *str = [NSString stringWithFormat:@"%@",[user.status objectForKey:@"was_online"]];
                    subtitleStr = [CZCommonTool labelFinallyTime:str];
                }else if ([onlineStyle isEqualToString:@"userStatusOnline"]){
                    subtitleStr = @"在线".lv_localized;
                }else if ([onlineStyle isEqualToString:@"userStatusRecently"]){
                    subtitleStr = @"最近在线".lv_localized;
                }
                _latelyOnlineLabel.text = subtitleStr;
            }
        }else if([cellModel isKindOfClass:[MessageInfo class]]){
            MessageInfo *info = (MessageInfo *)cellModel;
            if (info.messageType == MessageType_Document) {
                self.leftImageView.image = [UIImage imageNamed:@"detail_document"];
                self.nameLabel.text = info.content.title;
                self.managerMarkLabel.hidden = YES;
                self.latelyOnlineLabel.text = [NSString stringWithFormat:@"%@ %@",info.content.document.totalSize,[Common getMessageDay:info.date]];
            }else if (info.messageType == MessageType_Audio) {
                self.leftImageView.image = [UIImage imageNamed:@"detail_voice"];
                UserInfo *user = [[TelegramManager shareInstance] contactInfo:info.sender.user_id];
                self.nameLabel.text = user.displayName;
                self.managerMarkLabel.hidden = YES;
                self.latelyOnlineLabel.text = [NSString stringWithFormat:@"%@ %@",[NSString stringWithFormat:@"%ld\"",lround(info.content.audio.duration)],[Common getMessageDay:info.date]];
            }else if (info.messageType == MessageType_Voice) {
                self.leftImageView.image = [UIImage imageNamed:@"detail_voice"];
                UserInfo *user = [[TelegramManager shareInstance] contactInfo:info.sender.user_id];
                self.nameLabel.text = user.displayName;
                self.managerMarkLabel.hidden = YES;
                self.latelyOnlineLabel.text = [NSString stringWithFormat:@"%@ %@",[NSString stringWithFormat:@"%ld\"",lround(info.content.voice_note.duration)],[Common getMessageDay:info.date]];
            }
            
        }
//        if([cellModel isKindOfClass:[NSString class]])
//        {
//            if([@"add" isEqualToString:(NSString *)cellModel])
//            {
//                [UserInfo cleanColorBackgroundWithView:_headerImageView];
//                _headerImageView.image = [UIImage imageNamed:@"icon_add"];
//                _userNameLabel.text = @"   ";
//            }
//            if([@"delete" isEqualToString:(NSString *)cellModel])
//            {
//                [UserInfo cleanColorBackgroundWithView:_headerImageView];
//                _headerImageView.image = [UIImage imageNamed:@"icon_delete"];
//                _userNameLabel.text = @"   ";
//            }
//        }
    }
}

@end
