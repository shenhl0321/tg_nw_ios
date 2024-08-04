//
//  SelectMemberSearchView.m
//  GoChat
//
//  Created by Autumn on 2021/11/7.
//

#import "SelectMemberSearchView.h"


@interface MemberImageCell : DYCollectionViewCell

@property (nonatomic, strong) UserInfo *member;
@property (nonatomic, strong) ChatInfo *group;
@property (nonatomic, strong) UIImageView *imageView;

@end


@implementation MemberImageCell

- (void)dy_initUI {
    [super dy_initUI];
    
    self.hideSeparatorLabel = YES;
    _imageView = ({
        UIImageView *iv = [[UIImageView alloc] init];
        [iv xhq_cornerRadius:5];
        iv.backgroundColor = UIColor.redColor;
        iv;
    });
    [self addSubview:_imageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)setMember:(UserInfo *)member {
    _member = member;
    if (!member.profile_photo) {
        [self loadTextImage:member.displayName];
        return;
    }
    if (!member.profile_photo.isSmallPhotoDownloaded) {
        [[FileDownloader instance] downloadImage:[NSString stringWithFormat:@"%ld", member._id] fileId:member.profile_photo.fileSmallId type:FileType_Photo];
        [self loadTextImage:member.displayName];
        return;
    }
    [UserInfo cleanColorBackgroundWithView:_imageView];
    _imageView.image = [UIImage imageWithContentsOfFile:member.profile_photo.localSmallPath];
}

- (void)setGroup:(ChatInfo *)group {
    _group = group;
    if (!group.photo) {
        [self loadTextImage:group.title];
        return;
    }
    ProfilePhoto *photo = group.photo;
    if (!photo.isSmallPhotoDownloaded && photo.small.remote.unique_id.length > 1) {
        [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", group._id] fileId:photo.fileSmallId download_offset:0 type:FileType_Group_Photo];
        [self loadTextImage:group.title];
        return;
    }
    
    [UserInfo cleanColorBackgroundWithView:_imageView];
    _imageView.image = [UIImage imageWithContentsOfFile:photo.localSmallPath];
}

- (void)loadTextImage:(NSString *)name {
    _imageView.image = nil;
    unichar text = [@" " characterAtIndex:0];
    if(name.length > 0) {
        text = [[name uppercaseString] characterAtIndex:0];
    }
    [UserInfo setColorBackgroundWithView:_imageView withSize:CGSizeMake(42, 42) withChar:text];
}

@end


@interface SelectMemberSearchView ()<
UITextFieldDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation SelectMemberSearchView

- (instancetype)initWithFrame:(CGRect)frame {
    return [super initWithFrame:CGRectMake(0, kNavigationStatusHeight(), kScreenWidth(), 60)];
}

- (void)dy_initUI {
    [super dy_initUI];
    self.backgroundColor = UIColor.whiteColor;
    _textField = ({
        UITextField *view = UITextField.new;
        view.placeholder = @"搜索".lv_localized;
        view.backgroundColor = HEX_COLOR(@"#EFF1F0");
        [view setMylimitCount:@200];
        view.delegate = self;
        [view addTarget:self action:@selector(textContentChanged:) forControlEvents:UIControlEventEditingChanged];
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 20;
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
        UIImageView * imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edit_icon_search"]];
        imageV.frame = CGRectMake(20, 10, 20, 20);
        [leftView addSubview:imageV];
        view.leftView = leftView;
        view.leftViewMode = UITextFieldViewModeAlways;
        view;
    });
    [self addSubview:_textField];
    [self addSubview:self.collectionView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSArray *lists = self.isFromGroup ? _groups : _contacts;
    CGFloat width = lists.count * (40 + 10);
    if (lists.count > 0) {
        width -= 10;
    }
    [_collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(15);
        make.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(MIN(width, SCREEN_WIDTH - 100));
    }];
    [_textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.trailing.mas_equalTo(-15);
        make.centerY.mas_equalTo(0);
        if (width <= 0) {
            make.leading.mas_equalTo(15);
        } else {
            make.leading.mas_equalTo(_collectionView.mas_trailing).offset(10);
        }
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.isFromGroup ? _groups.count : _contacts.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MemberImageCell *cell = [collectionView xhq_dequeueCell:MemberImageCell.class indexPath:indexPath];
    if (self.isFromGroup) {
        cell.group = _groups[indexPath.item];
    } else {
        cell.member = _contacts[indexPath.item];
    }
    return cell;
}




- (void)textContentChanged:(UITextField *)textField {
    !self.searchBlock ? : self.searchBlock();
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - setter
- (void)setGroups:(NSArray *)groups {
    _groups = groups;
    [_collectionView reloadData];
    [self layoutIfNeeded];
    [self setNeedsLayout];
}

- (void)setContacts:(NSArray *)contacts {
    _contacts = contacts;
    [_collectionView reloadData];
    [self layoutIfNeeded];
    [self setNeedsLayout];
}

#pragma mark - getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
            layout.minimumLineSpacing = 10;
            layout.minimumInteritemSpacing = 0;
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout.itemSize = CGSizeMake(40, 40);
            layout;
        });
        _collectionView = ({
            CGRect frame = CGRectZero;
            UICollectionView *collection = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
            collection.delegate = self;
            collection.dataSource = self;
            collection.backgroundColor = UIColor.whiteColor;
            collection.showsHorizontalScrollIndicator = NO;
            [collection xhq_registerCell:MemberImageCell.class];
            if (@available(iOS 11.0, *)) {
                collection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
            collection;
        });
    }
    return _collectionView;
}

- (NSString *)keyword {
    return _textField.text;
}

@end


