//
//  CreateTagsMemberCell.m
//  GoChat
//
//  Created by Autumn on 2021/11/9.
//

#import "CreateTagsMemberCell.h"

@implementation CreateTagsMemberCellItem

- (CGSize)cellSize {
    CGFloat wh = (kScreenWidth() - 80) / 5;
    return CGSizeMake(wh, wh + 30);
}

@end


@interface CreateTagsMemberCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *delButton;

@end

@implementation CreateTagsMemberCell

- (void)dy_initUI {
    [super dy_initUI];
    
    _imageView = ({
        UIImageView *iv = [[UIImageView alloc] init];
        [iv xhq_cornerRadius:5];
        iv;
    });
    _nameLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.xhq_content;
        label.font = [UIFont systemFontOfSize:13];
        label;
    });
    _delButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"quoteclose"] forState:UIControlStateNormal];
        [btn xhq_addTarget:self action:@selector(delAction)];
        btn;
    });
    [self addSubview:_imageView];
    [self addSubview:_nameLabel];
    [self addSubview:_delButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(0);
        make.height.mas_equalTo(_imageView.mas_width);
    }];
    [_delButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.mas_equalTo(_imageView).offset(2);
        make.trailing.mas_equalTo(_imageView).offset(-2);
        make.size.mas_equalTo(20);
    }];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(_imageView.mas_bottom).offset(8);
    }];
}

- (void)delAction {
    !self.responseBlock ? : self.responseBlock();
}

- (void)setItem:(DYCollectionViewCellItem *)item {
    [super setItem:item];
    [UserInfo cleanColorBackgroundWithView:_imageView];
    CreateTagsMemberCellItem *m = (CreateTagsMemberCellItem *)item;
    if (!m.user) {
        _delButton.hidden = YES;
        _nameLabel.text = @"";
        _imageView.image = [UIImage imageNamed:@"icon_add"];
        return;
    }
    _delButton.hidden = NO;
    _nameLabel.text = m.user.displayName;
    if (!m.user.profile_photo) {
        [self loadTextImage:m.user.displayName];
        return;
    }
    if (!m.user.profile_photo.isSmallPhotoDownloaded) {
        [[FileDownloader instance] downloadImage:[NSString stringWithFormat:@"%ld", m.user._id]
                                               fileId:m.user.profile_photo.fileSmallId type:FileType_Photo];
        [self loadTextImage:m.user.displayName];
        return;
    }
    _imageView.image = [UIImage imageWithContentsOfFile:m.user.profile_photo.localSmallPath];
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
