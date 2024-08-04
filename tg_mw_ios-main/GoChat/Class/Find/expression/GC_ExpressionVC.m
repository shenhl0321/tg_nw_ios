//
//  GC_ExpressionVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/15.
//

#import "GC_ExpressionVC.h"
#import "GC_ExpressionCell.h"
#import "GC_ExpressionTitleCell.h"

#import "GC_ExpressionSetVC.h"
#import "GC_ExpressionDetailVC.h"

@interface GC_ExpressionVC ()

@property(nonatomic, strong)UIButton *setBtn;

@end

@implementation GC_ExpressionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:@"表情商店".lv_localized];
    [self initUI];
    // Do any additional setup after loading the view.
}
- (UIButton *)setBtn{
    if (!_setBtn) {
        _setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_setBtn setImage:[UIImage imageNamed:@"icon_mine_set"] forState:UIControlStateNormal];
        [_setBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
        _setBtn.titleLabel.font = [UIFont semiBoldCustomFontOfSize:17];
        [_setBtn addTarget:self action:@selector(setAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _setBtn;
}

    
- (void)initUI{

    [self.view addSubview:self.tableView];
    [self.customNavBar addSubview:self.setBtn];
    [self.setBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.width.height.mas_equalTo(50);
        make.bottom.mas_equalTo(0);
    }];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_ExpressionCell" bundle:nil] forCellReuseIdentifier:@"GC_ExpressionCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_ExpressionTitleCell" bundle:nil] forCellReuseIdentifier:@"GC_ExpressionTitleCell"];
    
   
    self.tableView.backgroundColor = [UIColor colorForF5F9FA];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(kNavBarAndStatusBarHeight);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        GC_ExpressionTitleCell * cell = [tableView dequeueReusableCellWithIdentifier:@"GC_ExpressionTitleCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    GC_ExpressionCell * cell = [tableView dequeueReusableCellWithIdentifier:@"GC_ExpressionCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 50;
    }
    return  70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GC_ExpressionDetailVC *vc = [[GC_ExpressionDetailVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setAction{
    GC_ExpressionSetVC *vc = [[GC_ExpressionSetVC alloc] init];
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
