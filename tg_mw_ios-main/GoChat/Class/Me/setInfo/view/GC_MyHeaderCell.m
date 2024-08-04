//
//  GC_MyHeaderCell.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/14.
//

#import "GC_MyHeaderCell.h"

@implementation GC_MyHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.headerImageV.clipsToBounds = YES;
    self.headerImageV.layer.cornerRadius = 25;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setImageV{
    //头像
    [self.headerImageV setClipsToBounds:YES];
    [self.headerImageV setContentMode:UIViewContentModeScaleAspectFill];
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
            [UserInfo setColorBackgroundWithView:self.headerImageV withSize:CGSizeMake(42, 42) withChar:text];
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
        [UserInfo setColorBackgroundWithView:self.headerImageV withSize:CGSizeMake(42, 42) withChar:text];
    }
}

@end
