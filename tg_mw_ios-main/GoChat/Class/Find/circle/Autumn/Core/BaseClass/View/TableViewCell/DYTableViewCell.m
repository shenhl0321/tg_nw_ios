//
//  DYTableViewCell.m
//  ShanghaiCard
//
//  Created by 帝云科技 on 2018/11/1.
//  Copyright © 2018 帝云科技. All rights reserved.
//

#import "DYTableViewCell.h"

@interface DYTableViewCellItem ()

@property (nonatomic, weak, readwrite) Class cellClass;

@end

@implementation DYTableViewCellItem

- (NSString *)cellIdentifier {
    NSString *className = NSStringFromClass([self class]);
    if ([className hasSuffix:@"Item"]) {
        _cellIdentifier = [className substringToIndex:className.length - 4];
    }
    return _cellIdentifier;
}

- (CGFloat)cellHeight {
    if (!_cellHeight) {
        _cellHeight = 0.f;
    }
    return _cellHeight;
}

- (Class)cellClass {
    return NSClassFromString(self.cellIdentifier);
}

+ (instancetype)item {
    return [[[self class]alloc] init];
}

@end







@interface DYTableViewCell ()

@property (nonatomic, strong) UILabel *separatorLabel;

@end

@implementation DYTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self dy_initUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self dy_initUI];
}

- (void)dy_initUI {
    
    [self dy_noneSelectionStyle];
    _sideMargin = 0;
    [self addSubview:self.separatorLabel];
    
    self.textLabel.textColor = [UIColor xhq_aTitle];
    self.textLabel.font = [UIFont xhq_font15];
    self.detailTextLabel.textColor = [UIColor xhq_content];
    self.detailTextLabel.font = [UIFont xhq_font14];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_separatorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(0.5f);
        make.leading.mas_equalTo(_sideMargin);
        make.trailing.mas_equalTo(-_sideMargin);
    }];
    
    [self bringSubviewToFront:_separatorLabel];
}

- (void)dy_noneSelectionStyle {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - setter
- (void)setItem:(DYTableViewCellItem *)item
{
    _item = item;
    if ([item isMemberOfClass:[DYTableViewCellItem class]]) {
        if ([NSString xhq_notEmpty:item.title]) {
            self.textLabel.text = item.title;
        }
        if ([NSString xhq_notEmpty:item.imageName]) {
            UIImage *image = [UIImage imageNamed:item.imageName];
            self.imageView.image = image;
        }
    }
    if (self.accessoryType == UITableViewCellAccessoryNone && !self.accessoryView) {
        self.accessoryType = item.isShowIndicator ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    }
    if (item.isHideSeparatorLabel) {
        self.hideSeparatorLabel = item.hideSeparatorLabel;
    }
}

- (void)setHideSeparatorLabel:(BOOL)hideSeparatorLabel {
    if (_hideSeparatorLabel != hideSeparatorLabel) {
        _hideSeparatorLabel = hideSeparatorLabel;
        _separatorLabel.hidden = hideSeparatorLabel;
    }
}

- (void)setSideMargin:(CGFloat)sideMargin {
    if (_sideMargin != sideMargin) {
        _sideMargin = sideMargin;
        [self layoutIfNeeded];
    }
}

#pragma mark - getter
- (UILabel *)separatorLabel {
    if (!_separatorLabel) {
        _separatorLabel = [[UILabel alloc] init];
        _separatorLabel.backgroundColor = UIColor.xhq_line;
    }
    return _separatorLabel;
}

@end


@implementation NSMutableArray (DYTableViewCellItem)

- (__kindof DYTableViewCellItem *)dy_itemForTitle:(NSString *)title {
    for (id obj in self) {
        if ([obj isKindOfClass:[NSMutableArray class]]) {
            NSMutableArray *items = (NSMutableArray *)obj;
            DYTableViewCellItem *item = [items dy_itemForTitle:title];
            if (item) {
                return item;
            }
        }else if ([obj isKindOfClass:[DYTableViewCellItem class]]) {
            DYTableViewCellItem *item = (DYTableViewCellItem *)obj;
            if ([item.title isEqualToString:title]) {
                return item;
            }
        }
    }
    return nil;
}

@end
