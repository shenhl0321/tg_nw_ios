//
//  PublishTimelineMediaCell.m
//  GoChat
//
//  Created by Autumn on 2021/11/4.
//

#import "PublishTimelineMediaCell.h"

@implementation PublishTimelineMediaCellItem

- (CGSize)cellSize {
    CGFloat wh = (kScreenWidth() - 25 * 2 - 10 * 2) / 3;
    return CGSizeMake(wh, wh);
}

@end


@interface PublishTimelineMediaCell ()

@property (nonatomic, strong) UIImageView *addImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *playerImageView;
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation PublishTimelineMediaCell

- (void)dy_initUI {
    [super dy_initUI];
    _addImageView = ({
        UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_publish_add"]];
        iv;
    });
    _imageView = ({
        UIImageView *iv = [[UIImageView alloc] init];
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.clipsToBounds = YES;
        iv;
    });
    _playerImageView = ({
        UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_video_play"]];
        iv;
    });
    _closeButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"icon_timeline_close"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(removeAction) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self xhq_cornerRadius:5];
    [self addSubview:_addImageView];
    [self addSubview:_imageView];
    [self addSubview:_playerImageView];
    [self addSubview:_closeButton];
    self.backgroundColor = [UIColor colorForF5F9FA];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    [_addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.size.mas_equalTo(30);
    }];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [_playerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.size.mas_equalTo(25);
    }];
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.mas_equalTo(0);
        make.size.mas_equalTo(30);
    }];
}

- (void)removeAction {
    !self.responseBlock ? : self.responseBlock();
}

- (void)setItem:(DYCollectionViewCellItem *)item {
    [super setItem:item];
    PublishTimelineMediaCellItem *m = (PublishTimelineMediaCellItem *)item;
    if (m.image) {
        _imageView.image = m.image;
        _imageView.hidden = NO;
        _closeButton.hidden = NO;
        _addImageView.hidden = YES;
        _playerImageView.hidden = !m.isVideo;
    } else {
        _closeButton.hidden = YES;
        _playerImageView.hidden = YES;
        _imageView.hidden = YES;
        _addImageView.hidden = NO;
    }
}

@end
