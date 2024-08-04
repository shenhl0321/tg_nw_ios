//
//  TF_TimeBrowseCommentV.m
//  GoChat
//
//  Created by apple on 2022/2/10.
//

#import "TF_TimeBrowseCommentV.h"
#import "TimelineHelper.h"
#import "TimelineInfoReplyCell.h"
#import "TimelineInfoReplyCell.h"
#import "TimelineInfoRepayFooterView.h"
#import "UIView+XHQGestureRecognizer.h"
@interface TF_TimeBrowseCommentV()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIVisualEffectView    *effectView;
@property (nonatomic, strong) UIView                *topView;
@property (nonatomic, strong) UILabel               *countLabel;
@property (nonatomic, strong) UIButton              *closeBtn;

@property (nonatomic, strong) UITableView           *tableView;

/// <#code#>
@property (nonatomic,strong) NSMutableArray *dataSource;
/// <#code#>
@property (nonatomic,strong) UILabel *commentL;
/// <#code#>
@property (nonatomic,strong) UIActivityIndicatorView *activityV;
@end

@implementation TF_TimeBrowseCommentV

- (instancetype)init {
    if (self = [super init]) {
        
//        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        self.backgroundColor = [UIColor whiteColor];
        
        
        [self addSubview:self.effectView];
        [self addSubview:self.topView];
        [self.topView addSubview:self.countLabel];
        [self.topView addSubview:self.closeBtn];
        [self addSubview:self.tableView];
        [self addSubview:self.commentL];
        [self addSubview:self.activityV];
        
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.mas_equalTo(kAdapt(50));
        }];
        
        [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.topView);
        }];
        
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.topView);
            make.right.equalTo(self).offset(-kAdapt(16));
            make.width.height.mas_equalTo(kAdapt(40));
        }];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.mas_equalTo(self.commentL.mas_top);
            make.top.equalTo(self.topView.mas_bottom);
        }];
        
        [self.commentL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self);
            make.height.mas_equalTo(44);
            make.bottom.mas_equalTo(-kBottomSafeHeight);
        }];
        [self.activityV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(40);
            make.center.mas_equalTo(self.tableView);
        }];
    }
    return self;
}

- (void)setBlog:(BlogInfo *)blog{
    _blog = blog;
    
    self.countLabel.text = [NSString stringWithFormat:@"%zd条评论".lv_localized, blog.reply_count];
    [self.dataSource removeAllObjects];
    [self requestData];
}

- (void)startActivityAnimating:(BOOL)start{
    if (start) {
        self.activityV.hidden = NO;
        [self.activityV startAnimating];
    } else {
        self.activityV.hidden = YES;
        [self.activityV stopAnimating];
    }
}

- (UIActivityIndicatorView *)activityV{
    if (!_activityV) {
        _activityV = [[UIActivityIndicatorView alloc] init];
        [_activityV setBackgroundColor:[UIColor whiteColor]];
        _activityV.hidden = YES;
    }
    return _activityV;
}

- (void)requestData {
    @weakify(self)
    [self startActivityAnimating:YES];
    [TimelineHelper queryBlogReplys:self.blog.ids offset:0 completion:^(NSArray<BlogReply *> * _Nonnull replys) {
        @strongify(self)
        [self startActivityAnimating:NO];
        for (BlogReply *reply in replys) {
            NSMutableArray *items = NSMutableArray.array;
            TimelineInfoReplyCellItem *item = TimelineInfoReplyCellItem.item;
            item.displayMode = RepayListDisplayMode_None;
            item.cellModel = reply;
            [items addObject:item];
            [self.dataSource addObject:items];
            [self subReplyReq:items];
        }
        [self.tableView reloadData];
        
    }];
}


- (void)subReplyReq:(NSMutableArray *)items {
    NSInteger section = [self.dataSource indexOfObject:items];
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

- (void)commentClick{
    if (self.comment) {
        self.comment(self.blog.ids);
    }
}

- (void)closeClick{
    if (self.closeCall) {
        self.closeCall();
    }
}


/// 评论内回复更新
- (void)replyCommentChanged:(NSArray *)param {
    NSInteger replyId = [param.firstObject integerValue];
    for (NSMutableArray *items in self.dataSource) {
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

#pragma mark - <UITableViewDataSource, UITableViewDelegate>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    TimelineInfoReplyCellItem *item = [self.dataSource[section] firstObject];
    return item.showNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DYTableViewCellItem *item = self.dataSource[indexPath.section][indexPath.row];
    DYTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item.cellIdentifier forIndexPath:indexPath];
    cell.item = item;
    NSMutableArray *items = self.dataSource[indexPath.section];
    cell.hideSeparatorLabel = items.count == indexPath.row + 1;
    @weakify(self);
    cell.responseBlock = ^{
        @strongify(self);
        BlogReply *reply = (BlogReply *)item.cellModel;
        if (self.replay) {
            self.replay(reply.ids, ((TimelineInfoReplyCellItem *)item).username);
        }
    };
    return cell;
}


#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    TimelineInfoRepayFooterView *footer = [tableView xhq_dequeueView:TimelineInfoRepayFooterView.class];
    NSMutableArray *items = self.dataSource[section];
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
    
    NSMutableArray *items = self.dataSource[section];
    TimelineInfoReplyCellItem *item = items.firstObject;
    if (item.displayMode == RepayListDisplayMode_None) {
        return 5;
    }
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}


#pragma mark - 懒加载

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    }
    return _effectView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [UIView new];
        _topView.backgroundColor = [UIColor whiteColor];
        
        CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH, kAdapt(50));
        //绘制圆角 要设置的圆角 使用“|”来组合
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:frame byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
        
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        //设置大小
        maskLayer.frame = frame;
        
        //设置图形样子
        maskLayer.path = maskPath.CGPath;
        
        _topView.layer.mask = maskLayer;
    }
    return _topView;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [UILabel new];
        _countLabel.font = [UIFont systemFontOfSize:17.0f];
        _countLabel.textColor = [UIColor blackColor];
    }
    return _countLabel;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton new];
        [_closeBtn setImage:[UIImage imageNamed:@"com_nav_ic_close_normal"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UILabel *)commentL{
    if (!_commentL) {
        _commentL = [[UILabel alloc] init];
        _commentL.text = @"  \t写下你的精彩评论吧~".lv_localized;
//        [_commentL setTitle:@"评论" forState:UIControlStateNormal];
//        [_commentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [_commentBtn addTarget:self action:@selector(commentClick) forControlEvents:UIControlEventTouchUpInside];
        _commentL.font = XHQFont(15);
        _commentL.textColor = XHQHexColor(0x999999);
        _commentL.userInteractionEnabled = YES;
        @weakify(self)
        [_commentL xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            @strongify(self);
            [self commentClick];
        }];
        
    }
    return _commentL;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView xhq_registerCell:TimelineInfoReplyCell.class];
        [_tableView xhq_registerView:TimelineInfoRepayFooterView.class];
        _tableView.rowHeight = kAdapt(120.0f);
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedRowHeight = 0;
        _tableView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
    }
    return _tableView;
}

@end
