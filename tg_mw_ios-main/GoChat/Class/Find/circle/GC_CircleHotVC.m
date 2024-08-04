//
//  GC_CircleHotVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/15.
//

#import "GC_CircleHotVC.h"
#import "GC_CircleListCell.h"

#import "GC_CircleDetailVC.h"

@interface GC_CircleHotVC ()

@end

@implementation GC_CircleHotVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self initUI];
}

- (void)initUI{
    self.customNavBar.hidden = YES;
    self.contentView.hidden = YES;
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[GC_CircleListCell class] forCellReuseIdentifier:@"GC_CircleListCell"];
   
    
    self.tableView.backgroundColor = [UIColor colorForF5F9FA];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(0);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (GC_CircleListCell *)extracted:(UITableView * _Nonnull)tableView {
    GC_CircleListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_CircleListCell"];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    GC_CircleListCell * cell = [self extracted:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 460.;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GC_CircleDetailVC *vc = [[GC_CircleDetailVC alloc] init];
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
