//
//  MessageReactionBottomView.m
//  GoChat
//
//  Created by Autumn on 2022/3/27.
//

#import "MessageReactionBottomView.h"
#import "UserinfoHelper.h"

@interface MessageReactionBottomView ()<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation MessageReactionBottomView

+ (CGFloat)viewHeight {
    return 40;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [super initWithFrame:CGRectMake(0, 0, 180, MessageReactionBottomView.viewHeight)];
}

- (void)dy_initUI {
    [super dy_initUI];
    [self addSubview:self.collectionView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)setReactions:(NSArray<MessageReactionList *> *)reactions {
    _reactions = reactions;
    NSMutableArray *uid1s = NSMutableArray.array,
    *uid2s = NSMutableArray.array,
    *uid3s = NSMutableArray.array,
    *uid4s = NSMutableArray.array;
    for (MessageReactionList *r in reactions) {
        if (r.reactionId == 1) {
            [uid1s addObject:@(r.userId)];
        } else if (r.reactionId == 2) {
            [uid2s addObject:@(r.userId)];
        } else if (r.reactionId == 3) {
            [uid3s addObject:@(r.userId)];
        } else if (r.reactionId == 4) {
            [uid4s addObject:@(r.userId)];
        }
    }
    self.items = NSMutableArray.array;
    [@[uid1s, uid2s, uid3s, uid4s] enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.count > 0) {
            MessageReactionBottomListCellItem *item = MessageReactionBottomListCellItem.item;
            item.reactionId = idx + 1;
            item.userIds = obj;
            [self.items addObject:item];
        }
    }];
    [self.collectionView reloadData];
    self.xhq_width = MIN(200, (self.items.count * 70) + 10);
}

#pragma mark - getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
            layout.minimumLineSpacing = 10;
            layout.minimumInteritemSpacing = 0;
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout;
        });
        _collectionView = ({
            UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            collection.delegate = self;
            collection.dataSource = self;
            collection.showsHorizontalScrollIndicator = NO;
            collection.bounces = NO;
            collection.backgroundColor = UIColor.whiteColor;
            [collection xhq_registerCell:[MessageReactionBottomListCell class]];
            if (@available(iOS 11.0, *)) {
                collection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
            collection;
        });
    }
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MessageReactionBottomListCell *cell = [collectionView xhq_dequeueCell:MessageReactionBottomListCell.class
                                                                indexPath:indexPath];
    cell.item = _items[indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    MessageReactionBottomListCellItem *item = _items[indexPath.item];
    return item.cellSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [MessageReactionPop showReactions:self.reactions];
}

@end


@implementation MessageReactionBottomListCellItem

- (CGSize)cellSize {
    NSInteger count = MIN(self.userIds.count, 10);
    CGFloat width = 15 + 22 + count * 10 + 10;
    return CGSizeMake(width, 30);
}

@end

@implementation MessageReactionBottomListCell

- (void)dy_initUI {
    [super dy_initUI];
    
    [self xhq_cornerRadius:15];
    _emojiLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont xhq_font16];
        label.textAlignment = 1;
        label;
    });
    _avatarContainer = ({
        UIView *view = UIView.new;
        view;
    });
    [self addSubview:_emojiLabel];
    [self addSubview:_avatarContainer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_emojiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.leading.mas_equalTo(5);
        make.width.mas_equalTo(22);
    }];
    [_avatarContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_emojiLabel.mas_trailing).offset(5);
        make.trailing.mas_equalTo(-5);
        make.top.bottom.mas_equalTo(0);
    }];
}

- (void)setItem:(DYCollectionViewCellItem *)item {
    [super setItem:item];
    MessageReactionBottomListCellItem *m = (MessageReactionBottomListCellItem *)item;
    _emojiLabel.text = ReactionEmojiForId(@(m.reactionId));
    BOOL selfClicked = [m.userIds containsObject:@(UserInfo.shareInstance._id)];
    self.backgroundColor = [UIColor.blueColor colorWithAlphaComponent:selfClicked ? 0.5 : 0.1];
    [self updateAvatars:m.userIds];
}

- (void)updateAvatars:(NSArray *)userids {
    [_avatarContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (userids.count == 0) {
        return;
    }
    if (userids.count > 10) {
        userids = [userids subarrayWithRange:NSMakeRange(0, 10)];
    }
    __block UIView *lastView = nil;
    [userids enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView xhq_cornerRadius:10];
        [UserinfoHelper setUserAvatar:obj.integerValue inImageView:imageView];
        [self.avatarContainer addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 20));
            make.centerY.mas_equalTo(0);
            if (lastView) {
                make.leading.equalTo(lastView.mas_trailing).offset(-10);
            } else {
                make.leading.mas_equalTo(0);
            }
        }];
        lastView = imageView;
    }];
}

@end




@interface MessageReactionPopCell : DYTableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *emojiLabel;

@property (nonatomic, strong) MessageReactionList *reaction;

@end

@implementation MessageReactionPopCell

- (void)dy_initUI {
    [super dy_initUI];
    self.hideSeparatorLabel = YES;
    _nameLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.colorTextFor23272A;
        label.font = [UIFont xhq_font14];
        label;
    });
    _avatar = ({
        UIImageView *iv = [[UIImageView alloc] init];
        [iv xhq_cornerRadius:20];
        iv;
    });
    _emojiLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont xhq_font16];
        label;
    });
    [self addSubview:_nameLabel];
    [self addSubview:_avatar];
    [self addSubview:_emojiLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(15);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(40);
    }];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_avatar.mas_trailing).offset(10);
        make.centerY.mas_equalTo(0);
    }];
    [_emojiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-15);
        make.centerY.mas_equalTo(0);
    }];
}

- (void)setReaction:(MessageReactionList *)reaction {
    _reaction = reaction;
    _emojiLabel.text = ReactionEmojiForId(@(reaction.reactionId));
    [UserinfoHelper setUserAvatar:reaction.userId inImageView:_avatar];
    [UserinfoHelper setUsername:reaction.userId inLabel:_nameLabel];
}

@end



@interface MessageReactionPop()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray<MessageReactionList *> *reactions;
@property (nonatomic, assign) CGFloat containerHeight;

@end

@implementation MessageReactionPop

+ (void)showReactions:(NSArray<MessageReactionList *> *)reactions {
    MessageReactionPop *pop = [[MessageReactionPop alloc] init];
    pop.reactions = reactions;
    [UIViewController.xhq_currentController presentViewController:pop animated:NO completion:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self dy_initData];
    [self dy_initUI];
}

- (void)dy_initData {
    
    [self dy_configureData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.backgroundView.alpha = 0;
    self.container.transform = CGAffineTransformMakeTranslation(0, _containerHeight);
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundView.alpha = 1;
        self.container.transform = CGAffineTransformIdentity;
    }];
}

- (void)dy_initUI {
    self.view.backgroundColor = UIColor.clearColor;
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.container];
    [self.container addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundView.alpha = 0;
        self.container.transform = CGAffineTransformMakeTranslation(0, self.containerHeight);
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

#pragma mark - ConfigureData
- (void)dy_configureData {
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.reactions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageReactionPopCell *cell = [tableView xhq_dequeueCell:MessageReactionPopCell.class indexPath:indexPath];
    cell.reaction = self.reactions[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    UIButton *closeButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"com_nav_ic_close_normal"] forState:UIControlStateNormal];
        [btn xhq_addTarget:self action:@selector(dismiss)];
        btn;
    });
    [view addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.bottom.top.mas_equalTo(0);
        make.width.mas_equalTo(closeButton.mas_height);
    }];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

#pragma mark - UITableViewDelegate

#pragma mark - setter
- (void)setReactions:(NSArray<MessageReactionList *> *)reactions {
    _reactions = reactions;
    CGFloat height = reactions.count * 50;
    _containerHeight = MIN(height + 40, kScreenWidth()) + kHomeIndicatorHeight();
    [self.tableView reloadData];
}

#pragma mark - getter
- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = ({
            UIView *view = UIView.new;
            view.frame = self.view.bounds;
            view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.4];
            @weakify(self);
            [view xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
                @strongify(self);
                [self dismiss];
            }];
            view;
        });
    }
    return _backgroundView;
}

- (UIView *)container {
    if (!_container) {
        _container = ({
            UIView *view = UIView.new;
            view.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - _containerHeight, kScreenWidth(), _containerHeight);
            view.backgroundColor = UIColor.whiteColor;
            view;
        });
    }
    return _container;
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        @weakify(self);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self);
            self->_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        });
        _tableView.bounces = NO;
        [_tableView xhq_registerCell:[MessageReactionPopCell class]];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.tableFooterView = [UIView new];
        _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth(), CGFLOAT_MIN)];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
