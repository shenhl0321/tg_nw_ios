//
//  GC_MineInfoCell.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/1.
//

#import "GC_MineInfoCell.h"

@implementation GC_MineInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.nameLab.textColor = [UIColor colorTextFor23272A];
    self.nameLab.font = [UIFont regularCustomFontOfSize:19];
    self.desLab.textColor = [UIColor colorTextFor878D9A];
    self.desLab.font = [UIFont regularCustomFontOfSize:15];
    
    [self.setBtn setTitle:@"" forState:UIControlStateNormal];
    [self.scanBtn setTitle:@"" forState:UIControlStateNormal];
    
//    [self.scanBtn setBackgroundImage:[UIImage imageNamed:@"icon_mine_scan".lv_Style] forState:UIControlStateNormal];
//    [self.setBtn setBackgroundImage:[UIImage imageNamed:@"icon_mine_set".lv_Style] forState:UIControlStateNormal];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Initialization code
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [_headerImageV addGestureRecognizer:tap];
    _headerImageV.userInteractionEnabled = YES;
    AppConfigInfo *config = [AppConfigInfo sharedInstance];
    self.scanBtn.hidden = !config.can_see_qr_code;
}

- (void)resetUI
{
    //头像
    UserInfo *user = [UserInfo shareInstance];
    if(user.profile_photo != nil)
    {
        if(!user.profile_photo.isSmallPhotoDownloaded)
        {
            [[FileDownloader instance] downloadImage:[NSString stringWithFormat:@"%ld", user._id] fileId:user.profile_photo.fileSmallId type:FileType_Photo];
            //本地头像
            self.headerImageV.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if([UserInfo shareInstance].displayName.length>0)
            {
                text = [[[UserInfo shareInstance].displayName uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.headerImageV withSize:CGSizeMake(60, 60) withChar:text];
        }
        else
        {
            [UserInfo cleanColorBackgroundWithView:self.headerImageV];
            self.headerImageV.image = [UIImage imageWithContentsOfFile:user.profile_photo.localSmallPath];
        }
    }
    else
    {
        //本地头像
        self.headerImageV.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if([UserInfo shareInstance].displayName.length>0)
        {
            text = [[[UserInfo shareInstance].displayName uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.headerImageV withSize:CGSizeMake(60, 60) withChar:text];
    }
    
    //昵称、号码
    UserInfo *userInfoLim =  [UserInfo shareInstance];
    self.nameLab.text = [UserInfo shareInstance].displayName;
    
    NSString *userNameStr = @"";
    if(!IsStrEmpty([UserInfo shareInstance].username))
    {
        userNameStr = [NSString stringWithFormat:@"@%@", [UserInfo shareInstance].username];
    }
//    self.desLab.text = userNameStr;

    self.desLab.text = [NSString stringWithFormat:@"坤坤TG号：%@", userNameStr];
}
- (IBAction)buttonClick:(UIButton *)sender {
    [self tapAction];
}


- (void)tapAction{
    if (self.clickBlock) {
        self.clickBlock();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
