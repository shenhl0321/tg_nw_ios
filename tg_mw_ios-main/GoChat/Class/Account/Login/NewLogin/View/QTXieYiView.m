//
//  QTXieYiView.m
//  QTMobileProject
//
//  Created by 爱情营行 on 2021/8/5.
//

#import "QTXieYiView.h"
#import "BaseWebViewController.h"

@interface QTXieYiView () <UITextViewDelegate>

@property (strong, nonatomic) UITextView *textview;
@property (strong, nonatomic) NSString *titleStr;
@property (strong, nonatomic) NSArray *dataArr;
@property (nonatomic, assign) CGFloat view_W;
@property (strong, nonatomic) UIFont *textFont;
@property (strong, nonatomic) UIColor *selectedColor;

@property (strong, nonatomic) QTXieYiViewClickSuccess successBlock;

@end

@implementation QTXieYiView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self initUI];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.view_W = self.frame.size.width;
    
    [self addSubview:self.textview];
    [self.textview mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.edges.equalTo(self);
    }];
    
    [self refreshView];
}

- (void)refreshView{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[self isEmpty:self.titleStr]?@"":self.titleStr];
    
    for (NSDictionary *dict in self.dataArr) {
        [attributedString addAttribute:NSLinkAttributeName
                                 value:[NSString stringWithFormat:@"%@://", dict[@"url"]]
                                 range:[[attributedString string] rangeOfString:dict[@"title"]]];
    }
    [attributedString addAttribute:NSFontAttributeName value:self.textFont range:NSMakeRange(0, attributedString.length)];
    self.textview.attributedText = attributedString;
    
    NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
    for (NSDictionary *dict in self.dataArr) {
        NSLog(@" - %@", dict);
        [para setValue:self.selectedColor forKey:NSForegroundColorAttributeName];
    }
    self.textview.linkTextAttributes = para;
    self.textview.textColor = HEXCOLOR(0x999999);
    self.textview.delegate = self;
    self.textview.editable = NO; // 必须禁止输入，否则点击将弹出输入键盘
    self.textview.scrollEnabled = NO;
//    self.textview.backgroundColor = [UIColor redColor];
}

- (UITextView *)textview
{
    if (!_textview) {
        _textview = [[UITextView alloc] init];
    
    }
    return _textview;
}

- (void)initUI{
    
}

- (void)showTitle:(NSString *)title font:(UIFont *)font array:(nonnull NSArray *)array SelectedColor:(nonnull UIColor *)selectedColor confirm:(nonnull QTXieYiViewClickSuccess)confirm
{
    self.successBlock = confirm;
    self.textFont = font;
    self.titleStr = title;
    self.dataArr = array;
    self.selectedColor = selectedColor;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction{
    // 用户协议
    if ([[URL scheme] isEqualToString:[self hanziToPinyin:@"坤坤TG隐私政策"]]) {
        NSString *url = @"https://www.baidu.com";
        UIApplication *application = [UIApplication sharedApplication];
        NSURL *URL = [NSURL URLWithString:url];
        if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [application openURL:URL options:@{}
               completionHandler:^(BOOL success) {
               }];
        } else {
            [application openURL:URL];
        }
        
        return NO;
    }else if ([[URL scheme] isEqualToString:[self hanziToPinyin:@"用户协议"]]) {
        NSString *url = @"https://www.baidu.com";
        UIApplication *application = [UIApplication sharedApplication];
        NSURL *URL = [NSURL URLWithString:url];
        if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [application openURL:URL options:@{}
               completionHandler:^(BOOL success) {
               }];
        } else {
            [application openURL:URL];
        }
        
        return NO;
    }else if ([[URL scheme] isEqualToString:[self hanziToPinyin:@"隐私政策"]]) {
        NSString *url = @"https://www.baidu.com";
        UIApplication *application = [UIApplication sharedApplication];
        NSURL *URL = [NSURL URLWithString:url];
        if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [application openURL:URL options:@{}
               completionHandler:^(BOOL success) {
               }];
        } else {
            [application openURL:URL];
        }
        
        return NO;
    }
    return YES;
}

/// 字符串是否为null
- (BOOL)isEmpty:(NSString *)string{
    if (string == NULL) {
            return YES;
        }
        if (string == nil) {
            return YES;
        }
        if (string.length == 0) {
            return YES;
        }
        return NO;
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

- (NSString *)getNewYongHu:(NSString *)yonghu{
    NSString *newStr;
    if (yonghu.length >= 2) {
        if ([[yonghu substringToIndex:1] isEqualToString:@"@"]) {
            newStr = [yonghu substringWithRange:NSMakeRange(1, yonghu.length-1)];
        }
    }
    return newStr;
}
- (NSString *)getNewToptic:(NSString *)toptic{
    NSString *newStr;
    if (toptic.length >= 3) {
        if ([[toptic substringToIndex:1] isEqualToString:@"#"] && [[toptic substringFromIndex:toptic.length-1] isEqualToString:@"#"]) {
            newStr = [toptic substringWithRange:NSMakeRange(1, toptic.length-2)];
        }
    }
    return newStr;
}

@end
