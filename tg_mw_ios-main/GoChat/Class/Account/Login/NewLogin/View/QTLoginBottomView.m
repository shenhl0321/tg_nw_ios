//
//  QTLoginBottomView.m
//  BaseChat
//
//  Created by 漫漫人生路 on 2023/3/13.
//

#import "QTLoginBottomView.h"
#import "QTXieYiView.h"

@interface QTLoginBottomView ()

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet QTXieYiView *xieyiView;
@property (strong, nonatomic) QTLoginBottomSuccessBlock successBlock;

@property (weak, nonatomic) IBOutlet UIView *topView;

@end

@implementation QTLoginBottomView

static QTLoginBottomView *currentView = nil;

+(QTLoginBottomView *)sharedInstance {
    @synchronized(self) {
        if(!currentView) {
            currentView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([QTLoginBottomView class]) owner:nil options:nil] firstObject];
            currentView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
        }
    }
    return currentView;
}

- (void)layoutSubviews{
    
    CGFloat height = (CGFloat)SCREEN_WIDTH*210/562;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, SCREEN_WIDTH, height) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(20, 20)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.topView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.topView.layer.mask = maskLayer;
}

- (void)alertViewSuccessBlock:(QTLoginBottomSuccessBlock)successBlock{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window addSubview:currentView];
    self.backBtn.alpha = 0;
    self.successBlock = successBlock;
    
    BOOL isFrist = ![self userDefaultsStringForKey:@"isFrist"];
    if (isFrist == YES){
        self.hidden = NO;
    }else{
        self.hidden = YES;
    }
    [self userDefaultsSetString:@"1" forKey:@"isFrist"];
    
    
    NSString *xieyiStr = @"如果您同意《坤坤TG隐私政策》请点击“同意”开始使用我们的产品和服务，我们尽全力保护您的个人信息安全";
    [self.xieyiView showTitle:xieyiStr font:[UIFont systemFontOfSize:15] array:@[
        @{@"title":@"《坤坤TG隐私政策》",
          @"url": [self hanziToPinyin:@"坤坤TG隐私政策"],
          @"type":@"1"}
    ] SelectedColor:HEXCOLOR(0x34CDAC) confirm:^{
        
    }];
    
    MJWeakSelf
    [UIView animateWithDuration:0.5 animations:^{
        //
        currentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        //
        weakSelf.backBtn.alpha = 0.3;
    }];
}

/// 汉字转拼音
/// /// @param hanzi 汉字
- (NSString *)hanziToPinyin:(NSString *)hanzi{
    NSString *hanziText = hanzi;
    if ([hanziText length]) {
        NSMutableString *ms = [[NSMutableString alloc] initWithString:hanziText];
        if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO)) {
        }
        if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO)) {
            NSArray *arr = [ms componentsSeparatedByString:@" "];
            return [arr componentsJoinedByString:@""];
        }
    }
    return @"";
}
- (IBAction)buttonClick:(UIButton *)sender {
    if (sender.tag == 1){
        [self dismiss];
    }else if (sender.tag == 2){
        [self dismiss];
    }else if (sender.tag == 3){
        [self dismiss];
        if (self.successBlock){
            self.successBlock();
        }
    }
    
}

- (void)dismiss{
    currentView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self removeFromSuperview];
}


/// 从UserDefaults中获取字符串
- (NSString *)userDefaultsStringForKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

/// 存储字符串至UserDefaults
- (void)userDefaultsSetString:(NSString *)string forKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:string forKey:key];
    [defaults synchronize];
}

@end
