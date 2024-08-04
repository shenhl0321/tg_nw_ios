//
//  GC_MyScanVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/15.
//

#import "GC_MyScanVC.h"
#import "LBXScanNative.h"
#import "UIView+ScreensShot.h"

@interface GC_MyScanVC ()
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageV;
@property (weak, nonatomic) IBOutlet UIView *qrCodeCont;
@property (weak, nonatomic) IBOutlet UILabel *tipL;
@property (weak, nonatomic) IBOutlet UILabel *numLAb;

@property (weak, nonatomic) IBOutlet UIView *saveView;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet UIView *logoView;


@end

@implementation GC_MyScanVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:@"我的二维码".lv_localized];
    self.customNavBar.backgroundColor = [UIColor clearColor];
    
    
    [self initUI];
    self.contentView.hidden = YES;
    self.view.backgroundColor = [UIColor colorForF5F9FA];
//    NSString *name = localAppName;
    self.tipL.text = [NSString stringWithFormat:@"使用%@App扫描二维码，加我为好友".lv_localized, localAppName.lv_localized];
    self.numLAb.text = [NSString stringWithFormat:@"我的坤坤TG号：%@".lv_localized,[UserInfo shareInstance].username];
    // Do any additional setup after loading the view from its nib.
}

- (void)initUI{
    [self.saveBtn setTitle:@"" forState:UIControlStateNormal];
    [self.shareBtn setTitle:@"" forState:UIControlStateNormal];
    self.backgroudV.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    self.backgroudV.layer.cornerRadius = 20;
    self.backgroudV.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08].CGColor;
    self.backgroudV.layer.shadowOffset = CGSizeMake(0,0);
    self.backgroudV.layer.shadowOpacity = 1;
    self.backgroudV.layer.shadowRadius = 10;
    self.backgroudV.clipsToBounds = YES;
    
    [self resetUI];
    
}

- (void)resetUI
{
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
            if(user.displayName.length>0)
            {
                text = [[user.displayName uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.headerImageV withSize:CGSizeMake(70, 70) withChar:text];
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
        if(user.displayName.length>0)
        {
            text = [[user.displayName uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.headerImageV withSize:CGSizeMake(70, 70) withChar:text];
    }
    //昵称
    self.nameLab.text = user.displayName;
    //二维码
    //self.qrImageView.image = [ZXingWrapper createCodeWithString: size:CGSizeMake(1000, 1000) CodeFomart:kBarcodeFormatQRCode];
    self.qrCodeImageV.image = [LBXScanNative createQRWithString:[user qrString] QRSize:CGSizeMake(460, 460)];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)saveAction:(id)sender {
    self.customNavBar.hidden = YES;
    self.saveView.hidden = YES;
    self.shareView.hidden = YES;
    self.logoView.hidden = NO;
    
    UIImage *img = [self.view screenShot];
    
    self.customNavBar.hidden = NO;
    self.saveView.hidden = NO;
    self.shareView.hidden = NO;
    self.logoView.hidden = YES;
    
    if(img)
    {
        UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(!error)
    {
        [UserInfo showTips:nil des:@"已保存".lv_localized];
    }
    else
    {
        [UserInfo showTips:nil des:@"保存失败".lv_localized];
    }
}
- (IBAction)shareAction:(id)sender {
    
    UIImage *img = [self.qrCodeCont screenShot];
    if(img)
    {
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"Image", img] applicationActivities:nil];
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
}

@end
