//
//  ReplyCycleViewController.m
//  GoChat
//
//  Created by 吴亮 on 2021/10/3.
//

#import "ReplyCycleViewController.h"
#import "ReplyCell.h"
#import "ChatToolView.h"
@interface ReplyCycleViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * replayArr;

@property (nonatomic, strong) ChatToolView * chatToolView;

@end

@implementation ReplyCycleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"评论".lv_localized;
    self.replayArr = @[@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@""].mutableCopy;
    [self buildUI];
}
-(void)buildUI{
    
    self.chatToolView = [[ChatToolView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.chatToolView];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.01f)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.01f)];
    [self.view addSubview:self.tableView];
    
    int padding = 0;
    if (Is_iPhoneX) {
        padding = 20;
    }
    [self.chatToolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-padding);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@60);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.bottom.equalTo(self.chatToolView.mas_top);
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.replayArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ReplyCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ReplyCell"];
    if (cell == nil) {
        cell = [[ReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ReplyCell"];
    }
    
    [cell setModel:@{}];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size = [CZCommonTool boundingRectWithString:@"这是哪里风景好漂亮啊！".lv_localized withFont:14 withWidth:(SCREEN_WIDTH-15-10-34-15)];
    return size.height+15+10+10+10+10+15;
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
