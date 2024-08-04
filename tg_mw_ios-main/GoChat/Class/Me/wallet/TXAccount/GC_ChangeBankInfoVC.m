//
//  GC_ChangeBankInfoVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/14.
//

#import "GC_ChangeBankInfoVC.h"
#import "GC_CommonInputCell.h"
#import "GC_CommonSelectCell.h"

@interface GC_ChangeBankInfoVC ()

@property (nonatomic, strong)UIButton *saveBtn;

@property (nonatomic, strong)NSArray *dataArr;

@end

@implementation GC_ChangeBankInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    self.contentView.hidden = YES;
    // Do any additional setup after loading the view.
}
- (NSArray *)dataArr{
    if (!_dataArr) {
        _dataArr = @[@{@"title":@"银行卡号".lv_localized,@"place":@"请输入银行卡号".lv_localized},
        @{@"title":@"开户行".lv_localized,@"place":@"请选择银行卡开户行".lv_localized},
                     @{@"title":@"所在地".lv_localized,@"place":@"请选择银行卡所在地".lv_localized},
                     @{@"title":@"所在网点".lv_localized,@"place":@"请输入网点名称".lv_localized},
                     @{@"title":@"姓名".lv_localized,@"place":@"请输入持卡人姓名".lv_localized},
                     @{@"title":@"身份证".lv_localized,@"place":@"请输入持卡人身份证".lv_localized},
                     @{@"title":@"手机号".lv_localized,@"place":@"请输入绑定银行卡手机号码".lv_localized},];
    }
    return _dataArr;
}
- (UIButton *)saveBtn{
    if (!_saveBtn) {
        _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveBtn setTitle:@"保存".lv_localized forState:UIControlStateNormal];
        _saveBtn.backgroundColor = [UIColor colorMain];
        _saveBtn.layer.cornerRadius = 13;
        _saveBtn.titleLabel.font = [UIFont semiBoldCustomFontOfSize:17];
        [_saveBtn addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveBtn;
}

- (void)initUI{
    [self.customNavBar setTitle:@"提现账户".lv_localized];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.saveBtn];
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.bottom.mas_equalTo(-50);
        make.height.mas_equalTo(55);
    }];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_CommonInputCell" bundle:nil] forCellReuseIdentifier:@"GC_CommonInputCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_CommonSelectCell" bundle:nil] forCellReuseIdentifier:@"GC_CommonSelectCell"];
    
    self.tableView.backgroundColor = [UIColor colorForF5F9FA];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(kNavBarAndStatusBarHeight);
        make.bottom.mas_equalTo(-110);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dataDic = self.dataArr[indexPath.row];
    if (indexPath.row == 1 ||
        indexPath.row == 2 ||
        indexPath.row == 3) {
        GC_CommonSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_CommonSelectCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.dataDic = dataDic;
        return cell;
    }
    
    GC_CommonInputCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_CommonInputCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.dataDic = dataDic;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)saveAction{
    [self.navigationController popViewControllerAnimated:YES];
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
