//
//  GC_CollectionMyCodeVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/10.
//

#import "GC_CollectionMyCodeVC.h"
#import "GC_CollectionRecordListVC.h"

@interface GC_CollectionMyCodeVC ()
@property (weak, nonatomic) IBOutlet UILabel *setMoneyLab;
@property (weak, nonatomic) IBOutlet UILabel *saveLab;
@property (weak, nonatomic) IBOutlet UIView *recordView;
@property (weak, nonatomic) IBOutlet UIView *contentV;

@end

@implementation GC_CollectionMyCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorMain];
    [self.customNavBar setTitle:@"收付款".lv_localized];
    [self.customNavBar setTintColor:[UIColor whiteColor]];
    [self.customNavBar setBackgroundColor:[UIColor colorMain]];
    [self initUI];
    // Do any additional setup after loading the view from its nib.
}
- (void)initUI{
    self.contentView.hidden = YES;
    self.setMoneyLab.textColor = [UIColor colorMain];
    self.saveLab.textColor = [UIColor colorMain];
    
    self.setMoneyLab.userInteractionEnabled = YES;
    self.saveLab.userInteractionEnabled = YES;
    
    self.contentV.clipsToBounds = YES;
    self.contentV.layer.cornerRadius = 10;
    
    UITapGestureRecognizer *moneyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moneyAction)];
    [self.setMoneyLab addGestureRecognizer:moneyTap];
    
    UITapGestureRecognizer *saveTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveAction)];
    [self.saveLab addGestureRecognizer:saveTap];
    
    UITapGestureRecognizer *recordTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recordAction)];
    [self.recordView addGestureRecognizer:recordTap];
    
    

}

- (void)recordAction{
    GC_CollectionRecordListVC *vc = [[GC_CollectionRecordListVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)moneyAction{
   
}
- (void)saveAction{
    
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
