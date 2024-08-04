//
//  CZSedRegisterViewController.m
//  GoChat
//
//  Created by mac on 2021/6/30.
//

#import "QTChangeLoginPasswordVC.h"
#import "CZRegisterBtnView.h"
#import "CZChoiceCountyTableViewCell.h"
#import "QTChangeLoginPasswordCell.h"
#import "CZRegisterInputModel.h"
#import "CountryCodeViewController.h"
#import "InputSmsVerificationCodeViewController.h"
#import "InputNicknameViewController.h"
#import "QTChangeLoginPasswordHeadView.h"

@interface QTChangeLoginPasswordVC ()
@property   (weak, nonatomic) IBOutlet UITableView *mainTableview;
@property   (nonatomic,strong) NSMutableArray *placeHodlerArray;
@property (nonatomic, strong)UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (strong, nonatomic) QTChangeLoginPasswordHeadView *footView;


@end

@implementation QTChangeLoginPasswordVC

- (NSMutableArray *)placeHodlerArray{
    if (!_placeHodlerArray) {
        _placeHodlerArray = [NSMutableArray array];
        if (self.hasPwd) {
            [_placeHodlerArray addObject:[CZRegisterInputModel initWithPlaceHodlerStr:@"请输入原密码".lv_localized withtitleStr:@"原密码".lv_localized withFieldTag:100]];
            [_placeHodlerArray addObject:[CZRegisterInputModel initWithPlaceHodlerStr:@"请输入新密码".lv_localized withtitleStr:@"新密码".lv_localized withFieldTag:101]];
            [_placeHodlerArray addObject:[CZRegisterInputModel initWithPlaceHodlerStr:@"请再次输入新密码".lv_localized withtitleStr:@"确认密码".lv_localized withFieldTag:102]];
        }else{
            [_placeHodlerArray addObject:[CZRegisterInputModel initWithPlaceHodlerStr:@"请输入登录密码".lv_localized withtitleStr:@"登录密码".lv_localized withFieldTag:101]];
            [_placeHodlerArray addObject:[CZRegisterInputModel initWithPlaceHodlerStr:@"请再次输入登录密码".lv_localized withtitleStr:@"确认密码".lv_localized withFieldTag:102]];
        }
        
    }
    return _placeHodlerArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.hasPwd) {
        self.titleLab.text = @"修改登录密码".lv_localized;
//        [self.customNavBar setTitle:@"重置登录密码".lv_localized];
    }else{
        self.titleLab.text = @"设置登录密码".lv_localized;
//        [self.customNavBar setTitle:@"设置登录密码".lv_localized];
    }
    self.footView.confirmBtn.alpha = 0.6;
    self.customNavBar.hidden = YES;
    self.contentView.hidden = YES;
    self.mainTableview.tableFooterView = self.footView;
//    self.mainTableview.tableFooterView = [CZRegisterBtnView instanceViewWithBtnTitle:@"确定".lv_localized WithClick:^{
//        [self registerBtnClick];
//    }];
    
//    [self.customNavBar addSubview:self.saveBtn];
//    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-10);
//        make.width.height.mas_equalTo(50);
//        make.bottom.mas_equalTo(0);
//        }];
    // Do any additional setup after loading the view from its nib.
    
}
- (IBAction)buttonClick:(UIButton *)sender {
    if (sender.tag == 1){
        if (self.successBlock){
            self.successBlock();
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (QTChangeLoginPasswordHeadView *)footView{
    if (!_footView){
        _footView = [[NSBundle mainBundle] loadNibNamed:@"QTChangeLoginPasswordHeadView" owner:nil options:nil].firstObject;
        _footView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 150);
        [_footView.confirmBtn addTarget:self action:@selector(registerBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _footView;
}

- (UIButton *)saveBtn{
    if (!_saveBtn) {
        _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveBtn setTitle:@"确定".lv_localized forState:UIControlStateNormal];
        [_saveBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
        _saveBtn.titleLabel.font = [UIFont semiBoldCustomFontOfSize:17];
        [_saveBtn addTarget:self action:@selector(registerBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveBtn;
}
//确定
- (void)registerBtnClick{
    
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    
    if (self.hasPwd) {
        NSString *phonenumer = [self getFieldStrWithTag:100];
        if (!phonenumer || phonenumer.length < 1) {
            [UserInfo showTips:self.view des:@"请输入正确的原密码".lv_localized];
            return;
        }else{
            [paramsDic setObject:[Common md5:phonenumer] forKey:@"old_password"];
//            [paramsDic setObject:phonenumer forKey:@"old_password"];
        }
    }
    
    NSString *userpwd1 = [self getFieldStrWithTag:101];
    NSString *userpwd2 = [self getFieldStrWithTag:102];
    if (userpwd1 && userpwd2 &&  userpwd1.length > 5 && userpwd2.length > 5 && [userpwd1 isEqualToString:userpwd2]) {
//        [paramsDic setObject:[Common md5:userpwd1] forKey:@"new_password"];
        [paramsDic setObject:userpwd1 forKey:@"new_password"];
    }else{
        [UserInfo showTips:self.view des:@"请输入正确的登录密码".lv_localized];
        return;
    }
    
    [UserInfo show];
    MJWeakSelf
    [[TelegramManager shareInstance] changeLoginPaswordWithParams:[CZCommonTool dictionaryToJson:paramsDic] resultBlock:^(NSDictionary *request, NSDictionary *response, id obj){
        [UserInfo dismiss];
        if(obj){
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if (weakSelf.hasPwd) {
                    [UserInfo showTips:weakSelf.view des:@"修改登录密码成功".lv_localized];
                }else{
                    [UserInfo showTips:weakSelf.view des:@"设置登录密码成功".lv_localized];
                }
                if (weakSelf.successBlock){
                    weakSelf.successBlock();
                }
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }else if([obj isKindOfClass:[NSString class]]){
                [UserInfo showTips:weakSelf.view des:obj];
            }
        }else{
            [UserInfo showTips:self.view des:@"设置登录密码失败，请重试".lv_localized];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        NSLog(@"sendCode timeout......");
        [UserInfo showTips:self.view des:@"请求超时，请检查网络是否正常".lv_localized];
    }];
    
}

- (NSString *)getFieldStrWithTag:(NSInteger)tag{
    for (UITableViewCell *cell in self.mainTableview.visibleCells) {
        if (cell.tag == tag) {
            if ([cell isMemberOfClass:[QTChangeLoginPasswordCell class]]) {
                QTChangeLoginPasswordCell *cellLim = (QTChangeLoginPasswordCell *)cell;
                return cellLim.inputString;
            }
        }
    }
    return nil;
}

//设置TablerView显示几组数据，默认分一组；
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//设置UITabView每组显示几行数据
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.placeHodlerArray.count;
}
//设置每一行的每一组显示单元格的什么内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CZRegisterInputModel *cellModel = [self.placeHodlerArray objectAtIndex:indexPath.row];
    NSString *ID = @"QTChangeLoginPasswordCell";
    QTChangeLoginPasswordCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"QTChangeLoginPasswordCell" owner:nil options:nil] firstObject];
    }
    cell.cellModel = cellModel;
    [cell.inputField addTarget:self action:@selector(textFieldChange) forControlEvents:UIControlEventEditingChanged];
    return cell;
}
- (void)textFieldChange{
    NSString *string01 = @"";
    NSString *string02 = @"";
    NSString *string03 = @"";
    string02 = [self getFieldStrWithTag:101];
    string03 = [self getFieldStrWithTag:102];
    if (self.hasPwd){
        string01 = [self getFieldStrWithTag:100];
        
        if (!IsStrEmpty(string01) && !IsStrEmpty(string02) && !IsStrEmpty(string03)){
            self.footView.confirmBtn.enabled = YES;
            self.footView.confirmBtn.alpha = 1;
        }else{
            self.footView.confirmBtn.enabled = NO;
            self.footView.confirmBtn.alpha = 0.6;
        }
    }else{
        if (!IsStrEmpty(string02) && !IsStrEmpty(string03)){
            self.footView.confirmBtn.enabled = YES;
            self.footView.confirmBtn.alpha = 1;
        }else{
            self.footView.confirmBtn.enabled = NO;
            self.footView.confirmBtn.alpha = 0.6;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
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
