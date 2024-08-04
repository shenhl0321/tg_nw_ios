//
//  FriendCycleDeatilVC.m
//  GoChat
//
//  Created by 吴亮 on 2021/10/2.
//

#import "FriendCycleDeatilVC.h"
#import "FriendCycleCell.h"
#import "ReplyCell.h"

#import "ReplyCycleViewController.h"

@interface FriendCycleDeatilVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * replyArr;
@end

@implementation FriendCycleDeatilVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"动态详情".lv_localized;
    self.replyArr = @[@"",@"",@"",@"",@"",@"",@""].mutableCopy;
    [self buildUI];
}

-(void)buildUI{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    else{
        return self.replyArr.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        FriendCycleCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCycleCell"];
        if (cell == nil) {
            cell = [[FriendCycleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FriendCycleCell"];
        }
        [cell setModel:@{}];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else{
        ReplyCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ReplyCell"];
        if (cell == nil) {
            cell = [[ReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ReplyCell"];
        }
        [cell setModel:@{}];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return  cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 430;
    }else{
//        return 200;
        CGSize size = [CZCommonTool boundingRectWithString:@"这是哪里风景好漂亮啊！".lv_localized withFont:14 withWidth:(SCREEN_WIDTH-15-10-34-15)];
        return size.height+15+10+10+10+10+15;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.01f)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 40;
    }else{
        return 0.01f;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        footerView.backgroundColor = [UIColor whiteColor];
        UIButton * addReplayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addReplayBtn.frame = CGRectMake(15, 0, SCREEN_WIDTH-30,40);
        addReplayBtn.backgroundColor = HEX_COLOR(@"#F2F2F2");
        [addReplayBtn setTitle:@"添加评论".lv_localized forState:UIControlStateNormal];
        [addReplayBtn setTitleColor:HEX_COLOR(@"#999999") forState:UIControlStateNormal];
        addReplayBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        addReplayBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        
        [footerView addSubview:addReplayBtn];
        return footerView;
    }else{
        return [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.01)];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        ReplyCycleViewController * replyVC = [[ReplyCycleViewController alloc] init];
        [self.navigationController showViewController:replyVC sender:nil];
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
