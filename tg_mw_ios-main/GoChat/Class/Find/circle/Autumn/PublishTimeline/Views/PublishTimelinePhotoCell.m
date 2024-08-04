//
//  PublishTimelinePhotoCell.m
//  GoChat
//
//  Created by mac on 2022/1/6.
//

#import "PublishTimelinePhotoCell.h"

@implementation PublishTimelinePhotoCellItem


@end

@interface PublishTimelinePhotoCell ()

@property (nonatomic, weak) UIView *customView;

@end

@implementation PublishTimelinePhotoCell

- (void)setItem:(DYCollectionViewCellItem *)item {
    [super setItem:item];
    PublishTimelinePhotoCellItem *m = (PublishTimelinePhotoCellItem *)item;
    if (![self.subviews containsObject:self.customView]) {
        self.customView = m.customView;
        [self addSubview:self.customView];
        return;
    }
    if (m.cellSize.height != m.customView.xhq_height) {
        [self layoutIfNeeded];
    }
}

- (void)dy_initUI {
    [super dy_initUI];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_customView) {
        return;
    }
    [_customView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

@end
