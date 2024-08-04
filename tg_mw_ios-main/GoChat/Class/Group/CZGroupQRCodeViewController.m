//
//  CZGroupQRCodeViewController.m
//  GoChat
//
//  Created by mac on 2021/7/9.
//

#import "CZGroupQRCodeViewController.h"

@interface CZGroupQRCodeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *bottomTipsLabel;
@property (weak, nonatomic) IBOutlet UIView *screenView;
@property (weak, nonatomic) IBOutlet UIView *shadowBg;
@property (weak, nonatomic) IBOutlet UIView *whiteBg;
@property (weak, nonatomic) IBOutlet UIView *bigShadowBg;
@property (nonatomic,strong) UIImage *shareImag;

@property (weak, nonatomic) IBOutlet UILabel *tipL;

@property (weak, nonatomic) IBOutlet UIImageView *saveImageV;
@property (weak, nonatomic) IBOutlet UILabel *saveLab;
@property (weak, nonatomic) IBOutlet UIImageView *shareImageV;
@property (weak, nonatomic) IBOutlet UILabel *shareLab;
@property (weak, nonatomic) IBOutlet UIView *logoView;



@end

@implementation CZGroupQRCodeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:@"群二维码".lv_localized];
    self.customNavBar.backgroundColor = [UIColor clearColor];
    self.customNavBar.contentView.backgroundColor = [UIColor clearColor];
    [self.contentView removeFromSuperview];
    self.bigShadowBg.layer.shadowColor =[UIColor colorTextFor000000_:0.08].CGColor;
    self.bigShadowBg.layer.shadowOffset = CGSizeMake(0, 0);
    self.bigShadowBg.layer.shadowRadius = 10;
    self.bigShadowBg.layer.shadowOpacity = 1;
    self.shadowBg.layer.shadowColor =[UIColor colorTextFor000000_:0.08].CGColor;
    self.shadowBg.layer.shadowOffset = CGSizeMake(0, 0);
    self.shadowBg.layer.shadowRadius = 10;
    self.shadowBg.layer.shadowOpacity = 1;
    self.shadowBg.layer.cornerRadius =40;
    self.whiteBg.layer.cornerRadius = 40;
    self.headerImageView.layer.cornerRadius = 35;
    self.headerImageView.layer.masksToBounds = YES;
    self.view.backgroundColor =  HexRGB(0xF5F9FA);
    [self settingCurrentUI];
    
    self.tipL.text = [NSString stringWithFormat:@"用%@扫码，加入该群".lv_localized, localAppName.lv_localized];
    // Do any additional setup after loading the view from its nib.
}

- (void)settingCurrentUI{
    if (_chatInfo) {
        [self getUserHeaderImage];
    }
    if (_super_groupFullInfo) {
        NSString *invitationStr = self.super_groupFullInfo.invite_link;
        UIImage *qrcodeImage = [CZCommonTool createQRCodeWithTargetString:invitationStr logoImage:[UIImage new]];
        self.qrCodeImageView.image = qrcodeImage;
    }
}

- (IBAction)saveBtnClick:(UIButton *)sender {
    self.customNavBar.hidden = YES;
    self.saveImageV.hidden = YES;
    self.saveLab.hidden = YES;
    self.shareImageV.hidden = YES;
    self.shareLab.hidden = YES;
    self.logoView.hidden = NO;
    
    self.shareImag =[CZCommonTool captureImageInView:self.view];
    
    self.customNavBar.hidden = NO;
    self.saveImageV.hidden = NO;
    self.saveLab.hidden = NO;
    self.shareImageV.hidden = NO;
    self.shareLab.hidden = NO;
    self.logoView.hidden = YES;
    
    
    [self loadImageFinished:self.shareImag];
}

- (IBAction)shareBtnClick:(UIButton *)sender {
    if (!self.shareImag) {
        self.shareImag =[CZCommonTool captureImageInView:self.screenView];
    }
    NSData *imageData = UIImagePNGRepresentation(self.shareImag);
    NSArray *activityItems = @[imageData];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

//设置群头像
- (void)getUserHeaderImage
{
    if(self.chatInfo.photo != nil)
    {
        if(!self.chatInfo.photo.isSmallPhotoDownloaded && self.chatInfo.photo.small.remote.unique_id.length > 1)
        {
            [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", self.chatInfo._id] fileId:self.chatInfo.photo.fileSmallId download_offset:0 type:FileType_Group_Photo];
            //本地头像
            unichar text = [@" " characterAtIndex:0];
            if(self.chatInfo.title.length>0)
            {
                text = [[self.chatInfo.title uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(70, 70) withChar:text];
        }else{
            [UserInfo cleanColorBackgroundWithView:self.headerImageView];
            self.headerImageView.image = [UIImage imageWithContentsOfFile:self.chatInfo.photo.localSmallPath];
        }
    }else{
        //本地头像
        unichar text = [@" " characterAtIndex:0];
        if(self.chatInfo.title.length>0)
        {
            text = [[self.chatInfo.title uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(70, 70) withChar:text];
    }
    self.groupNameLabel.text = self.chatInfo.title;
}

//保存到相册
- (void)loadImageFinished:(UIImage *)image{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}
 
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        [UserInfo showTips:self.view des:@"保存失败，请重试!".lv_localized];
    }else{
        [UserInfo showTips:self.view des:@"保存到相册成功!".lv_localized];
    }
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
