//
//  GC_CollectionCode.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/5.
//

#import "GC_CollectionCode.h"
#import "GC_CollectionMyCodeVC.h"

@interface GC_CollectionCode ()
@property (weak, nonatomic) IBOutlet UIView *contentV;
@property (weak, nonatomic) IBOutlet UIView *scanView;
@property (weak, nonatomic) IBOutlet UILabel *stopLab;
@property (weak, nonatomic) IBOutlet UILabel *moneyLab;
@property (weak, nonatomic) IBOutlet UIImageView *scanImageV;

@end

@implementation GC_CollectionCode

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.customNavBar setTitle:@"收付款".lv_localized];
    [self.customNavBar setTintColor:[UIColor whiteColor]];
    [self.customNavBar setBackgroundColor:HexRGB(0xF2BA00)];
    self.view.backgroundColor = HexRGB(0xF2BA00);
    [self initUI];
    // Do any additional setup after loading the view from its nib.
}
- (void)initUI{
    self.contentV.clipsToBounds = YES;
    self.contentV.layer.cornerRadius = 10;
    
    self.scanView.clipsToBounds = YES;
    self.scanView.layer.cornerRadius = 13;
    
    self.stopLab.textColor = [UIColor colorMain];
    self.stopLab.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *stopTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopAction)];
    [self.stopLab addGestureRecognizer:stopTap];
    
    UITapGestureRecognizer *scanTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanAction)];
    [self.scanView addGestureRecognizer:scanTap];
    self.scanView.userInteractionEnabled = YES;
    self.contentView.hidden = YES;
    
}

- (void)stopAction{
    
}
- (void)scanAction{
    GC_CollectionMyCodeVC *vc = [[GC_CollectionMyCodeVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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
