//
//  TimelineReplyVC.m
//  GoChat
//
//  Created by Autumn on 2021/11/20.
//

#import "TimelineReplyVC.h"

#import "TimelineInfoReplyCell.h"
#import "ChatToolView.h"
#import "TimelineCommentView.h"
#import "IQKeyboardManager.h"

#import "TimelineHelper.h"
#import "BlogReply.h"

@interface TimelineReplyVC ()<BusinessListenerProtocol>

@property (nonatomic, strong) TimelineCommentView *commentView;

@end

@implementation TimelineReplyVC

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
        make.bottom.equalTo(@(-kHomeIndicatorHeight()));
        make.height.equalTo(@60);
    }];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(@0);
        make.top.equalTo(@(kNavigationStatusHeight()));
        make.bottom.equalTo(_commentView.mas_top);
    }];
}

- (void)dy_initData {
    [super dy_initData];
    
    [self.customNavBar setTitle:@"评论".lv_localized];
    [self.dataArray addObject:self.sectionArray0];
    [self dy_configureData];
}

- (void)dy_initUI {
    [super dy_initUI];
    self.view.backgroundColor = UIColor.whiteColor;
    [self.tableView xhq_registerCell:TimelineInfoReplyCell.class];
    [self.view addSubview:self.commentView];
}

- (void)dy_request {
    [TimelineHelper querySubReplys:self.reply.ids completion:^(NSArray<BlogReply *> * _Nonnull replys) {
        self.totalPage = replys.count == 20 ? [NSString stringWithFormat:@"%ld", self.currentPage.integerValue + 1] : self.currentPage;
        for (BlogReply *reply in replys) {
            [self dy_configureDataWithModel:reply];
        }
        [self dy_tableViewReloadData];
    }];
}

- (void)dy_configureData {
    TimelineInfoReplyCellItem *item = TimelineInfoReplyCellItem.item;
    item.cellModel = self.reply;
    [self.sectionArray0 addObject:item];
}

#pragma mark - ConfigureData
- (void)dy_configureDataWithModel:(DYModel *)model {
    TimelineInfoReplyCellItem *item = TimelineInfoReplyCellItem.item;
    item.subRepay = YES;
    item.replyInfo = YES;
    item.cellModel = model;
    [self.sectionArray0 addObject:item];
}

- (void)dy_cellResponse:(__kindof DYTableViewCellItem *)item indexPath:(NSIndexPath *)indexPath {
    if ([item isKindOfClass:TimelineInfoReplyCellItem.class]) {
        BlogReply *reply = (BlogReply *)item.cellModel;
        [self.commentView commentReply:reply.ids name:((TimelineInfoReplyCellItem *)item).username];
    }
}

#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam {
    switch (notifcationId) {
        case MakeID(EUserManager, EUser_Timeline_Reply_Comment_Change):
            [self replyCommentChanged:inParam];
            break;
        default:
            break;
    }
}

/// 评论内回复更新
- (void)replyCommentChanged:(NSArray *)param {
    /// 是否是回复当前页面的评论内容
    NSInteger replyId = [param.firstObject integerValue];
    BOOL isInThisReply = NO;
    for (TimelineInfoReplyCellItem *item in self.sectionArray0) {
        BlogReply *reply = (BlogReply *)item.cellModel;
        if (reply.ids == replyId) {
            isInThisReply = YES;
            break;
        }
    }
    if (!isInThisReply) {
        return;
    }
    [self dy_configureDataWithModel:[BlogReply mj_objectWithKeyValues:param.lastObject]];
    [self.tableView reloadData];
}

#pragma mark - getter
- (TimelineCommentView *)commentView {
    if (!_commentView) {
        _commentView = [[TimelineCommentView alloc] init];
        [_commentView setCommentReplyId:self.reply.ids];
    }
    return _commentView;
}


@end
