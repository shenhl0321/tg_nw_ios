//
//  QTGroupFirTableViewCell.m
//  GoChat
//
//  Created by mac on 2021/7/24.
//

#import "QTGroupFirTableViewCell.h"

@interface QTGroupFirTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *addNewMemberLab;
@property (weak, nonatomic) IBOutlet UILabel *noticeLab;
@property (weak, nonatomic) IBOutlet UILabel *searchMemberLab;
@property (weak, nonatomic) IBOutlet UILabel *moreLab;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *firstSpace;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *secondSpace;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *thirdSpace;


@end

@implementation QTGroupFirTableViewCell

- (void)setMembersList:(NSArray *)membersList{
    if (membersList) {
        _membersList = membersList;//GroupMemberInfo
        NSInteger onlineNumber = 0;
        for (GroupMemberInfo *iteminfo in membersList) {
            UserInfo *user = [[TelegramManager shareInstance] contactInfo:iteminfo.user_id];
            if(user != nil)
            {
                NSString *onlineStyle = [user.status objectForKey:@"@type"];
               if ([onlineStyle isEqualToString:@"userStatusOnline"]){
                    onlineNumber++;
                }else if ([onlineStyle isEqualToString:@"userStatusRecently"]){
                    onlineNumber++;
                }
            }
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.addNewMemberLab.textColor = [UIColor colorMain];
    self.noticeLab.textColor = [UIColor colorMain];
    self.searchMemberLab.textColor = [UIColor colorMain];
    self.moreLab.textColor = [UIColor colorMain];
    [self.headerImageView mn_iconStyleWithRadius:37.5];
    
    self.firstSpace.constant = self.secondSpace.constant = self.thirdSpace.constant = (kScreenWidth() - (44 * 4) - kAdapt(60)) / 3;
    AppConfigInfo *config = [AppConfigInfo sharedInstance];
}

- (void)reset{
    
}

- (void)setChatInfo:(ChatInfo *)chatInfo{
    if (chatInfo) {
        _chatInfo = chatInfo;
        [self resetBaseInfo];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)functionBtnClick:(UIButton *)sender {
    NSLog(@"tag : %ld",(long)sender.tag);
    if (_delegate && [_delegate respondsToSelector:@selector(cellFunctionBtnClickWithTag:withSender:)]) {
        [_delegate cellFunctionBtnClickWithTag:sender.tag withSender:sender];
    }
}

//设置UI
- (void)resetBaseInfo
{
    if(self.chatInfo.photo != nil){
        if(!self.chatInfo.photo.isSmallPhotoDownloaded && self.chatInfo.photo.small.remote.unique_id.length > 1){
            [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", self.chatInfo._id] fileId:self.chatInfo.photo.fileSmallId download_offset:0 type:FileType_Group_Photo];
            //本地头像
            self.headerImageView.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(self.chatInfo.title.length>0){
                text = [[self.chatInfo.title uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(75, 75) withChar:text];
        }else{
            [UserInfo cleanColorBackgroundWithView:self.headerImageView];
            self.headerImageView.image = [UIImage imageWithContentsOfFile:self.chatInfo.photo.localSmallPath];
        }
    }else{
        //本地头像
        self.headerImageView.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if(self.chatInfo.title.length>0)
        {
            text = [[self.chatInfo.title uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(75, 75) withChar:text];
    }
    self.groupNameLabel.text = self.chatInfo.title;
    
    //设置功能入口UI
    for (UIView *suview in self.contentView.subviews) {
        if (suview.tag == 101 && [suview isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)suview;//Close_inform_clo
            btn.selected = self.chatInfo.default_disable_notification;
        }
        if (suview.tag == 1001 && [suview isKindOfClass:[UILabel class]]) {
            UILabel *labelLin = (UILabel *)suview;
            if (self.chatInfo.default_disable_notification) {//禁用通知
                labelLin.text = @"开启通知".lv_localized;
            }else{
                labelLin.text = @"关闭通知".lv_localized;
            }
        }
    }
}


@end
