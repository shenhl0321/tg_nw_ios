//
//  ContactSearchBar.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/4.
//

#import "ContactSearchBar.h"

@interface ContactSearchBar ()
<UITextFieldDelegate>
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *searchBtn;

@property (nonatomic, strong) UIButton *cancelBtn;
@end

@implementation ContactSearchBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.searchBtn];
    [self.contentView addSubview:self.searchTf];
    [self addSubview:self.cancelBtn];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left_margin());
        make.right.mas_equalTo(-62);
        make.height.mas_equalTo(42);
        make.centerY.mas_equalTo(0);
    }];
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.size.mas_equalTo(CGSizeMake(15, 15));
        make.centerY.mas_equalTo(0);
    }];
    [self.searchTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(35);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(42);
        make.centerY.mas_equalTo(0);
    }];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(62, 42));
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
}

- (void)styleHasCancel{
    self.cancelBtn.hidden = NO;
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left_margin());
        make.right.mas_equalTo(-62);
        make.height.mas_equalTo(42);
        make.centerY.mas_equalTo(0);
    }];
    [self.cancelBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(62, 42));
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
}

- (void)styleNoCancel{
    self.cancelBtn.hidden = YES;
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left_margin());
        make.right.mas_equalTo(-left_margin());
        make.height.mas_equalTo(42);
        make.centerY.mas_equalTo(0);
    }];
//    [self.cancelBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(62, 0));
//        make.right.mas_equalTo(0);
//        make.centerY.mas_equalTo(0);
//    }];
}

-(UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:@"取消".lv_localized forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = fontRegular(16);
        [_cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

-(UIButton *)searchBtn{
    if (!_searchBtn) {
        _searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_searchBtn setImage:[UIImage imageNamed:@"Search"] forState:UIControlStateNormal];
        _searchBtn.userInteractionEnabled = NO;
        
    }
    return _searchBtn;
}

- (void)setCornerRadius:(CGFloat)cornerRadius{
    _cornerRadius = cornerRadius;
    self.contentView.layer.cornerRadius = cornerRadius;
}
- (void)setBackColor:(UIColor *)backColor{
    _backColor = backColor;
    self.contentView.backgroundColor = backColor;
}
-(UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor colorForF5F9FA];
        _contentView.layer.cornerRadius = 13;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (UITextField *)searchTf{
    if (!_searchTf) {
        _searchTf = [[UITextField alloc] init];
        [_searchTf mn_defalutStyle];
        _searchTf.placeholder = @"搜索".lv_localized;
        _searchTf.returnKeyType = UIReturnKeySearch;
        [_searchTf addTarget:self action:@selector(searchTfValueChanged:) forControlEvents:UIControlEventEditingChanged];
        _searchTf.delegate = self;
    }
    return _searchTf;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
//    [self styleHasCancel];
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:textFieldDidBeginEditing:)]) {
        [self.delegate searchBar:self textFieldDidBeginEditing:textField];
    }
}

- (void)cancelAction{
//    [self styleNoCancel];
   
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:touchUpInsideCancelBtn:)]) {
        [self.delegate searchBar:self touchUpInsideCancelBtn:self.cancelBtn];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.text.length == 0) {
        return NO;
    }
    [textField resignFirstResponder];
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:textFieldShouldReturn:)]) {
        [self.delegate searchBar:self textFieldShouldReturn:textField];
    }
    return YES;
}


-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:textFieldDidEndEditing:)]) {
        [self.delegate searchBar:self textFieldDidEndEditing:textField];
    }
}

- (void)searchTfValueChanged:(UITextField *)textField{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:textFieldValueChanged:)]) {
        [self.delegate searchBar:self textFieldValueChanged:textField];
    }
}
@end
