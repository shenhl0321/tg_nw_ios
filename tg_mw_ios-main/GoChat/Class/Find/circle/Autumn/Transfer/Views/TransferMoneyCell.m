//
//  TransferMoneyCell.m
//  GoChat
//
//  Created by Autumn on 2022/1/18.
//

#import "TransferMoneyCell.h"
#import "TransferObject.h"
#import "EBNumberKeyboardView.h"

@implementation TransferMoneyCellItem

- (CGFloat)cellHeight {
    return 150;
}


@end

@interface TransferMoneyCell ()<UITextFieldDelegate, EBNumberKeyboardViewDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) EBNumberKeyboardView *numberKeyboardView;

@end

@implementation TransferMoneyCell

- (void)dy_initUI {
    [super dy_initUI];
    [self dy_noneSelectionStyle];
    self.hideSeparatorLabel = YES;
    _titleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.colorTextFor23272A;
        label.font = [UIFont regularCustomFontOfSize:15];
        label.text = @"转账金额".lv_localized;
        label;
    });
    _textField = ({
        UITextField *view = UITextField.new;
        view.font = [UIFont semiBoldCustomFontOfSize:34];
        view.textColor = UIColor.colorTextFor23272A;
        view.delegate = self;
        [view addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
        view.leftViewMode = UITextFieldViewModeAlways;
        view.keyboardType = UIKeyboardTypeDecimalPad;
        view.tintColor = UIColor.xhq_base;
        view.inputAccessoryView = UIView.new;
        
        view.leftView = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
            [view addSubview:({
                UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
                label.textColor = UIColor.colorTextFor23272A;;
                label.font = [UIFont semiBoldCustomFontOfSize:34];
                label.text = @"￥";
                label;
            })];
            view;
        });
        view;
    });
    _numberKeyboardView = ({
        EBNumberKeyboardView *view = [[EBNumberKeyboardView alloc] initWithKeyboardType:EBNumberKeyboardTypeDecimal];
        view.delegate = self;
        view;
    });
    _line = ({
        UIView *view = UIView.new;
        view.backgroundColor = XHQHexColor(0xEBEBEB);
        view;
    });
    _textField.inputView = _numberKeyboardView;
    [self addSubview:_titleLabel];
    [self addSubview:_textField];
    [self addSubview:_line];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(25);
        make.top.mas_equalTo(10);
    }];
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_titleLabel);
        make.top.equalTo(_titleLabel.mas_bottom).offset(25);
        make.trailing.mas_equalTo(-25);
        make.height.mas_equalTo(40);
    }];
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(_textField);
        make.bottom.equalTo(_textField.mas_bottom).offset(5);
        make.height.mas_equalTo(0.8);
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField.text containsString:@"."] && [string isEqualToString:@"."]) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidChanged:(UITextField *)textField {
    if ([textField.text containsString:@"."]) {
        NSArray <NSString *>*texts = [textField.text componentsSeparatedByString:@"."];
        NSString *firstString = [texts firstObject];
        NSString *lastString = [texts lastObject];
        if (lastString.length > 2) {
            [textField substringToIndex:firstString.length + 3];
        }
    }
    TransferObject *obj = (TransferObject *)self.item.cellModel;
    obj.amount = textField.text.doubleValue;
}

#pragma mark - EBNumberKeyboardViewDelegate
// 输入数字、小数点、负号
- (void)numberKeyboardViewEditing:(EBNumberKeyboardView *)keyboardView text:(NSString*)text {
    if ([text isEqualToString:kEBNumberKeyboardViewDotKey]) {
        if (self.textField.text.length == 0
            || [self.textField.text rangeOfString:kEBNumberKeyboardViewDotKey].location != NSNotFound) {
            return;
        }
    }
    [self.textField insertText:text];
}

// 点击完成输入
- (void)numberKeyboardViewEndEditing:(EBNumberKeyboardView *)keyboardView {
    !self.responseBlock ? : self.responseBlock();
}

// 删除字符
- (void)numberKeyboardViewDeleteText:(EBNumberKeyboardView *)keyboardView {
    [self.textField deleteBackward];
}

@end
