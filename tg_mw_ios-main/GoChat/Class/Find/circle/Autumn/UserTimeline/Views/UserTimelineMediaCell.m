//
//  UserTimelineMediaCell.m
//  GoChat
//
//  Created by Autumn on 2021/12/15.
//

#import "UserTimelineMediaCell.h"
#import "PhotoImageView.h"
#import "UIImageView+VideoThumbnail.h"
#import "BlogInfo.h"

@implementation UserTimelineMediaCellItem

- (CGSize)cellSize {
    CGFloat wh = (kScreenWidth() - 50) / 3;
    return CGSizeMake(wh, wh);
}

@end

@interface UserTimelineMediaCell ()

@property (nonatomic, strong) PhotoImageView *imageView;

@end

@implementation UserTimelineMediaCell

- (void)setItem:(DYCollectionViewCellItem *)item {
    [super setItem:item];
    BlogInfo *blog = (BlogInfo *)item.cellModel;
    _imageView.photo = PhotoInfo.new;
    if (blog.content.isPhotoContent) {
        _imageView.photo = blog.content.photos.firstObject;
    } else if (blog.content.isVideoContent) {
        [_imageView setThumbnailImage:blog.content.video];
    } else {
        [_imageView reset];
    }
}

- (void)dy_initUI {
    [super dy_initUI];
    
    _imageView = ({
        PhotoImageView *iv = [[PhotoImageView alloc] init];
        [iv xhq_cornerRadius:6];
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

@end
