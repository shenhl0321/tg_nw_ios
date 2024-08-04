//
//  JoinChatInviteLinkViewController.m
//  GoChat
//
//  Created by mac on 2021/7/10.
//

#import "JoinChatInviteLinkViewController.h"

@interface JoinChatInviteLinkViewController ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *headimage1;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *membersLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userHeadImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userHeadImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *userHeadImageView3;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel1;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel2;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel3;
@property (weak, nonatomic) IBOutlet UILabel *joinBtn;

@end

@implementation JoinChatInviteLinkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshXibUI];
    [self initUISetting];
    // Do any additional setup after loading the view from its nib.
}

- (void)refreshXibUI{
    [self.headimage1 mn_iconStyleWithRadius:35];
    self.groupNameLabel.font = fontSemiBold(16);
    self.groupNameLabel.textColor = [UIColor colorTextFor23272A];
    self.membersLabel.font = fontRegular(14);
    self.membersLabel.textColor = HexRGB(0x999999);
    [self.userHeadImageView mn_iconStyleWithRadius:25];
    [self.userHeadImageView2 mn_iconStyleWithRadius:25];
    [self.userHeadImageView3 mn_iconStyleWithRadius:25];
    self.userNameLabel1.font = fontRegular(13);
    self.userNameLabel1.textColor = [UIColor colorTextFor23272A];
    self.userNameLabel2.font = fontRegular(13);
    self.userNameLabel2.textColor = [UIColor colorTextFor23272A];
    self.userNameLabel3.font = fontRegular(13);
    self.userNameLabel3.textColor = [UIColor colorTextFor23272A];
    self.joinBtn.font = fontSemiBold(16);
    self.joinBtn.textColor = [UIColor colorMain];
}

//获取成员信息  并展示
- (void)getUserMessageWithUserid:(long)userid withShowView:(UIImageView *)imageview withNameLabel:(UILabel *)nameLabel{
    if(userid>0)
    {
        [[TelegramManager shareInstance] requestContactInfo:userid resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:UserInfo.class])
            {
                UserInfo *user = obj;
                [self resetBaseInfoWithView:imageview withNameLabel:nameLabel withUserinfo:user];
                
            }else{
                [UserInfo showTips:nil des:@"获取群成员信息失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
            }
        } timeout:^(NSDictionary *request) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"获取群成员信息失败，请稍后重试".lv_localized];
        }];
    }
    [UserInfo shareInstance].willShowContactId = 0;
}

//加入  先判断是否在群中
- (void)addGroupWithInviteLink
{
    if(self.inviteLink && self.inviteLink.length>5)
    {
        [UserInfo show];
        [[TelegramManager shareInstance] joinChatByInviteLink:self.inviteLink resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            [UserInfo dismiss];
            if(obj != nil && [obj isKindOfClass:ChatInfo.class]){
                [AppDelegate gotoChatView:obj];
            }
            else
            {
                [UserInfo showTips:nil des:@"加入群组失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
            }
        } timeout:^(NSDictionary *request) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"加入群组失败，请稍后重试".lv_localized];
        }];
    }
}

- (void)initUISetting{
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createTapGesture:)];
    tap.delegate = self;
    tap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    //赋值
    if (self.inviteInfo) {
        [self getUserHeaderImage];
        self.membersLabel.text = [NSString stringWithFormat:@"%d成员".lv_localized,self.inviteInfo.member_count];
        if (self.inviteInfo.member_user_ids.count> 0) {
            [self getUserMessageWithUserid:[[self.inviteInfo.member_user_ids objectAtIndex:0] longValue] withShowView:self.userHeadImageView withNameLabel:self.userNameLabel1];
        }
        if (self.inviteInfo.member_user_ids.count> 1) {
            [self getUserMessageWithUserid:[[self.inviteInfo.member_user_ids objectAtIndex:1] longValue] withShowView:self.userHeadImageView2 withNameLabel:self.userNameLabel2];
        }
        if (self.inviteInfo.member_user_ids.count> 2) {
            [self getUserMessageWithUserid:[[self.inviteInfo.member_user_ids objectAtIndex:2] longValue] withShowView:self.userHeadImageView3 withNameLabel:self.userNameLabel3];
        }
    }
}

//设置群头像
- (void)getUserHeaderImage
{
    if(self.inviteInfo.photo != nil)
    {
        if(!self.inviteInfo.photo.isSmallPhotoDownloaded && self.inviteInfo.photo.small.remote.unique_id.length > 1)
        {
            [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", self.inviteInfo.chat_id] fileId:self.inviteInfo.photo.fileSmallId download_offset:0 type:FileType_Group_Photo];
            //本地头像
            unichar text = [@" " characterAtIndex:0];
            if(self.inviteInfo.title.length>0)
            {
                text = [[self.inviteInfo.title uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.headimage1 withSize:CGSizeMake(42, 42) withChar:text];
        }else{
            [UserInfo cleanColorBackgroundWithView:self.headimage1];
            self.headimage1.image = [UIImage imageWithContentsOfFile:self.inviteInfo.photo.localSmallPath];
        }
    }else{
        //本地头像
        unichar text = [@" " characterAtIndex:0];
        if(self.inviteInfo.title.length>0)
        {
            text = [[self.inviteInfo.title uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.headimage1 withSize:CGSizeMake(42, 42) withChar:text];
    }
    self.groupNameLabel.text = self.inviteInfo.title;
}

//设置用户资料
- (void)resetBaseInfoWithView:(UIImageView *)headerImageView withNameLabel:(UILabel *)nameLabel withUserinfo:(UserInfo *)user{
    if(user.profile_photo != nil){
        if(!user.profile_photo.isSmallPhotoDownloaded && user.profile_photo.small.remote.unique_id.length > 1){
            [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", user._id] fileId:user.profile_photo.fileSmallId download_offset:0 type:FileType_Photo];
            //本地头像
            headerImageView.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(user.displayName.length>0)
            {
                text = [[user.displayName uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:headerImageView withSize:CGSizeMake(60, 60) withChar:text];
        }
        else
        {
            [UserInfo cleanColorBackgroundWithView:headerImageView];
            headerImageView.image = [UIImage imageWithContentsOfFile:user.profile_photo.localSmallPath];
        }
    }else{
        //本地头像
        headerImageView.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if(user.displayName.length>0)
        {
            text = [[user.displayName uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:headerImageView withSize:CGSizeMake(60, 60) withChar:text];
    }
    
    if(user.displayName != nil && user.displayName.length>0)
    {
        nameLabel.text = [NSString stringWithFormat:@"%@", user.displayName];
    }else{
        nameLabel.text = nil;
    }
}

- (void)createTapGesture:(UITapGestureRecognizer *)sender {
    CATransition *animation = [CATransition animation];
    animation.duration = 0.3;
    animation.type = kCATransitionReveal;
    animation.subtype = kCATransitionFromTop;
    [self.view.window.layer addAnimation:animation forKey:nil];
    [self dismissViewControllerAnimated:NO completion:0];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{

    if ([touch.view isEqual:self.view]) {
        return YES;
    }
    return NO;
}

//加入群组
- (IBAction)addGroupClick:(UIButton *)sender {
    [self addGroupWithInviteLink];
}
//取消
- (IBAction)cancleBtnClick:(UIButton *)sender {
    [self createTapGesture:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
