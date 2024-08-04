 //
//  ASwitch.m
//  ASwitchDemo
//
//  Created by XMJ on 2018/5/4.
//  Copyright © 2018年 Mona's Pro. All rights reserved.
//

#import "ASwitch.h"

#define HexRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define ASwitchDuration 0.25
#define DefaultNormalColor HexRGB(0xCCCCCC)
#define DefaultOnColor [UIColor colorMain]
#define DefaultRadius 9
#define DefaultWidth 44
#define DefaultHeight 24
#define DefaultLeft 2
@interface ASwitch()

@property (nonatomic, strong) UIImageView *circleImgV;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign, readonly) CGFloat left;
@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, strong) CABasicAnimation *transAnimation;

@end

@implementation ASwitch

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        self.width = frame.size.width;
        self.height = frame.size.height;
        [self initUI];
        self.frame = frame;
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

- (void)initData{
    self.circleRadius = DefaultRadius;
    self.onColor = DefaultOnColor;
    self.normalColor = DefaultNormalColor;
    self.width = DefaultWidth;
    self.height = DefaultHeight;
    self.on = NO;
}

-(CGFloat)left{
    CGFloat left = DefaultLeft;
    if (self.width - self.circleRadius*2>0) {
        left = (self.height - self.circleRadius*2)*0.5;
    }
    return left;
}

-(void)setCircleRadius:(CGFloat)circleRadius{
    if (_circleRadius  != circleRadius) {
        _circleRadius = circleRadius;
        self.circleImgV.layer.cornerRadius = self.circleRadius;
        [self circleImgVFrameWithisOn:self.isOn];//需要调整一下位置
    }
}


- (void)initUI{
    self.frame = CGRectMake(0, 0, self.width, self.height);
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    [self addSubview:self.circleImgV];
}

-(UIImageView *)circleImgV{
    if (!_circleImgV) {
        _circleImgV = [[UIImageView alloc] initWithFrame:CGRectMake(self.left, self.left, self.circleRadius*2, self.circleRadius*2)];
        _circleImgV.backgroundColor = [UIColor whiteColor];
        _circleImgV.layer.cornerRadius = self.circleRadius;
        _circleImgV.layer.masksToBounds = YES;
    }
    return _circleImgV;
}

- (void)tap:(UITapGestureRecognizer *)recognizer{
//    if (![MoorgenUtil moorgenUtilIsCanExecute]) {
//        return ;
//    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self setOn:!self.isOn animated:YES completion:nil];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        if (self.aSwitchDelegate && [self.aSwitchDelegate respondsToSelector:@selector(aSwitch:isOn:)]) {
            [self.aSwitchDelegate aSwitch:self isOn:self.isOn];
        }
    }

}

-(CABasicAnimation *)transAnimation{
    if (!_transAnimation) {
        _transAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        _transAnimation.autoreverses = NO;
        _transAnimation.duration = 0.25;
        _transAnimation.repeatCount = 1;
        _transAnimation.fillMode=kCAFillModeForwards;
        _transAnimation.removedOnCompletion = NO;
    }
    return _transAnimation;
}

- (void)setOn:(BOOL)on animated:(BOOL)animated completion:(CompleteBlock)completion{
    if (on == _on) {
        return;
    }
    _on = on;
    [self circleImgVFrameWithisOn:on];
    [self.circleImgV.layer removeAllAnimations];
    CGPoint startPoint = CGPointMake(self.left+self.circleRadius, self.left+self.circleRadius);
    CGPoint endPoint = CGPointMake(self.width - self.left - self.circleRadius, self.left+self.circleRadius);
    CGPoint fromPoint = startPoint;
    CGPoint toPoint = endPoint;
    CGFloat duration = ASwitchDuration;
    
    if(on){
        fromPoint = startPoint;
        toPoint = endPoint;
    }else{
        fromPoint = endPoint;
        toPoint = startPoint;
    }
    if (animated) {
        duration = ASwitchDuration;
    }else{
        duration = 0;
    }
    self.transAnimation.duration = duration;
    self.transAnimation.fromValue = [NSValue valueWithCGPoint:fromPoint];
    self.transAnimation.toValue = [NSValue valueWithCGPoint:toPoint];
    
    if (animated) {
        [self.circleImgV.layer addAnimation:self.transAnimation forKey:@"translation"];
    }
    if (on) {
        self.backgroundColor = self.onColor;

    }else{
        self.backgroundColor = self.normalColor;
    }
}


-(void)setOnColor:(UIColor *)onColor{
    _onColor = onColor;
    if (self.isOn) {
        self.backgroundColor = self.onColor;
    }else{
        self.backgroundColor = self.normalColor;
    }
}

- (void)setNormalColor:(UIColor *)normalColor{
    _normalColor = normalColor;
    if (self.isOn) {
        self.backgroundColor = self.onColor;
    }else{
        self.backgroundColor = self.normalColor;
    }
}

- (void)circleImgVFrameWithisOn:(BOOL)isOn{
    if (isOn) {
         self.circleImgV.frame = CGRectMake(self.width-self.left-self.circleRadius*2, self.left, self.circleRadius*2, self.circleRadius*2);
    }else{
          self.circleImgV.frame = CGRectMake(self.left, self.left, self.circleRadius*2, self.circleRadius*2);
    }
}

-(void)setOnWithOutAnimation:(BOOL)isOn{
    if (self.isOn == isOn) {
        return;
    }
    self.isOn = isOn;
    [self setOn:isOn animated:NO completion:nil];
}

-(void)setHeight:(CGFloat)height{
    if (_height != height) {
        _height = height;
         self.layer.cornerRadius = height*0.5;
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.width = self.frame.size.width;
    self.height = self.frame.size.height;
     [self circleImgVFrameWithisOn:self.isOn];
}
@end
