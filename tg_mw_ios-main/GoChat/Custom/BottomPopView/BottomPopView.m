//
//  BottomPopView.m
//  MoorgenSmartHome
//
//  Created by XMJ on 2020/8/24.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//

#import "BottomPopView.h"

@interface BottomPopView()

@end
@implementation BottomPopView

//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self addSubview:self.backgroundView];
//        [self addSubview:self.bottomView];
//    }
//    return self;
//}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initBottomView];
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initBottomView];
    }
    return self;
}

- (void)initBottomView{
    _contentHeight = 238+kBottom34();
    self.frame = CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT);
    if (self.backgroundView.superview==nil) {
        [self addSubview:self.backgroundView];
    }
    if (self.bottomView.superview==nil) {
        [self addSubview:self.bottomView];
    }
}

-(UIView *)backgroundView{
    if (!_backgroundView) {
        _backgroundView = [UIView new];
        _backgroundView.frame = CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT);
        _backgroundView.backgroundColor = HexRGBAlpha(0x000000, 0.4);
        [_backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backTap:)]];
    }
    return _backgroundView;
}

- (void)backTap:(UITapGestureRecognizer *)tagRec{
    [self hide];
}

- (void)show
{
    if (self.superview == nil) {
        [kKeyWindow addSubview:self];
    }
    self.alpha = 0;
//    WS(weakSelf)
    _bottomView.transform = CGAffineTransformScale(_bottomView.transform,0.1,0.1);
    [UIView animateWithDuration:0.3 animations:^{
        self->_bottomView.transform = CGAffineTransformIdentity;
        self.alpha = 1;
    }];
    
}

- (void)hide
{
    if (self.superview) {
        [UIView animateWithDuration:0.3 animations:^{
            self->_bottomView.transform = CGAffineTransformScale(self->_bottomView.transform,0.1,0.1);
            self.alpha = 0;
        } completion:^(BOOL finished) {
            
            [self removeFromSuperview];
        }];
    }
}
-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, APP_SCREEN_HEIGHT-self.contentHeight, APP_SCREEN_WIDTH, self.contentHeight)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        _bottomView.layer.cornerRadius = 7;
        _bottomView.layer.masksToBounds = YES;
        
    }
    return _bottomView;
}

-(void)setContentHeight:(CGFloat)contentHeight{
    _contentHeight = contentHeight;
     self.bottomView.frame = CGRectMake(0, APP_SCREEN_HEIGHT-self.contentHeight, APP_SCREEN_WIDTH, self.contentHeight);
   
}

@end
