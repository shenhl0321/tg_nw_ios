//
//  MNSlider.m
//  iCurtain
//
//  Created by XMJ on 2020/7/30.
//  Copyright © 2020 dooya. All rights reserved.
//

#import "MNSlider.h"
#import "UIView+XMJAdditions.h"

@interface MNSlider ()

//@property (nonatomic, strong) UIImageView *backImgV;
//@property (nonatomic, strong) UIImageView *fontImgV;


@property (nonatomic, readonly, assign) CGFloat top;
@property (nonatomic, readonly, assign) CGFloat bottom;
@property (nonatomic, readonly, assign) CGFloat left;
@property (nonatomic, readonly, assign) CGFloat right;
@property (nonatomic, readonly, assign) CGFloat contentWidth;
@property (nonatomic, readonly, assign) CGFloat contentHeight;
@property (nonatomic, assign) CGPoint beginPoint;
@end

@implementation MNSlider
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initData];
        [self initUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self initUI];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initData];
        [self initUI];
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self refreshUI];
}


- (void)initData{
    
    _xmjEdge = UIEdgeInsetsMake(0, 12, 0, 12);
    _isVertical = YES;
    _isReverse = NO;
    _percent = 0;
    _backImgVColor = HexRGB(0xdbdbdb);
    _fontImgVColor = HexRGB(0x308bfd);
    _touchSize = CGSizeMake(29, 29);
    
     
}

- (void)initUI{
    if (self.backImgV.superview == nil) {
        [self addSubview:self.backImgV];
        [self.backImgV addSubview:self.fontImgV];
        [self addSubview:self.touchIV];
        _backImgV.backgroundColor =  self.backImgVColor;
        _fontImgV.backgroundColor =  self.fontImgVColor;
         [self refreshUI];
    }
}

-(void)setPercent:(CGFloat)percent{
    if (percent < 0) {
        percent = 0;
    }else if(percent > 1){
        percent = 1;
    }
    if (self.isReverse) {
        _percent = 1-percent;
    }else{
        _percent = percent;
    }
}

-(void)setTouchSize:(CGSize)touchSize{
    _touchSize = touchSize;
    _touchIV.size = touchSize;
    [self refreshUI];
}

-(void)setXmjEdge:(UIEdgeInsets)xmjEdge{
    _xmjEdge = xmjEdge;
    [self refreshUI];
}

-(CGFloat)top{
    if (self.xmjEdge.top == NAN) {
        return 0;;
    }
    return self.xmjEdge.top;
}

-(CGFloat)bottom{
    if (self.xmjEdge.bottom == NAN) {
        return 0;
    }
    return self.xmjEdge.bottom;
}

-(CGFloat)left{
    if (self.xmjEdge.left == NAN) {
        return 0;
    }
    return self.xmjEdge.left;
}

-(CGFloat)right{
    if (self.xmjEdge.right == NAN) {
        return 0;
    }
    return self.xmjEdge.right;
}

-(CGFloat)contentWidth{
    return self.width - self.left - self.right;
}

-(CGFloat)contentHeight{
    return self.height - self.top - self.bottom;
}

- (void)refreshUI{
    if (self.width<0 || self.height < 0) {
        return;
    }

//    if (self.touchIV.width != self.touchSize.width || self.touchIV.height != self.touchSize.height) {
//        self.touchIV.size = self.touchSize;
//        self.touchIV.layer.cornerRadius = self.touchSize.width*0.5;
//        self.touchIV.layer.borderColor = colorText(0.1).CGColor;
//        self.touchIV.layer.borderWidth = 1;
//
//
//    }
    if (self.backImgV.width != self.width || self.backImgV.height != self.height) {
        self.backImgV.frame = self.bounds;//重新赋值
       if (self.isVertical) {
           self.backImgV.layer.cornerRadius = self.width*0.5;
           self.backImgV.layer.masksToBounds = YES;
       }else{
           self.backImgV.layer.cornerRadius = self.height*0.5;
           self.backImgV.layer.masksToBounds = YES;
       }
    }
    
    if (self.isVertical) {
        CGFloat height = self.percent * self.contentHeight;
        if (self.isReverse) {
            //比如percent0.3的时候
            self.fontImgV.frame = CGRectMake(self.left, self.top + (self.contentHeight-height), self.contentWidth, height+self.bottom);
            self.touchIV.center = CGPointMake(self.backImgV.center.x, self.top + (self.contentHeight-height));
        }else{
            self.fontImgV.frame = CGRectMake(self.left, 0, self.contentWidth, height + self.top);
            self.touchIV.center = CGPointMake(self.backImgV.center.x, height+self.top);
        }
    }else{
        CGFloat width = self.percent * self.contentWidth;
        if (self.isReverse) {
            self.fontImgV.frame = CGRectMake(self.left+(self.contentWidth-width), self.top, width+self.right, self.contentHeight);
            self.touchIV.center = CGPointMake(self.left + (self.contentWidth - width), self.backImgV.center.y);
        }else{
            self.fontImgV.frame = CGRectMake(0, self.top, width+self.left, self.contentHeight);
            self.touchIV.center = CGPointMake(self.left + width, self.backImgV.center.y);
        }
    }
}



-(UIImageView *)backImgV{
    if (!_backImgV) {
        _backImgV = [[UIImageView alloc] init];
    }
    return _backImgV;
}

- (UIImageView *)fontImgV{
    if (!_fontImgV) {
        _fontImgV = [[UIImageView alloc] init];
    }
    return _fontImgV;
}

-(UIImageView *)touchIV{
    if (!_touchIV) {
        _touchIV = [[UIImageView alloc] init];
        _touchIV.backgroundColor = [UIColor whiteColor];
        _touchIV.layer.borderColor = [UIColor colorForF5F9FA].CGColor;
        _touchIV.layer.borderWidth = 0.5;
        _touchIV.layer.shadowRadius = 4;
        _touchIV.layer.shadowOpacity = 1;
        _touchIV.layer.shadowColor = HexRGBAlpha(0x000000, 0.1).CGColor;
        _touchIV.layer.shadowOffset = CGSizeMake(0, 2);
        _touchIV.layer.cornerRadius = 14.5;
        
    }
    return _touchIV;
}

-(void)setFontImgVColor:(UIColor *)fontImgVColor{
    self.fontImgV.backgroundColor = fontImgVColor;
}

-(void)setBackImgVColor:(UIColor *)backImgVColor{
    self.backImgV.backgroundColor = backImgVColor;
}


#pragma mrak - touch 方法监听函数
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event{
     CGPoint point = [touch locationInView:self];
    _beginPoint = point;
    NSLog(@"begin   y --- %.3f",point.y);
    if ([self validTouchWithTouch:touch]) {
        BOOL result = [super beginTrackingWithTouch:touch withEvent:event];
        if (result) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(slider_beginTouch:)]) {
                [self.delegate slider_beginTouch:self];
            }
        }
        return result;
    }else{
        return NO;
    }
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event{
    CGPoint point = [touch locationInView:self];
    if (point.y == self.beginPoint.y && point.x == self.beginPoint.x) {
        
    }else{
        if (self.isVertical) {
            self.percent = (point.y-self.top)/self.contentHeight;
        }else{
            self.percent = (point.x-self.left)/self.contentWidth;
        }
        [self refreshUI];
        [self percentChangeFromTracking];
        if (self.delegate && [self.delegate respondsToSelector:@selector(slider_continueTouch:)]) {
            [self.delegate slider_continueTouch:self];
        }
    }
    
    return YES;
}

- (void)endTrackingWithTouch:(nullable UITouch *)touch withEvent:(nullable UIEvent *)event{
    if (self.delegate && [self.delegate respondsToSelector:@selector(slider_endTouch:)]) {
        [self.delegate slider_endTouch:self];
    }
    
}// touch is sometimes nil if cancelTracking calls through to this.

- (void)cancelTrackingWithEvent:(nullable UIEvent *)event{
    if (self.delegate && [self.delegate respondsToSelector:@selector(slider_endTouch:)]) {
        [self.delegate slider_endTouch:self];
    }
}

- (void)percentChangeFromTracking{
    
}

- (BOOL)validTouchWithTouch:(UITouch *)touch{
    if (self.touchIV.hidden == YES) {
        return NO;
    }
    CGPoint point = [touch locationInView:self];
    return [self validTouchWithPoint:point];
}

- (BOOL)validTouchWithPoint:(CGPoint )point{
    BOOL valid = NO;
    CGRect rect = CGRectInset(self.touchIV.frame, -15, -15);;
    if (CGRectContainsPoint(rect, point)) {
        valid = YES;
    }
    return valid;
}

-(void)setIsReverse:(BOOL)isReverse{
    _isReverse = isReverse;
    [self refreshUI];
}

-(void)setIsVertical:(BOOL)isVertical{
    _isVertical = isVertical;
    [self refreshUI];
    if (isVertical) {
        self.backImgV.layer.cornerRadius = self.width*0.5;
        self.backImgV.layer.masksToBounds = YES;
    }else{
        self.backImgV.layer.cornerRadius = self.height*0.5;
        self.backImgV.layer.masksToBounds = YES;
    }
}


-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    
    BOOL isValid = [self validTouchWithPoint:point];
    return isValid;
    
}

-(void)setEnabled:(BOOL)enabled{
    [super setEnabled:enabled];
    self.fontImgV.hidden = !enabled;
    self.touchIV.hidden = !enabled;
}
@end
