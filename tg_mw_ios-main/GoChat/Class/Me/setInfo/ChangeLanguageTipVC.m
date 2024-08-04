//
//  ChangeLanguageTipVC.m
//  GoChat
//
//  Created by zlp&hj on 2022/7/15.
//

#import "ChangeLanguageTipVC.h"

@interface ChangeLanguageTipVC ()
/// <#code#>
@property (nonatomic, strong) UILabel *tipL;
@end

@implementation ChangeLanguageTipVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor  = [UIColor blackColor];
    UILabel *tipL = [[UILabel alloc] init];
    [self.view addSubview:tipL];
    self.tipL = tipL;
    tipL.textColor = [UIColor whiteColor];
    tipL.text = @"切换语言".lv_localized;
    [self.tipL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
    }];
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
