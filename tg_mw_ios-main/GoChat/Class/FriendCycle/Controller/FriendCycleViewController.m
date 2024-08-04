//
//  FrindCycleViewController.m
//  GoChat
//
//  Created by 吴亮 on 2021/10/2.
//

#import "FriendCycleViewController.h"
#import "FriendCycleCell.h"
#import "FriendCycleDeatilVC.h"
#import "TimelineInfoVC.h"
#import "CreateFriendCycleVC.h"
#import "PublishTimelineVC.h"
#import "CycleMainViewController.h"
#import "WFPopViewController.h"

#import "FriendCycleHelper.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"

@interface FriendCycleViewController ()<UITableViewDelegate,UITableViewDataSource,UIPopoverPresentationControllerDelegate>
@property (nonatomic, strong) UIButton * hotBtn;
@property (nonatomic, strong) UIButton * focusBtn;
@property (nonatomic, strong) UIButton * friendBtn;
@property (nonatomic, strong) UIView * headerView;

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) NSMutableArray * dataArr;

@property (nonatomic, strong) UIButton * mainViewBtn;

@property (nonatomic, assign) FriendCycleType selectedType;

@end

@implementation FriendCycleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataArr = NSMutableArray.array;
    
    [self buildTitleView];
    [self buildUI];
    
    self.mainViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.mainViewBtn.frame = CGRectMake(SCREEN_WIDTH-70, SCREEN_HEIGHT/3*2, 60, 60);
    self.mainViewBtn.layer.masksToBounds = YES;
    self.mainViewBtn.layer.cornerRadius = 30;
    [self.mainViewBtn setImage:[UIImage imageNamed:@"home_page"] forState:UIControlStateNormal];
    [self.mainViewBtn addTarget:self action:@selector(mainViewBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.mainViewBtn];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.headerView.frame = self.navigationItem.titleView.frame;
    CGFloat width = self.headerView.frame.size.width/3;
    self.hotBtn.frame = CGRectMake(0, 0, width, 44);
    self.focusBtn.frame = CGRectMake(width, 0, width, 44);
    self.friendBtn.frame = CGRectMake(2*width, 0, width, 44);
}

- (void)buildTitleView{
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 44, 44);
    [rightBtn setImage:[UIImage imageNamed:@"new_Cycle"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-100, 44)];
    self.headerView.layer.borderWidth = 1;
    self.headerView.layer.borderColor = HEX_COLOR(@"#00C69B").CGColor;
    self.headerView.layer.masksToBounds = YES;
    self.headerView.layer.cornerRadius = 5;
    self.navigationItem.titleView = self.headerView;
    
    self.hotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.hotBtn setTitle:@"热门".lv_localized forState:UIControlStateNormal];
    [self.hotBtn addTarget:self action:@selector(hotBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.hotBtn];
    
    self.focusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.focusBtn setTitle:@"关注".lv_localized forState:UIControlStateNormal];
    [self.focusBtn addTarget:self action:@selector(focusBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.focusBtn.layer.borderWidth = 1;
    self.focusBtn.layer.borderColor = HEX_COLOR(@"#00C69B").CGColor;
    [self.headerView addSubview:self.focusBtn];
    
    self.friendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.friendBtn setTitle:@"好友".lv_localized forState:UIControlStateNormal];
    [self.friendBtn addTarget:self action:@selector(friendBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.friendBtn];
    
    CGFloat width = self.headerView.frame.size.width/3;
    self.hotBtn.frame = CGRectMake(0, 0, width, 44);
    self.focusBtn.frame = CGRectMake(width, 0, width, 44);
    self.friendBtn.frame = CGRectMake(2*width, 0, width, 44);
    
    [self hotBtnClick];
    
}

-(void)buildUI{
    self.view.backgroundColor = [UIColor orangeColor];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.01)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.01)];
    [self.view addSubview:self.tableView];
    
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(self.view);
    }];
}
#pragma mark rightItemClick
-(void)rightItemClick{
    PublishTimelineVC * createVC = [[PublishTimelineVC alloc] init];
    [self.navigationController showViewController:createVC sender:nil];
}
#pragma mark - headerViewClick

-(void)hotBtnClick{
    [self selectBtn:self.hotBtn];
    [self unSelectBtn:self.focusBtn];
    [self unSelectBtn:self.friendBtn];
    self.selectedType = FriendCycleType_Hot;
    [self.dataArr removeAllObjects];
    [self request];
}
-(void)focusBtnClick{
    [self selectBtn:self.focusBtn];
    [self unSelectBtn:self.hotBtn];
    [self unSelectBtn:self.friendBtn];
    self.selectedType = FriendCycleType_Follow;
    [self.dataArr removeAllObjects];
    [self request];
}
-(void)friendBtnClick{
    [self selectBtn:self.friendBtn];
    [self unSelectBtn:self.focusBtn];
    [self unSelectBtn:self.hotBtn];
    self.selectedType = FriendCycleType_Friend;
    [self.dataArr removeAllObjects];
    [self request];
}
-(void)selectBtn:(UIButton *)button{
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = HEX_COLOR(@"00C69B");
}
-(void)unSelectBtn:(UIButton *)button{
    [button setTitleColor:HEX_COLOR(@"00C69B") forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
}

#pragma mark TableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BlogInfo *blog = _dataArr[indexPath.row];
    return [FriendCycleCell hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
        FriendCycleCell *cell = (FriendCycleCell *)sourceCell;
        cell.blog = blog;
    } cache:^NSDictionary *{
        return @{kHYBCacheUniqueKey: @(blog.ids), kHYBCacheStateKey: @(blog.ids)};
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendCycleCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (cell == nil) {
        cell = [[FriendCycleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
    }
    [cell.moreBtn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.moreBtn.tag = indexPath.row;
    cell.blog = _dataArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TimelineInfoVC *detailVC = [[TimelineInfoVC alloc] init];
    detailVC.blog = _dataArr[indexPath.row];
    [self.navigationController showViewController:detailVC sender:nil];
}

-(void)mainViewBtnClick{
    CycleMainViewController * mainVC = [[CycleMainViewController alloc] init];
    [self.navigationController showViewController:mainVC sender:nil];
}

-(void)moreBtnClick:(UIButton *)button{
    WFPopViewController *viewVC = [[WFPopViewController alloc] init];
    viewVC.preferredContentSize =CGSizeMake(150,100);
    viewVC.modalPresentationStyle =UIModalPresentationPopover;
    UIPopoverPresentationController *popVC = viewVC.popoverPresentationController;
    popVC.delegate =self;
    // 气泡依附于哪个view弹出
    popVC.sourceView = button;
    // 气泡从哪个位置弹出，是以按钮的上边中心点即（sender.width/2，0）为坐标原点。
    popVC.sourceRect = CGRectMake(0, button.frame.size.height,0, 0);
    // > 箭头的指向（上，下，左，右）
    popVC.permittedArrowDirections = UIPopoverArrowDirectionUp;
    [self presentViewController:viewVC animated:YES completion:nil];
}
-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    // 此处为不适配(如果选择其他,会自动视频屏幕,上面设置的大小就毫无意义了)
    return UIModalPresentationNone;

}

- (void)request {
//    return;
    [FriendCycleHelper queryCycleList:self.selectedType offset:1 completion:^(NSArray<BlogInfo *> * _Nonnull blogs) {
        [self.dataArr addObjectsFromArray:blogs];
        [self.tableView reloadData];
    }];
}


@end
