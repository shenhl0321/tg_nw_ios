//
//  MessageADButtonsView.m
//  GoChat
//
//  Created by Autumn on 2022/1/21.
//

#import "MessageADButtonsView.h"
#import "ChatMsgReplyMarkupInlineKeyboard.h"
#import "BaseWebViewController.h"

@interface MessageADButtonsView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray<ChatMsgInlineKeyboardButton *> *items;

@property (nonatomic, assign) CGFloat vHeight;

@end

static CGFloat const kCellHeight = 37;
static CGFloat const kCellSpace = 4;

@implementation MessageADButtonsView

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

- (void)reloadData {
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MessageADButtonCell *cell = [collectionView xhq_dequeueCell:MessageADButtonCell.class
                                                      indexPath:indexPath];
    cell.buttonItem = _items[indexPath.item];
//    cell.backgroundColor = self.cellBgColor;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ChatMsgInlineKeyboardButton *item = _items[indexPath.item];
    if (item.type.url) {
        if ([item.type.url containsString:@"joinchat"]) {
            NSString *invitelink = [[UserInfo shareInstance] userIdFromInvitrLink:[NSURL URLWithString:item.type.url]];
            if (invitelink && invitelink.length > 5) {
                [UserInfo shareInstance].inviteLink = invitelink;
                [((AppDelegate*)([UIApplication sharedApplication].delegate)) addGroupWithInviteLink];
                return;
            }
            [UserInfo showTips:nil des:@"无效的邀请链接".lv_localized];
            return;
        }
        BaseWebViewController *web = [[BaseWebViewController alloc] init];
        web.urlStr = item.type.url;
        web.titleString = item.text;
        web.type = WEB_LOAD_TYPE_URL;
        [self.xhq_currentController.navigationController pushViewController:web animated:YES];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (CGRectGetWidth(collectionView.frame) - kCellSpace) / 2;
    if (self.items.count % 2 == 0) {
        return CGSizeMake(width, kCellHeight);
    }
    /// 单数、最后一个
    if (indexPath.item == self.items.count - 1) {
        return CGSizeMake(CGRectGetWidth(collectionView.frame), kCellHeight);
    }
    /// 单数、其他
    return CGSizeMake(width, kCellHeight);
}

#pragma mark - setter
- (void)setRows:(NSMutableArray<NSMutableArray *> *)rows {
    _rows = rows;
    [self.items removeAllObjects];
    [rows enumerateObjectsUsingBlock:^(NSMutableArray * _Nonnull btns, NSUInteger idx, BOOL * _Nonnull stop) {
        [btns enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.items addObject:[ChatMsgInlineKeyboardButton mj_objectWithKeyValues:obj]];
        }];
    }];
    
    /// 双数
    self.vHeight = self.items.count / 2 * (kCellSpace + kCellHeight);
    
    /// 单数
    if (self.items.count % 2 != 0) {
        self.vHeight += (kCellSpace + kCellHeight);
    }
}

#pragma mark - getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.sectionInset = UIEdgeInsetsMake(kCellSpace, 0, 0, 0);
            layout.minimumLineSpacing = kCellSpace;
            layout.minimumInteritemSpacing = kCellSpace;
            layout;
        });
        _collectionView = ({
            UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            collection.delegate = self;
            collection.dataSource = self;
            collection.scrollEnabled = NO;
            collection.backgroundColor = UIColor.clearColor;
            [collection xhq_registerCell:[MessageADButtonCell class]];
            collection;
        });
    }
    return _collectionView;
}

- (NSMutableArray<ChatMsgInlineKeyboardButton *> *)items {
    if (!_items) {
        _items = NSMutableArray.array;
    }
    return _items;
}

@end


@interface MessageADButtonCell ()

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation MessageADButtonCell

#pragma mark - setter
- (void)setButtonItem:(ChatMsgInlineKeyboardButton *)buttonItem {
    _buttonItem = buttonItem;
    _textLabel.text = buttonItem.text;
}

- (void)dy_initUI {
    [super dy_initUI];
    [self xhq_cornerRadius:5];
    self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.1];
    _textLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.colorTextFor23272A;
        label.font = [UIFont regularCustomFontOfSize:14];
        label.textAlignment = 1;
        label;
    });
    _arrowImageView = ({
        UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_chat_ad_arrow"]];
        iv;
    });
    [self addSubview:_textLabel];
    [self addSubview:_arrowImageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(0, 5, 0, 5));
    }];
    [_arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.mas_equalTo(0);
        make.size.mas_equalTo(15);
    }];
}

@end
