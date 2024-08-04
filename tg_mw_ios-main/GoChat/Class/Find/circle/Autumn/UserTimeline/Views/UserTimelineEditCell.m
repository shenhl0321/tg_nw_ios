//
//  UserTimelineEditCell.m
//  GoChat
//
//  Created by Autumn on 2021/12/15.
//

#import "UserTimelineEditCell.h"

@implementation UserTimelineEditCellItem

- (CGSize)cellSize {
    return CGSizeMake(kScreenWidth() - 30, 50);
}

@end

@interface UserTimelineEditCell ()

@property (nonatomic, strong) UIButton *editButton;

@end

@implementation UserTimelineEditCell

- (void)setItem:(DYCollectionViewCellItem *)item {
    [super setItem:item];
    UserTimelineEditCellItem *m = (UserTimelineEditCellItem *)item;
    NSString *title = m.userid == UserInfo.shareInstance._id ? @"编辑主页".lv_localized : @"发消息".lv_localized;
    [_editButton setTitle:title forState:UIControlStateNormal];
}

- (void)dy_initUI {
    [super dy_initUI];
    _editButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"编辑主页".lv_localized forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor colorMain];
        btn.titleLabel.font = [UIFont semiBoldCustomFontOfSize:16];
        btn.userInteractionEnabled = NO;
        [btn xhq_cornerRadius:13];
        btn;
    });
    [self addSubview:_editButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

@end

