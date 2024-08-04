//
//  TimelineInfoVC.m
//  GoChat
//
//  Created by Autumn on 2021/11/19.
//

#import "TimelineInfoVC.h"
#import "TimelineReplyVC.h"
#import "TimelineInfoReplyCell.h"
#import "TimelineInfoRepayFooterView.h"
#import "TimelineListCell.h"
#import "TimelineCommentView.h"
#import "IQKeyboardManager.h"

#import "TimelineHelper.h"
#import "BlogInfo.h"
#import "GC_CommentFooterView.h"
#import "TF_TimeVideoBrowseVC.h"
@interface TimelineInfoVC ()<BusinessListenerProtocol>

@property (nonatomic, strong) TimelineCommentView *commentView;

@end

@implementation TimelineInfoVC

- (void)dealloc {
    [BusinessFramework.defaultBusinessFramework unregisterBusinessListener:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    IQKeyboardManager.sharedManager.enable = NO;
    IQKeyboardManager.sharedManager.enableAutoToolbar = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    IQKeyboardManager.sharedManager.enable = YES;
    IQKeyboardManager.sharedManager.enableAutoToolbar = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [_commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(@0);
        make.height.equalTo(@60);
        make.top.equalTo(self.tableView.mas_bottom);
    }];
}

- (void)dy_initData {
    [super dy_initData];
    
    [self.customNavBar setTitle:@"动态详情".lv_localized];
    self.style = UITableViewStyleGrouped;
    [self dy_configureData];
}

- (void)dy_initUI {
    [super dy_initUI];
    
    [self.view addSubview:self.commentView];
    [self.tableView xhq_registerCell:TimelineListCell.class];
    [self.tableView xhq_registerCell:TimelineInfoReplyCell.class];
    [self.tableView xhq_registerView:TimelineInfoRepayFooterView.class];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)dy_request {
    [TimelineHelper queryBlogReplys:self.blog.ids offset:0 completion:^(NSArray<BlogReply *> * _Nonnull replys) {
        if (self.isDropdownRefresh) {
            [self.dataArray removeAllObjects];
            [self dy_configureData];
        }
        for (BlogReply *reply in replys) {
            [self dy_configureDataWithModel:reply];
        }
        [self dy_tableViewReloadData];
    }];
}

- (void)subReplyReq:(NSMutableArray *)items {
    NSInteger section = [self.dataArray indexOfObject:items];
    TimelineInfoReplyCellItem *item = items.firstObject;
    BlogReply *reply = (BlogReply *)item.cellModel;
    [TimelineHelper querySubReplys:reply.ids completion:^(NSArray<BlogReply *> * _Nonnull replys) {
        if (replys.count == 0) {
            return;
        }
        item.subRepayNumber = replys.count;
        item.displayMode = RepayListDisplayMode_All;
        for (BlogReply *sub in replys) {
            TimelineInfoReplyCellItem *sItem = TimelineInfoReplyCellItem.item;
            sItem.subRepay = YES;
            sItem.cellModel = sub;
            [items addObject:sItem];
        }
        [UIView setAnimationsEnabled:NO];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
        [UIView setAnimationsEnabled:YES];
    }];
}


#pragma mark - ConfigureData
- (void)dy_configureData {
    NSMutableArray *items = NSMutableArray.array;
    TimelineListCellItem *item = TimelineListCellItem.item;
    item.displayInDetail = YES;
    item.cellModel = self.blog;
    [items addObject:item];
    [self.dataArray addObject:items];
}

- (void)dy_configureDataWithModel:(JWModel *)model {
    NSMutableArray *items = NSMutableArray.array;
    TimelineInfoReplyCellItem *item = TimelineInfoReplyCellItem.item;
    item.displayMode = RepayListDisplayMode_None;
    item.cellModel = model;
    [items addObject:item];
    [self.dataArray addObject:items];
    [self subReplyReq:items];
}


- (void)dy_cellResponse:(__kindof DYTableViewCellItem *)item indexPath:(NSIndexPath *)indexPath {
    if ([item isKindOfClass:TimelineListCellItem.class]) {
        TimelineListCellItem *m = (TimelineListCellItem *)item;
        if (m.response == TimelineResponse_Comment) {
            [self.commentView commentBlog:self.blog.ids];
        } else if (m.response == TimelineResponse_BrowseVideo) {
            TF_TimeVideoBrowseVC *vc = [[TF_TimeVideoBrowseVC alloc] init];
            vc.type = self.type;
            vc.blogs = @[self.blog];
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:nav animated:YES completion:nil];
        }
    } else if ([item isKindOfClass:TimelineInfoReplyCellItem.class]) {
        BlogReply *reply = (BlogReply *)item.cellModel;
        [self.commentView commentReply:reply.ids name:((TimelineInfoReplyCellItem *)item).username];
    }
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    TimelineInfoReplyCellItem *item = [self.dataArray[section] firstObject];
    return item.showNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:TimelineListCell.class]) {
        TimelineListCell *listCell = (TimelineListCell *)cell;
        @weakify(self)
        listCell.photoCall = ^(TimelineListCell * _Nonnull cell, NSInteger index) {
            @strongify(self)
            
            TF_TimeVideoBrowseVC *vc = [[TF_TimeVideoBrowseVC alloc] init];
            vc.type = self.type;
            vc.blogs = @[self.blog];
            vc.firstIndex = index;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:nav animated:YES completion:nil];
        };
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        GC_CommentFooterView *footView = [[GC_CommentFooterView alloc] init];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentAction)];
        [footView addGestureRecognizer:tapGesture];
        return footView;
    }
    TimelineInfoRepayFooterView *footer = [tableView xhq_dequeueView:TimelineInfoRepayFooterView.class];
    NSMutableArray *items = self.dataArray[section];
    TimelineInfoReplyCellItem *item = items.firstObject;
    footer.totalDisplayNumber = items.count;
    footer.currentDisplayNumber = item.showNumber;
    footer.displayMode = item.displayMode;
    @weakify(self); @weakify(footer); @weakify(item);
    footer.moreBlock = ^{
        @strongify(self); @strongify(footer); @strongify(item);
        item.displayMode = footer.displayMode;
        [self.tableView reloadData];
    };
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 50;
    }
    NSMutableArray *items = self.dataArray[section];
    TimelineInfoReplyCellItem *item = items.firstObject;
    if (item.displayMode == RepayListDisplayMode_None) {
        return 5;
    }
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return;
    }
    TimelineInfoReplyCellItem *item = self.dataArray[indexPath.section][0];
    BlogReply *model = (BlogReply *)item.cellModel;
    TimelineReplyVC *reply = [[TimelineReplyVC alloc] init];
    reply.reply = model;
    [self.navigationController pushViewController:reply animated:YES];
}


#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam {
    switch (notifcationId) {
        case MakeID(EUserManager, EUser_Timeline_Follows_Change):
            [self.tableView reloadData];
            break;
        case MakeID(EUserManager, EUser_Timeline_Info_Comment_Change):
            [self infoCommentChanged:(NSArray *)inParam];
            break;
        case MakeID(EUserManager, EUser_Timeline_Reply_Comment_Change):
            [self replyCommentChanged:(NSArray *)inParam];
            break;
        case MakeID(EUserManager, EUser_Timeline_Reply_Liked_Change):
            [self replyLikedChanged:(NSArray *)inParam];
            break;
        case MakeID(EUserManager, EUser_Timeline_Delete_Change):
        case MakeID(EUserManager, EUser_Timeline_Blocked_Change):
            [self deleteTimeline:inParam];
            break;
        default:
            break;
    }
}

- (void)commentAction{
    [self.commentView commentBlog:self.blog.ids];
}

/// 动态评论更新
- (void)infoCommentChanged:(NSArray *)param {
    NSInteger blogId = [param.firstObject integerValue];
    if (blogId != self.blog.ids) {
        return;
    }
    
    NSMutableArray *replyItems = NSMutableArray.array;
    TimelineInfoReplyCellItem *rItem = TimelineInfoReplyCellItem.item;
    rItem.displayMode = RepayListDisplayMode_None;
    rItem.cellModel = [BlogReply mj_objectWithKeyValues:param.lastObject];
    [replyItems addObject:rItem];
    [self.dataArray insertObject:replyItems atIndex:1];
    [self.tableView reloadData];
}

/// 评论内回复更新
- (void)replyCommentChanged:(NSArray *)param {
    NSInteger replyId = [param.firstObject integerValue];
    for (NSMutableArray *items in self.dataArray) {
        if (![items.firstObject isKindOfClass:TimelineInfoReplyCellItem.class]) {
            continue;
        }
        BOOL isChanged = NO;
        for (TimelineInfoReplyCellItem *item in items) {
            BlogReply *reply = (BlogReply *)item.cellModel;
            if (replyId == reply.ids) {
                isChanged = YES;
                TimelineInfoReplyCellItem *fItem = items.firstObject;
                fItem.subRepayNumber ++;
                fItem.displayMode = RepayListDisplayMode_Close;
                TimelineInfoReplyCellItem *sItem = TimelineInfoReplyCellItem.item;
                sItem.subRepay = YES;
                sItem.cellModel = [BlogReply mj_objectWithKeyValues:param.lastObject];
                [items addObject:sItem];
                break;
            }
        }
        if (isChanged) {
            break;
        }
    }
    [self.tableView reloadData];
}

/// 点赞评论
- (void)replyLikedChanged:(NSArray *)param {
    NSInteger replyId = [param.firstObject integerValue];
    BOOL isLike = [param.lastObject boolValue];
    for (NSMutableArray *items in self.dataArray) {
        if (![items.firstObject isKindOfClass:TimelineInfoReplyCellItem.class]) {
            continue;
        }
        BOOL isChanged = NO;
        for (TimelineInfoReplyCellItem *item in items) {
            BlogReply *reply = (BlogReply *)item.cellModel;
            if (replyId == reply.ids && reply.liked != isLike) {
                isChanged = YES;
                reply.liked = isLike;
                isLike ? reply.like_count ++ : reply.like_count --;
                break;
            }
        }
        if (isChanged) {
            break;
        }
    }
    [self.tableView reloadData];
}

/// 删除动态
- (void)deleteTimeline:(id)param {
    NSInteger blogId = [param integerValue];
    if (self.blog.ids == blogId) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - getter
- (TimelineCommentView *)commentView {
    if (!_commentView) {
        _commentView = [[TimelineCommentView alloc] init];
    }
    return _commentView;
}


@end
