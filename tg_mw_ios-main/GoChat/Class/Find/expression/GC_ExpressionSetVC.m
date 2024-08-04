//
//  GC_ExpressionSetVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/15.
//

#import "GC_ExpressionSetVC.h"
#import "GC_ExpressionCell.h"
#import "GC_ExpressionTitleCell.h"
#import "GC_ExpressionDetailVC.h"

@interface GC_ExpressionSetVC ()

@end

@implementation GC_ExpressionSetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:@"表情管理".lv_localized];
    [self initUI];
    // Do any additional setup after loading the view.
}
    
- (void)initUI{

    [self.view addSubview:self.tableView];
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
        cell.titleLab.text = @"聊天面板中的表情".lv_localized;
        return cell;
    }
    
    GC_ExpressionCell * cell = [tableView dequeueReusableCellWithIdentifier:@"GC_ExpressionCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setFollowStatus:YES];
    [cell.addBtn setTitle:@"移除".lv_localized forState:UIControlStateNormal];
    [cell.addBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
