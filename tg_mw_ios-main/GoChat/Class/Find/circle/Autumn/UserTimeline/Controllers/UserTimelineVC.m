//
//  UserTimelineVC.m
//  GoChat
//
//  Created by Autumn on 2021/12/15.
//

#import "UserTimelineVC.h"
#import "TimelineInfoVC.h"
#import "TimelineUserFollowsVC.h"

#import "UserTimelineNaviView.h"
#import "UserTimelineInfoCell.h"
#import "UserTimelineStatisticsCell.h"
#import "UserTimelineMediaCell.h"
#import "UserTimelineEditCell.h"

#import "UserTimelineHelper.h"
#import "UserinfoHelper.h"
#import "GC_MyInfoVC.h"

@interface UserTimelineVC ()<BusinessListenerProtocol>

@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) UserTimelineNaviView *naviView;

@property (nonatomic, assign) NSInteger userid;
/// <#code#>
@property (nonatomic, strong) UserInfo *userInfo;
@end

@implementation UserTimelineVC

- (void)dealloc {
    [BusinessFramework.defaultBusinessFramework unregisterBusinessListener:self];
}

- (instancetype)initWithUserid:(NSInteger)userid {
    if (self = [super init]) {
        self.userid = userid;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    
    [self reloadBlogUserinfo];
    [_naviView reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.width.mas_equalTo(kScreenWidth());
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo((160 + kStatusBarHeights()));
    }];
}

- (void)dy_initData {
    [super dy_initData];
    self.addLoadFooter = YES;
    [self dy_configureData];
    [BusinessFramework.defaultBusinessFramework registerBusinessListener:self];
    [self getUserInfo];
}

- (void)dy_initUI {
    [super dy_initUI];
    UIEdgeInsets inset = UIEdgeInsetsMake(160 + kStatusBarHeights(), 0, 0, 0);
    self.collectionView.contentInset = inset;
    self.collectionView.scrollIndicatorInsets = inset;
    _topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_banner_place"]];
    [self.collectionView addSubview:_topImageView];
    
    [self.collectionView xhq_registerCell:UserTimelineInfoCell.class];
    [self.collectionView xhq_registerCell:UserTimelineStatisticsCell.class];
    [self.collectionView xhq_registerCell:UserTimelineEditCell.class];
    [self.collectionView xhq_registerCell:UserTimelineMediaCell.class];
    
    _naviView = [[UserTimelineNaviView alloc] initWithUserid:self.userid];
    [self.view addSubview:_naviView];
    [self.view bringSubviewToFront:_naviView];
    
    UIView *topView = [UIView new];
    topView.backgroundColor = [UIColor whiteColor];
    topView.clipsToBounds = YES;
    topView.layer.cornerRadius = 20;
    [self.topImageView addSubview:topView];
    
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(20);
        make.height.mas_equalTo(40);
    }];
    
}

- (void)dy_request {
    [self reloadBlogs];
}

- (void)reloadBlogs {
    [UserTimelineHelper fetchUserBlogs:self.userid offset:self.currentPage.intValue completion:^(NSArray<BlogInfo *> * _Nonnull blogs) {
        NSMutableArray *items = self.dataArray.lastObject;
        if (self.isDropdownRefresh) {
            [items removeAllObjects];
        }
        self.totalPage = blogs.count == 20 ? [NSString stringWithFormat:@"%ld", self.currentPage.integerValue + 1] : self.currentPage;
        for (BlogInfo *blog in blogs) {
            UserTimelineMediaCellItem *item = UserTimelineMediaCellItem.item;
            item.cellModel = blog;
            [items addObject:item];
        }
        
        [self dy_collectionViewReloadData];
    }];
}

- (void)reloadBlogUserinfo {
    [UserTimelineHelper fetchBlogUserinfo:self.userid completion:^(BlogUserInfo * _Nonnull info) {
        NSMutableArray *items = NSMutableArray.array;
        UserTimelineStatisticsCellItem *sItem = UserTimelineStatisticsCellItem.item;
        sItem.type = UserTimelineStatisticsType_Blogs;
        sItem.number = info.blogs;
        [items addObject:sItem];
        
        sItem = UserTimelineStatisticsCellItem.item;
        sItem.type = UserTimelineStatisticsType_Followed;
        sItem.number = info.follows;
        [items addObject:sItem];
        
        sItem = UserTimelineStatisticsCellItem.item;
        sItem.type = UserTimelineStatisticsType_Followers;
        sItem.number = info.fans;
        [items addObject:sItem];
        
        sItem = UserTimelineStatisticsCellItem.item;
        sItem.type = UserTimelineStatisticsType_Liked;
        sItem.number = info.likes;
        [items addObject:sItem];
        [self.dataArray replaceObjectAtIndex:1 withObject:items];
        [UIView setAnimationsEnabled:NO];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
        [UIView setAnimationsEnabled:YES];
    }];
    
    [UserTimelineHelper fetchUserDesc:self.userid completion:^(NSString * _Nonnull desc) {
        NSMutableArray *items = self.dataArray.firstObject;
        UserTimelineInfoCellItem *item = items.firstObject;
        item.desc = desc;
        [UIView setAnimationsEnabled:NO];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        [UIView setAnimationsEnabled:YES];
    }];
    [UserinfoHelper getUserExtInfo:self.userid completion:^(UserInfoExt * _Nonnull ext) {
        NSMutableArray *items = self.dataArray.firstObject;
        UserTimelineInfoCellItem *item = items.firstObject;
        item.ext = ext;
        [UIView setAnimationsEnabled:NO];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        [UIView setAnimationsEnabled:YES];
    }];
    
}

- (void)dy_load {
    NSMutableArray *items = self.dataArray.lastObject;
    UserTimelineMediaCellItem *item = items.lastObject;
    if (item) {
        BlogInfo *blog = (BlogInfo *)item.cellModel;
        self.currentPage = [NSString stringWithFormat:@"%ld", blog.ids];
        [self dy_request];
    }
}

- (void)getUserInfo{
    [[TelegramManager shareInstance] requestContactInfo:self.userid resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:UserInfo.class])
        {
            UserInfo *user = obj;
            // 自己
            if(self.userid != [UserInfo shareInstance]._id)
            {
                self.userInfo = user;
                
            }
            
        }
        
    } timeout:^(NSDictionary *request) {
        
    }];
}

- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam {
    int makeId = MakeID(EUserManager, EUser_Timeline_UnReadMessage);
    if (notifcationId != makeId) {
        return;
    }
    [_naviView reloadData];
}

- (void)dy_cellResponse:(__kindof DYCollectionViewCellItem *)item indexPath:(NSIndexPath *)indexPath {
    [UIView setAnimationsEnabled:NO];
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    [UIView setAnimationsEnabled:YES];
}

#pragma mark - ConfigureData
- (void)dy_configureData {
    NSMutableArray *items = NSMutableArray.array;
    UserTimelineInfoCellItem *iItem = UserTimelineInfoCellItem.item;
    iItem.userid = self.userid;
    [items addObject:iItem];
    [self.dataArray addObject:items];
    
    items = NSMutableArray.array;
    UserTimelineStatisticsCellItem *sItem = UserTimelineStatisticsCellItem.item;
    sItem.type = UserTimelineStatisticsType_Blogs;
    [items addObject:sItem];
    
    sItem = UserTimelineStatisticsCellItem.item;
    sItem.type = UserTimelineStatisticsType_Followed;
    [items addObject:sItem];
    
    sItem = UserTimelineStatisticsCellItem.item;
    sItem.type = UserTimelineStatisticsType_Followers;
    [items addObject:sItem];
    
    sItem = UserTimelineStatisticsCellItem.item;
    sItem.type = UserTimelineStatisticsType_Liked;
    [items addObject:sItem];
    [self.dataArray addObject:items];
    
    items = NSMutableArray.array;
    UserTimelineEditCellItem *eItem = UserTimelineEditCellItem.item;
    eItem.userid = self.userid;
    [items addObject:eItem];
    [self.dataArray addObject:items];
    
    items = NSMutableArray.array;
    [self.dataArray addObject:items];
}

#pragma mark - method
- (void)editCellSelected {
    if (self.userid == UserInfo.shareInstance._id) {
        GC_MyInfoVC *vc = [[GC_MyInfoVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (![self canSendMsg]) {
        [UserInfo showTips:nil des:@"加好友后才能聊天".lv_localized];
        return;
    }
    if ([[TelegramManager shareInstance] contactInfo:self.userid] != nil) {
        [[TelegramManager shareInstance] createPrivateChat:self.userid resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if (obj != nil && [obj isKindOfClass:ChatInfo.class]) {
               
                [AppDelegate gotoChatView:obj];
            }
        } timeout:^(NSDictionary *request) {}];
    } else {
        [UserInfo show];
        [[TelegramManager shareInstance] requestContactInfo:self.userid resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            [UserInfo dismiss];
            [[TelegramManager shareInstance] createPrivateChat:self.userid resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                if (obj != nil && [obj isKindOfClass:ChatInfo.class]) {
                
                    [AppDelegate gotoChatView:obj];
                }
            } timeout:^(NSDictionary *request) {}];
        } timeout:^(NSDictionary *request) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"请求超时，请稍后重试".lv_localized];
        }];
    }
}

- (BOOL)canSendMsg
{
    if(self.userInfo.is_contact)
    {//已经是好友的，不受任何影响
        return YES;
    }
    AppConfigInfo *info = [AppConfigInfo getAppConfigInfo];
    if(info != nil)
    {
        if(info.onlyFriendChat)
        {//加好友才能聊天
            return self.userInfo.is_contact;
        }
        if(info.onlyWhiteAddFriend)
        {
            return NO;
        }
    }
    return YES;
}

- (void)followsController:(UserTimelineStatisticsCellItem *)item {
    if (item.type == UserTimelineStatisticsType_Blogs || item.type == UserTimelineStatisticsType_Liked) {
        MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示".lv_localized
                                                        detail:item.alertMessage
                                                         items:@[MMItemMake(@"确定".lv_localized, MMItemTypeNormal, nil)]];
        [view show];
        return;
    }
    TimelineUserFollowsVC *follow = [[TimelineUserFollowsVC alloc] init];
    follow.userid = self.userid;
    if (item.type == UserTimelineStatisticsType_Followers) {
        follow.selectIndex = 1;
    } else {
        follow.selectIndex = 0;
    }
    [self.navigationController pushViewController:follow animated:YES];
}


- (void)blogInfoController:(BlogInfo *)blog {
    TimelineInfoVC *info = [[TimelineInfoVC alloc] init];
    info.blog = blog;
    [self.navigationController pushViewController:info animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_naviView bindScrollView:scrollView];
}

#pragma mark - UICollectionViewDataSource

#pragma mark - UICollectionViewDelegate
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if ([[self.dataArray[section] firstObject] isKindOfClass:UserTimelineMediaCellItem.class]) {
        return 10;
    }
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if ([[self.dataArray[section] firstObject] isKindOfClass:UserTimelineMediaCellItem.class]) {
        return 10;
    }
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    DYCollectionViewCellItem *item = [self.dataArray[section] firstObject];
    if ([item isKindOfClass:UserTimelineMediaCellItem.class]) {
        return UIEdgeInsetsMake(25, 15, 20, 15);
    } else if ([item isKindOfClass:UserTimelineEditCellItem.class]) {
               return UIEdgeInsetsMake(0, 15, 0, 15);
           }
    return UIEdgeInsetsZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DYCollectionViewCellItem *item = self.dataArray[indexPath.section][indexPath.item];
    if ([item isKindOfClass:UserTimelineEditCellItem.class]) {
        [self editCellSelected];
        return;
    }
    if ([item isKindOfClass:UserTimelineStatisticsCellItem.class]) {
        [self followsController:(UserTimelineStatisticsCellItem *)item];
        return;
    }
    if ([item isKindOfClass:UserTimelineMediaCellItem.class]) {
        [self blogInfoController:(BlogInfo *)item.cellModel];
        return;
    }
}

@end
