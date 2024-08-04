//
//  PublishTimelineRemindCell.m
//  GoChat
//
//  Created by Autumn on 2021/11/4.
//

#import "PublishTimelineRemindCell.h"

@implementation PublishTimelineRemindCellItem

- (CGSize)cellSize {
    CGFloat wh = (kScreenWidth() - 40 * 2 - 10 * 4) / 5;
    return CGSizeMake(wh, wh);
}

@end

@interface PublishTimelineRemindCell ()

@property (nonatomic, strong) UIImageView *addImageView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation PublishTimelineRemindCell

- (void)dy_initUI {
    [super dy_initUI];

    _addImageView = ({
        UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_remind_add"]];
        iv;
    });
    _imageView = ({
        UIImageView *iv = [[UIImageView alloc] init];
        iv;
    });
    [self xhq_cornerRadius:26];
    [self addSubview:_addImageView];
    [self addSubview:_imageView];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.size.mas_equalTo(52);
    }];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
        make.size.mas_equalTo(52);
    }];
}

- (void)setItem:(DYCollectionViewCellItem *)item {
    [super setItem:item];
    PublishTimelineRemindCellItem *m = (PublishTimelineRemindCellItem *)item;
    UserInfo *member = m.user;
    if (!member) {
        _imageView.hidden = YES;
        _addImageView.hidden = NO;
     
        return;
    }
    _imageView.hidden = NO;
    _addImageView.hidden = YES;
    
    if (!member.profile_photo) {
        [self loadTextImage:member.displayName];
        return;
    }
    if (!member.profile_photo.isSmallPhotoDownloaded) {
        [[FileDownloader instance] downloadImage:[NSString stringWithFormat:@"%ld", member._id]
                                               fileId:member.profile_photo.fileSmallId type:FileType_Photo];
        [self loadTextImage:member.displayName];
        return;
    }
    [UserInfo cleanColorBackgroundWithView:_imageView];
    _imageView.image = [UIImage imageWithContentsOfFile:member.profile_photo.localSmallPath];
}

- (void)loadTextImage:(NSString *)name {
    _imageView.image = nil;
    unichar text = [@" " characterAtIndex:0];
    if(name.length > 0) {
        text = [[name uppercaseString] characterAtIndex:0];
    }
    [UserInfo setColorBackgroundWithView:_imageView withSize:self.bounds.size withChar:text];
}

@end
