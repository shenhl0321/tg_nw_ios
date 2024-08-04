//
//  MSTabbarItem.m
//  MoorgenSmartHome
//
//  Created by XMJ on 2018/4/28.
//  Copyright © 2018年 MoorgenSmartHome. All rights reserved.
//

#import "MSTabbarItem.h"
#import "UIButton+LXMImagePosition.h"

@interface MSTabbarItem ()
@property (nonatomic, strong) UILabel *badgeLabel;
@property (nonatomic, strong) UIView *badgeView;
@end

@implementation MSTabbarItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitleColor:HEXCOLOR(0x666666) forState:UIControlStateNormal];
        [self setTitleColor:HEXCOLOR(0x08CF98) forState:UIControlStateSelected];
        self.titleLabel.font = fontBold(10);
        [self addSubview:self.badgeView];
        [self.badgeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_centerX).with.offset(7.5);
            make.top.mas_equalTo(0);
            make.width.mas_greaterThanOrEqualTo(17);
            make.height.mas_equalTo(17);
            
        }];
//        [self bringSubviewToFront:self.badgeView];
    }
    return self;
}


-(void)setHighlighted:(BOOL)highlighted
{
    
}

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    self.titleLabel.font = fontBold(10);
//    if (selected) {
//        if (kIsIpad()) {
//            self.titleLabel.font = fontMedium(14);
//        }else{
//            if (TT) {
//                self.titleLabel.font = fontBold(12);
//            }else{
//                self.titleLabel.font = fontMedium(12);
//            }
//
//        }
//    }else{
//        if (kIsIpad()) {
//            self.titleLabel.font = fontRegular(14);
//        }else{
//            if (TT) {
//                self.titleLabel.font = fontBold(12);
//            }else{
//                self.titleLabel.font = fontMedium(12);
//            }
//        }
//    }
}
////返回图片的frame
//-(CGRect)imageRectForContentRect:(CGRect)contentRect
//{
////    return CGRectMake((contentRect.size.width - 25)/2, 2, 25, 25);
//     return CGRectMake(0, (contentRect.size.height-28)*0.5, 28, 28);
//}
////返回标题的frame
//-(CGRect)titleRectForContentRect:(CGRect)contentRect
//{
////    return CGRectMake(0, 30, contentRect.size.width, 15);
//    return CGRectMake(42, 0, contentRect.size.width-42, contentRect.size.width);
//}

-(UILabel *)badgeLabel{
    if (!_badgeLabel) {
        _badgeLabel = [[UILabel alloc] init];
        _badgeLabel.layer.cornerRadius = 8.5;
        _badgeLabel.layer.masksToBounds = YES;
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        _badgeLabel.textColor = [UIColor colorTextForFFFFFF];
        _badgeLabel.font = fontRegular(12);
        
    }
    return _badgeLabel;
}

-(UIView *)badgeView{
    if (!_badgeView) {
        _badgeView = [[UIView alloc] init];
        _badgeView.layer.cornerRadius = 8.5;
        _badgeView.layer.masksToBounds = YES;
        _badgeView.backgroundColor = [UIColor colorforFD4E57];
        _badgeView.hidden = YES;
        [_badgeView addSubview:self.badgeLabel];
        [self.badgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(0);
            make.left.mas_equalTo(4.5);
        }];
    }
    return _badgeView;
}
-(void)setBadgeValue:(NSString *)badgeValue{
    if (badgeValue == nil) {
        self.badgeView.hidden = YES;
    }else{
        self.badgeView.hidden = NO;
        self.badgeLabel.text = badgeValue;
    }
}
@end
