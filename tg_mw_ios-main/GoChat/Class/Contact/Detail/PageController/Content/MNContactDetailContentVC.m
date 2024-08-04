//
//  MNContactDetailContentVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/20.
//

#import "MNContactDetailContentVC.h"
#import "TF_RequestManager.h"
#import "UIViewController+WMPageController.h"

@interface MNContactDetailContentVC ()
@property (nonatomic, assign) CGFloat mnContentHeight;
//@property (nonatomic, assign) CGPoint lastPoint;
@property(nonatomic,assign)BOOL canScroll;

@end

@implementation MNContactDetailContentVC

- (instancetype)initWithUser:(UserInfo *)user type:(NSInteger)type
{
    self = [super init];
    if (self) {
        self.userInfo = user;
        self.type = type;
        _startId = 0;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.isHistory) {
        [self.customNavBar removeFromSuperview];
    }
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    _dataArray = [[NSMutableArray alloc] init];
    WS(weakSelf)
    [self initDataComplete:^{
        [weakSelf initDataCompleteFunc];
    } loadMore:NO];
    self.tableView.mj_footer = [self addFooterRefresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:NotifyGoToTopNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:NotifyLeaveTopNotification object:nil];
}


#pragma mark - collectionView -
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(20, 15, 20, 15);
        flowLayout.minimumLineSpacing = 9;
        flowLayout.minimumInteritemSpacing = 9;
        NSInteger count = 3;
        CGFloat itemWidth = floorf((APP_SCREEN_WIDTH - 2*15 - 9*(count-1))/count);
        flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
       
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, 100) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.delaysContentTouches = false;
//        _collectionView.bounces = NO;
      
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

- (void)refreshConetentViewWithHeight:(CGFloat)height{
    self.mnContentHeight = height;
    self.contentView.frame = CGRectMake(0, 0, APP_SCREEN_WIDTH, height);
}

- (void)initDataComplete:(NullBlock)complete loadMore:(BOOL)loadMore{
    long chatId = self.isHistory ? self.chatId : self.userInfo._id;
    NSString *userid = [NSString stringWithFormat:@"%ld", self.userInfo._id];
    if (self.isHistory) {
        userid = nil;
    }
    WS(weakSelf)
    [TF_RequestManager searchChatMessagesWithType:self.type userId:userid startId:self.startId chatId:chatId resultBlock:^(NSDictionary *request, NSDictionary *response, NSMutableArray *obj) {
        if (loadMore == NO) {
            [weakSelf.dataArray removeAllObjects];
        }
        [weakSelf.dataArray addObjectsFromArray:obj];
        if (complete) {
            complete();
        }
    } timeout:^(NSDictionary *request) {
        if (complete) {
            complete();
        }
        
    }];

}

- (void)initDataCompleteFunc{
    [self.tableView.mj_footer endRefreshing];
}

- (void)loadMoreData{
    WS(weakSelf)
    if (self.dataArray.count<1) {
        [self initDataCompleteFunc];
        return;
    }
    MessageInfo *message = self.dataArray[self.dataArray.count];
    if (message._id == self.startId) {
        [self initDataCompleteFunc];
        return;
    }
    self.startId = message._id;
    [self initDataComplete:^{
        [weakSelf initDataCompleteFunc];
    } loadMore:YES];
}

- (MJRefreshAutoNormalFooter *)addFooterRefresh{
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
//    [footer setTitle:@"上拉加载更多" forState:MJRefreshStateIdle];
//    [footer setTitle:@"正在刷新..." forState:MJRefreshStateRefreshing];
//    [footer setTitle:@"没有更多数据" forState:MJRefreshStateNoMoreData];
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在刷新...".lv_localized forState:MJRefreshStateRefreshing];
    [footer setTitle:@"" forState:MJRefreshStateNoMoreData];

    footer.triggerAutomaticallyRefreshPercent = 0.5;
    return footer;
}

#pragma mark - notification
-(void)acceptMsg:(NSNotification *)notification {
    NSString *notificationName = notification.name;
    if ([notificationName isEqualToString:NotifyGoToTopNotification]) {
        NSDictionary *userInfo = notification.userInfo;
        NSString *canScroll = userInfo[@"canScroll"];
        if ([canScroll isEqualToString:@"1"]) {
            self.canScroll = YES;
            self.collectionView.showsVerticalScrollIndicator = YES;
            self.tableView.showsVerticalScrollIndicator = YES;
        }
    }else if([notificationName isEqualToString:NotifyLeaveTopNotification]){
        self.collectionView.contentOffset = CGPointZero;
        self.tableView.contentOffset = CGPointZero;
        self.canScroll = NO;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.tableView.showsVerticalScrollIndicator = NO;
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.isHistory) {
        return;
    }
    if (!self.canScroll) {
        [scrollView setContentOffset:CGPointZero];
    }
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY < 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NotifyLeaveTopNotification object:nil userInfo:@{@"canScroll":@"1"}];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
