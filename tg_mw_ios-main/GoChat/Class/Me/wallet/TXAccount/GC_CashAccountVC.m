//
//  GC_CashAccountVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/14.
//

#import "GC_CashAccountVC.h"
#import "GC_CashAccountCell.h"
#import "GC_ChangeAccountInfoVC.h"
#import "GC_ChangeBankInfoVC.h"

@interface GC_CashAccountVC ()

@property (nonatomic, strong)NSArray *dataArr;

@end

@implementation GC_CashAccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view.
}
- (NSArray *)dataArr{
    if (!_dataArr) {
        _dataArr = @[@{@"title":@"TXZF",@"image":@"icon_wallet_wwxx"},
                     @{@"title":@"ZFB支付".lv_localized,@"image":@"icon_wallet_zfb"},
                     @{@"title":@"银联支付".lv_localized,@"image":@"icon_wallet_bank"}];
    }
    return _dataArr;
}
- (void)initUI{
    [self.customNavBar setTitle:@"提现账户".lv_localized];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_CashAccountCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.backgroundColor = [UIColor colorForF5F9FA];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(kNavBarAndStatusBarHeight);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GC_CashAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.dataDic = self.dataArr[indexPath.row];
    cell.reBindLab.userInteractionEnabled = YES;
    cell.reBindLab.tag = indexPath.row;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reBindTap:)];
    [cell.reBindLab addGestureRecognizer:tap];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 2){
       
//        [self.nav]
    }
}

- (void)reBindTap:(UITapGestureRecognizer *)tap{
    NSInteger tag = tap.view.tag;
    
    if (tag == 2) {
        GC_ChangeBankInfoVC *vc = [[GC_ChangeBankInfoVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        GC_ChangeAccountInfoVC *vc = [[GC_ChangeAccountInfoVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
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
