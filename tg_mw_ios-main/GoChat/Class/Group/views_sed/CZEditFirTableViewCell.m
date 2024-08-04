//
//  CZEditFirTableViewCell.m
//  GoChat
//
//  Created by mac on 2021/8/5.
//

#import "CZEditFirTableViewCell.h"

@interface CZEditFirTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UITextField *groupNameField;
@property (weak, nonatomic) IBOutlet UILabel *clickUploadLab;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLab;

@end

@implementation CZEditFirTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.clickUploadLab.textColor = [UIColor colorMain];
    self.clickUploadLab.font = fontRegular(14);
    [self.groupImageView mn_iconStyleWithRadius:35];
    self.groupNameLab.font = fontRegular(16);
    self.groupNameLab.textColor = [UIColor colorTextFor23272A];
    [self.groupNameField mn_defalutStyleWithFont:fontRegular(15)];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (NSString *)groupTitleStr{
    if ([self.chatInfo.title isEqualToString:self.groupNameField.text]) {
        //未改变
        return nil;
    }else{
        return self.groupNameField.text;
    }
}

//上传群组图片
- (IBAction)uploadGroupImageView:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(uploadGroupImageViewClick)]) {
        [_delegate uploadGroupImageViewClick];
    }
}

- (IBAction)editGroupName:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(editGrouNameClick)]) {
        [_delegate editGrouNameClick];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setChatInfo:(ChatInfo *)chatInfo{
    if (chatInfo) {
        _chatInfo = chatInfo;
        [self resetBaseInfo];
    }
}

- (void)resetBaseInfo
{
    [self.groupImageView setClipsToBounds:YES];
    [self.groupImageView setContentMode:UIViewContentModeScaleAspectFill];
    if(self.chatInfo.photo != nil)
    {
        if(!self.chatInfo.photo.isSmallPhotoDownloaded && self.chatInfo.photo.small.remote.unique_id.length > 1)
        {
            [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", self.chatInfo._id] fileId:self.chatInfo.photo.fileSmallId download_offset:0 type:FileType_Group_Photo];
            //本地头像
            self.groupImageView.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(self.chatInfo.title.length>0)
            {
                text = [[self.chatInfo.title uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.groupImageView withSize:CGSizeMake(42, 42) withChar:text];
        }
        else
        {
            [UserInfo cleanColorBackgroundWithView:self.groupImageView];
            self.groupImageView.image = [UIImage imageWithContentsOfFile:self.chatInfo.photo.localSmallPath];
        }
    }else{
        //本地头像
        self.groupImageView.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if(self.chatInfo.title.length>0)
        {
            text = [[self.chatInfo.title uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.groupImageView withSize:CGSizeMake(42, 42) withChar:text];
    }
    if (self.chatInfo.title && ![self.groupTitleStr isEqualToString:self.chatInfo.title]) {
        self.groupNameField.text = self.chatInfo.title;
    }
}

@end
