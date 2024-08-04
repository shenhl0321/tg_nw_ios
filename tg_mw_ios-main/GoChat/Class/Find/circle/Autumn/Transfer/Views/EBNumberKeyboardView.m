//
//  EBNumberKeyboardView.m
//  eBest_KA_Pro
//
//  Created by HoYo on 2018/5/8.
//  Copyright © 2018年 com.ebest. All rights reserved.
//

#import "EBNumberKeyboardView.h"

#define kEBScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kEBScreenHeight [[UIScreen mainScreen] bounds].size.height

CGFloat const kEBNumberKeyboardViewHeight = 238;
CGFloat const kEBNumberKeyboardViewColumns = 4; // 5列
CGFloat const kEBNumberKeyboardViewLineSpace = 7; // 间距
NSString *const kEBNumberKeyboardViewDotKey = @".";

@implementation EBNumberKeyboardView
- (instancetype)initWithKeyboardType:(EBNumberKeyboardType)keyboardType {
    if (self = [super init]) {
        self.frame = CGRectMake(0, kEBScreenHeight, kEBScreenWidth, kEBNumberKeyboardViewHeight + kHomeIndicatorHeight());
        self.backgroundColor = XHQHexColor(0xF5F5F5);
        _keyboardType = keyboardType;
        [self calcKeyboardLayout];
    }
    return self;
}

- (void)calcKeyboardLayout {
    NSArray *buttonTexts = @[
        @"1", @"2", @"3", @"退格".lv_localized,
        @"4", @"5", @"6", @"转账".lv_localized,
        @"7", @"8", @"9",
        @"0", kEBNumberKeyboardViewDotKey];
    NSInteger counts = buttonTexts.count;
    NSInteger rows = 4;
    CGFloat buttonWidth = (kEBScreenWidth - (kEBNumberKeyboardViewColumns - 1) * kEBNumberKeyboardViewLineSpace) / kEBNumberKeyboardViewColumns ;
    CGFloat buttonHeight = (kEBNumberKeyboardViewHeight - (rows - 1) * kEBNumberKeyboardViewLineSpace) / rows;
    CGFloat buttonX = 0, buttonY = 0;
    NSInteger index = 0;
    for (int rowIndex = 1; rowIndex <= rows; rowIndex++) {
        if (rowIndex > 1) {
            buttonY += buttonHeight + kEBNumberKeyboardViewLineSpace;
        }
        buttonX = 0;
        for (int colIndex = 1; colIndex <= kEBNumberKeyboardViewColumns; colIndex ++) {
            if (index >= counts) break;
            if (colIndex > 1) {
                buttonX += buttonWidth + kEBNumberKeyboardViewLineSpace;
            }
            NSString *text = buttonTexts[index];
            CGRect frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
            if ([text isEqualToString:@"转账".lv_localized]) {
                frame.size.height = buttonHeight * 3 + kEBNumberKeyboardViewLineSpace * 2;
            } else if ([text isEqualToString:@"9"]) {
                colIndex ++;
            }  else if ([text isEqualToString:@"0"]) {
                frame.size.width = buttonWidth * 2 + kEBNumberKeyboardViewLineSpace;
                buttonX += buttonWidth + kEBNumberKeyboardViewLineSpace;
            }
            [self addButtonWithFrame:frame text:text];
            index ++;
        }
    }
}

#pragma mark - Events
- (void)buttonClicked:(UIButton*)button {
    NSString *text = button.currentTitle;
    
    BOOL allowInput = [self checkInput:text];
    
    if (!allowInput) return;
    
    [self execDelegate:text];
}

#pragma mark - Methods

- (void)addButtonWithFrame:(CGRect)frame text:(NSString*)text {
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    if ([text isEqualToString:@"转账".lv_localized]) {
        button.titleLabel.font = [UIFont systemFontOfSize:20];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.backgroundColor = UIColor.colorMain;
    } else {
        button.titleLabel.font = [UIFont semiBoldCustomFontOfSize:24];
        [button setTitleColor:[UIColor colorTextFor23272A] forState:UIControlStateNormal];
        button.backgroundColor = UIColor.whiteColor;
    }
    if ([text isEqualToString:@"退格".lv_localized]) {
        [button setImage:[UIImage imageNamed:@"icon_input_delete"] forState:UIControlStateNormal];
    } else {
        [button setTitle:text forState:UIControlStateNormal];
    }
    [button xhq_cornerRadius:5];
    [self addSubview:button];
}

- (BOOL)checkInput:(NSString*)text {
    BOOL allowInput = YES;
    switch (_keyboardType) {
        case EBNumberKeyboardTypeUInteger: {
            if ([text isEqualToString: kEBNumberKeyboardViewDotKey]) {
                allowInput = NO;
            }
        }
            break;
        case EBNumberKeyboardTypeInteger: {
            if ([text isEqualToString: kEBNumberKeyboardViewDotKey]) {
                allowInput = NO;
            }
        }
            break;
        case EBNumberKeyboardTypeUDecimal: {
           
        }
            break;
        default:
            break;
    }
    return allowInput;
}

- (void)execDelegate:(NSString*)text {
    if (!text) {
        if ([self.delegate respondsToSelector:@selector(numberKeyboardViewDeleteText:)]) {
            [self.delegate numberKeyboardViewDeleteText:self];
        }
        return;
    }
    if ([text isEqualToString:@"转账".lv_localized]) {
        if ([self.delegate respondsToSelector:@selector(numberKeyboardViewEndEditing:)]) {
            [self.delegate numberKeyboardViewEndEditing:self];
        }
    }else if ([text isEqualToString:@"退格".lv_localized]) {
        if ([self.delegate respondsToSelector:@selector(numberKeyboardViewDeleteText:)]) {
            [self.delegate numberKeyboardViewDeleteText:self];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(numberKeyboardViewEditing:text:)]) {
            [self.delegate numberKeyboardViewEditing:self text:text];
        }
    }
}

@end
