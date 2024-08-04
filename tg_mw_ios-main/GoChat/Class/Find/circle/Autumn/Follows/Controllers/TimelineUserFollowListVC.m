//
//  TimelineUserFollowListVC.m
//  GoChat
//
//  Created by Autumn on 2021/12/16.
//

#import "TimelineUserFollowListVC.h"
#import "UserTimelineVC.h"

#import "TimelineUserFollowHelper.h"
#import "UserinfoHelper.h"

#import "TimelineUserFollowCell.h"

@interface TimelineUserFollowListVC ()<BusinessListenerProtocol>

@property (nonatomic, strong) NSMutableArray<BlogUserDate *> *userDates;
@property (nonatomic, strong) NSMutableArray<NSString *> *usernames;

@end

@implementation TimelineUserFollowListVC

- (void)dealloc {
    [BusinessFramework.defaultBusinessFramework unregisterBusinessListener:self];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)dy_initData {
    [super dy_initData];
    [self.dataArray addObject:self.sectionArray0];
    [BusinessFramework.defaultBusinessFramework registerBusinessListener:self];
    self.emptyTitle = self.type == TimelineUserFollowType_Fans ? @"暂无粉丝".lv_localized : @"暂无关注用户".lv_localized;
}

- (void)dy_initUI {
    [super dy_initUI];
    
    [self.tableView xhq_registerCell:TimelineUserFollowCell.class];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth(), 13)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth(), 13)];
}

- (void)dy_request {
    if (self.type == TimelineUserFollowType_Follows) {
        [TimelineUserFollowHelper fetchUserFollows:self.userid completion:^(NSArray<BlogUserDate *> * _Nonnull users) {
            self.userDates = users.mutableCopy;
            [self fetchUserinfos:^{
                [self dy_configureData];
            }];
        }];
    } else {
        [TimelineUserFollowHelper fetchUserFans:self.userid completion:^(NSArray<BlogUserDate *> * _Nonnull users) {
            self.userDates = users.mutableCopy;
            [self fetchUserinfos:^{
                [self dy_configureData];
            }];
        }];
    }
}



#pragma mark - ConfigureData
- (void)dy_configureData {
    [self.sectionArray0 removeAllObjects];
    [self.userDates enumerateObjectsUsingBlock:^(BlogUserDate * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.keyword && self.keyword.length > 0 && ![self.usernames[idx].lowercaseString containsString:self.keyword.lowercaseString]) {
            return;
        }
        TimelineUserFollowCellItem *item = TimelineUserFollowCellItem.item;
        item.cellModel = obj;
        item.userid = self.userid;
        [self.sectionArray0 addObject:item];
    }];
    [self dy_tableViewReloadData];
}

- (void)dy_configureDataWithModel:(DYModel *)model {
    TimelineUserFollowCellItem *item = TimelineUserFollowCellItem.item;
    item.cellModel = model;
    item.userid = self.userid;
    [self.sectionArray0 addObject:item];
}

#pragma mark - Noti
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam {
    int notiId = MakeID(EUserManager, EUser_Timeline_Follows_Change);
    if (notifcationId != notiId) {
        return;
    }
    [self dy_refresh];
}


#pragma mark - Method
- (void)fetchUserinfos:(dispatch_block_t)completion {
    NSMutableArray *ids = NSMutableArray.array;
    [self.userDates enumerateObjectsUsingBlock:^(BlogUserDate * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [ids addObject:@(obj.user_id)];
    }];
    if (ids.count == 0) {
        !completion ? : completion();
        return;
    }
    [UserinfoHelper getUsernames:ids completion:^(NSArray * _Nonnull names) {
        self.usernames = names.mutableCopy;
        !completion ? : completion();
    }];
}

#pragma mark - JXCategoryListContentViewDelegate
- (UIView *)listView {
    return self.view;
}

#pragma mark - UITableViewDataSource

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TimelineUserFollowCellItem *item = self.dataArray[indexPath.section][indexPath.row];
    BlogUserDate *user = (BlogUserDate *)item.cellModel;
    UserTimelineVC *timeline = [[UserTimelineVC alloc] initWithUserid:user.user_id];
    [self.navigationController pushViewController:timeline animated:YES];
}

#pragma mark - setter
- (void)setKeyword:(NSString *)keyword {
    _keyword = keyword;
    if (self.usernames.count == 0) {
        return;
    }
    [self dy_configureData];
}

@end
