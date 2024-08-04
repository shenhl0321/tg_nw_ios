//
//  GC_SetPwResultVC.m
//  GoChat
//
//  Created by wangfeiPro on 2022/1/6.
//

#import "GC_SetPwResultVC.h"

@interface GC_SetPwResultVC ()
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UILabel *setLab;
@property (weak, nonatomic) IBOutlet UILabel *statusLab;

@end

@implementation GC_SetPwResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contentView.hidden = YES;
    self.nextBtn.clipsToBounds = YES;
    self.nextBtn.layer.cornerRadius = 13;
    self.nextBtn.backgroundColor = [UIColor colorMain];
    
    self.setLab.font = [UIFont regularCustomFontOfSize:22];
    self.setLab.textColor = [UIColor colorMain];
    
    self.statusLab.font = [UIFont regularCustomFontOfSize:15];
    self.statusLab.textColor = [UIColor colorFor878D9A];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)nextAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
