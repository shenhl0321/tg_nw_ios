//
//  PublishTopicListCell.m
//  GoChat
//
//  Created by Autumn on 2022/3/1.
//

#import "PublishTopicListCell.h"
#import "BlogTopic.h"

@implementation PublishTopicListCellItem

- (CGFloat)cellHeight {
    return 50;
}

@end

@interface PublishTopicListCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *imagesContainer;

@property (nonatomic, strong) NSMutableArray<UIImageView *> *images;

@end

#define imageSize CGSizeMake(12, 17)
static NSInteger const imageCount = 5;

@implementation PublishTopicListCell

- (void)setItem:(DYTableViewCellItem *)item {
    [super setItem:item];
    BlogTopic *t = (BlogTopic *)item.cellModel;
    _nameLabel.text = [NSString stringWithFormat:@"#%@", t.name];
    
    if (t.ranking >= 5) {
        for (UIImageView *v in _images) { v.hidden = NO; }
    } else {
        NSInteger count = imageCount - t.ranking;
        for (NSInteger idx = 0; idx < count; idx ++ ) {
            _images[idx].hidden = YES;
        }
    }
}

- (void)dy_initUI {
    [super dy_initUI];
    
    self.sideMargin = 25;
    
    _nameLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.colorTextFor23272A;
        label.font = [UIFont regularCustomFontOfSize:15];
        label;
    });
    
    _imagesContainer = ({
        UIView *view = UIView.new;
        view;
    });
    
    [self addSubview:_nameLabel];
    [self addSubview:_imagesContainer];
    
    [self setSubImageViews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(25);
        make.centerY.mas_equalTo(0);
    }];
    [_imagesContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-25);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(imageSize.width * imageCount + 5 * (imageCount - 1));
    }];
}

- (void)setSubImageViews {
    _images = NSMutableArray.array;
    for (NSInteger idx = 0; idx < imageCount; idx ++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_cicle_topic_hot"]];
        [_imagesContainer addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.size.mas_equalTo(imageSize);
            if (self.images.count == 0) {
                make.leading.mas_equalTo(0);
            } else {
                make.leading.equalTo(self.images.lastObject.mas_trailing).offset(5);
            }
        }];
        
        [_images addObject:imageView];
    }
}

@end
