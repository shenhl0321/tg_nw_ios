//
//  UITextField+Style.m
//  MoorgenSmartHome
//
//  Created by XMJ on 2020/8/10.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//

#import "UITextField+Style.h"



@implementation UITextField (Style)

- (void)mn_defalutStyle{
    [self mn_defalutStyleWithFont:fontRegular(17)];
}

- (void)mn_defalutStyleWithFont:(UIFont *)font{
    self.textColor = [UIColor colorTextFor23272A];
    self.font = font;
    self.placeholder = @" ";
   
    self.leftViewMode = UITextFieldViewModeAlways;
    UIButton *clearBtn = [self valueForKey:@"_clearButton"];
    [clearBtn setImage:[UIImage imageNamed:@"TFClear"] forState:UIControlStateNormal];
    [self setClearButtonMode:UITextFieldViewModeWhileEditing];
        
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@" " attributes:@{NSForegroundColorAttributeName:[UIColor colorTextForA9B0BF]}];
}

- (void)mn_defalutStyleWithFont:(UIFont *)font leftMargin:(CGFloat)leftMargin{
    self.textColor = [UIColor colorTextFor23272A];
    self.font = font;
    self.placeholder = @" ";
   
    self.leftViewMode = UITextFieldViewModeAlways;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftMargin, 0)];
    self.leftView = leftView;
    UIButton *clearBtn = [self valueForKey:@"_clearButton"];
    [clearBtn setImage:[UIImage imageNamed:@"TFClear"] forState:UIControlStateNormal];
    [self setClearButtonMode:UITextFieldViewModeWhileEditing];
        
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@" " attributes:@{NSForegroundColorAttributeName:[UIColor colorTextForA9B0BF]}];
}

- (void)mn_countryCodeStyle{
    self.textColor = [UIColor colorTextFor23272A];
    self.font = fontRegular(17);
    self.leftViewMode = UITextFieldViewModeAlways;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    label.text = @"+";
    label.font = fontRegular(17);
    label.textColor = [UIColor colorTextFor23272A];
    [leftView addSubview:label];
    label.center = CGPointMake(label.center.x, leftView.center.y);
    self.leftView = leftView;
//    [self.rightView addSubview:label];
    
        
    //    self.rightViewMode = UITextFieldViewModeAlways;
    //    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TfLeftPadding, 20)];
    //    self.leftView = leftView;
        
    //    [self setValue:kColorPlachholder() forKeyPath:@"_placeholderLabel.textColor"];
    //    [self setValue:fontMedium(14) forKeyPath:@"_placeholderLabel.font"];
//    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:fontRegular(18),NSForegroundColorAttributeName:[UIColor colorForTfPlaceHoder]}];
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:fontRegular(15),NSForegroundColorAttributeName:[UIColor colorTextForA9B0BF]}];
   
}
//
////搜索的样式
//- (void)mn_SearchStyle{
//    self.textColor = [UIColor colorTextFor23272A];
//    self.font = fontRegular(17);
//    self.leftViewMode = UITextFieldViewModeAlways;
//    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
//    label.text = @"+";
//    label.font = fontRegular(17);
//    label.textColor = [UIColor colorTextFor23272A];
//    [leftView addSubview:label];
//    label.center = CGPointMake(label.center.x, leftView.center.y);
//    self.leftView = leftView;
////    [self.rightView addSubview:label];
//    
//        
//    //    self.rightViewMode = UITextFieldViewModeAlways;
//    //    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TfLeftPadding, 20)];
//    //    self.leftView = leftView;
//        
//    //    [self setValue:kColorPlachholder() forKeyPath:@"_placeholderLabel.textColor"];
//    //    [self setValue:fontMedium(14) forKeyPath:@"_placeholderLabel.font"];
////    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:fontRegular(18),NSForegroundColorAttributeName:[UIColor colorForTfPlaceHoder]}];
//    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:fontRegular(15),NSForegroundColorAttributeName:[UIColor colorTextForA9B0BF]}];
//   
//}


@end
