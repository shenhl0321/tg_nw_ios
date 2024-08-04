//
//  QTGroupPersonEditVC.m
//  BaseChat
//
//  Created by 漫漫人生路 on 2023/4/9.
//

#import "QTGroupPersonEditVC.h"

@interface QTGroupPersonEditVC ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageV;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTF;

@end

@implementation QTGroupPersonEditVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self getData];
}

#pragma mark - initUI
- (void)initUI{
    self.title = @"";
    self.view.backgroundColor = HEXCOLOR(0xFFFFFF);
    
    [self refreshIconImgV];
    [self refreshNickName];
}
#pragma mark - getData
- (void)getData{
    
}
#pragma mark - get/set

#pragma mark - click
- (IBAction)buttonClick:(UIButton *)sender {
    if (sender.tag == 1){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if (sender.tag == 2){
        //编辑名字的
        if (IsStrEmpty(self.nickNameTF.text)){
            [SVProgressHUD showInfoWithStatus:self.nickNameTF.placeholder];
            return;
        }
        if (self.nickNameTF.text != self.prevValueString) {
            [self saveUserNickname:self.nickNameTF.text];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}
-(void)navigationBar:(MNNavigationBar *)navationBar didClickRightBtn:(UIButton *)btn{
    
}

- (void)saveUserNickname:(NSString *)name
{
    MJWeakSelf
    [UserInfo show];
    [[TelegramManager shareInstance] setContactNickName:self.toBeModifyUser nickName:name resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response]){
            [UserInfo showTips:nil des:@"备注设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }else{
            if (weakSelf.successBlock){
                weakSelf.successBlock(weakSelf.nickNameTF.text);
            }
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"备注设置失败，请稍后重试".lv_localized];
    }];
}


#pragma mark - delegate

#pragma mark - other
- (void)refreshNickName{
    NSString *nickName = @"";
    nickName = self.toBeModifyUser.displayName;
    self.nickNameTF.text = nickName;
}
- (void)refreshIconImgV{
    if(self.toBeModifyUser.profile_photo != nil)
    {
        if(!self.toBeModifyUser.profile_photo.isSmallPhotoDownloaded)
        {
            [[FileDownloader instance] downloadImage:[NSString stringWithFormat:@"%ld", self.toBeModifyUser._id] fileId:self.toBeModifyUser.profile_photo.fileSmallId type:FileType_Photo];
            //本地头像
            self.avatarImageV.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(self.toBeModifyUser.displayName.length>0)
            {
                text = [[self.toBeModifyUser.displayName uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.avatarImageV withSize:CGSizeMake(70, 70) withChar:text];
        }
        else
        {
            [UserInfo cleanColorBackgroundWithView:self.avatarImageV];
            self.avatarImageV.image = [UIImage imageWithContentsOfFile:self.toBeModifyUser.profile_photo.localSmallPath];
        }
    }
    else
    {
        //本地头像
        self.avatarImageV.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if(self.toBeModifyUser.displayName.length>0)
        {
            text = [[self.toBeModifyUser.displayName uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.avatarImageV withSize:CGSizeMake(70, 70) withChar:text];
    }
}


@end
