//
//  SerchTf.m
//  iOSBaseTuya
//
//  Created by XMJ on 2020/8/10.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//

#import "SerchTf.h"
#import "UITextField+Style.h"
#import "UIButton+ClickRange.h"

@interface SerchTf ()<UITextFieldDelegate>
@property (nonatomic, strong) UIView *contentView;

@end
@implementation SerchTf

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

//-(void)setFrame:(CGRect)frame{
//    [super frame];
//}
- (void)setCornerRadius:(CGFloat)cornerRadius{
    _cornerRadius = cornerRadius;
    self.contentView.layer.cornerRadius = cornerRadius;
}
- (void)setIsLeft:(BOOL)isLeft{
    _isLeft = isLeft;

    [self.searchBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(-SCREEN_WIDTH/2 + left_margin() + 20);
    }];
    
    self.searchTf.textAlignment = NSTextAlignmentLeft;
}
- (void)initUI{
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(left_margin(), 0, APP_SCREEN_WIDTH-2*left_margin(), 42)];
    _contentView.layer.cornerRadius = 13;
    _contentView.layer.masksToBounds = YES;
    _contentView.backgroundColor = [UIColor colorForF5F9FA];
    [self addSubview:_contentView];
    

    MJWeakSelf
    if (!_searchTf) {
        _searchTf = [[UITextField alloc] init];
        _searchTf.delegate = self;
        [_searchTf mn_defalutStyle];
        [_searchTf addTarget:self action:@selector(searchTfValueChanged:) forControlEvents:UIControlEventEditingChanged];
        _searchTf.returnKeyType = UIReturnKeySearch;
       
        _searchTf.placeholder = LocalString(localSearch);
        [_contentView addSubview:_searchTf];
        [self.searchTf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(32);
            make.centerY.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.right.mas_equalTo(-15);
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneA:) name:@"doneAction" object:nil];
    }
    if (!_searchBtn) {
        _searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _searchBtn.frame = CGRectMake(0, 0, 12+24, 42);
        [_searchBtn setImage:[UIImage imageNamed:@"Search"] forState:UIControlStateNormal];
        [_searchBtn setImage:[UIImage imageNamed:@"Search"] forState:UIControlStateDisabled];
        [_searchBtn addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
        _searchBtn.enabled = NO;
        [_contentView addSubview:_searchBtn];
        [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(-30);
            make.size.mas_equalTo(CGSizeMake(15, 15));
            if (weakSelf.isLeft){
                make.centerX.mas_equalTo(-SCREEN_WIDTH/2 + left_margin() + 20);
            }else{
                make.centerY.mas_equalTo(0);
            }
        }];
        [self.searchBtn setEnlargeEdgeWithTop:10 right:4 bottom:10 left:10];
        
    }
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:LocalString(localCancel) forState:UIControlStateNormal];
        _cancelBtn.frame = CGRectMake(APP_SCREEN_WIDTH-64, 0, 64, 42);
        [_cancelBtn setTitleColor:[UIColor colorTextFor0DBFC0] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = fontRegular(17);
        _cancelBtn.hidden = YES;
        [self addSubview:_cancelBtn];
       
        [_cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    [self animationNoCancel];
}

- (void)searchAction:(UIButton *)btn{
    [self.searchTf resignFirstResponder];
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchTf:didEndSearchWithText:)]) {
        [self.delegate performSelector:@selector(searchTf:didEndSearchWithText:) withObject:self withObject:self.searchTf.text];
    }
}

- (void)cancelAction{
    [self.searchTf resignFirstResponder];
    self.searchTf.text = @"";
    self.searchBtn.enabled = NO;
    self.isSearching = NO;
    [self animationNoCancel];
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchTf_didCancelSearch:)]) {
        [self.delegate searchTf_didCancelSearch:self];
    }
}

- (void)animationHasCancel{
    MJWeakSelf
    self.contentView.frame = CGRectMake(left_margin(), 0, APP_SCREEN_WIDTH-left_margin()-64, 42);
    [self.searchBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.size.mas_equalTo(CGSizeMake(15, 15));
        if (weakSelf.isLeft){
            make.centerX.mas_equalTo(-SCREEN_WIDTH/2 + left_margin() + 20);
        }else{
            make.centerY.mas_equalTo(0);
        }
    }];
    self.searchTf.textAlignment = NSTextAlignmentLeft;
//    [self.searchTf mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(35);
//        make.right.mas_equalTo(-left_margin());
//        make.centerY.mas_equalTo(0);
//        make.height.mas_equalTo(40);
//    }];
    self.cancelBtn.hidden = NO;
}

- (void)animationNoCancel{
    MJWeakSelf
    self.contentView.frame = CGRectMake(left_margin(), 0, APP_SCREEN_WIDTH-2*left_margin(), 42);
    [self.searchBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(-30);
        make.size.mas_equalTo(CGSizeMake(15, 15));
        if (weakSelf.isLeft){
            make.centerX.mas_equalTo(-SCREEN_WIDTH/2 + left_margin() + 20);
        }else{
            make.centerY.mas_equalTo(0);
        }
    }];
    if (self.isLeft == YES){
        self.searchTf.textAlignment = NSTextAlignmentLeft;
    }else{
        self.searchTf.textAlignment = NSTextAlignmentCenter;
    }
    
    self.cancelBtn.hidden = YES;
}

- (void)searchTfValueChanged:(UITextField *)textField{
//    NSLog(@"valueChanged ---- %@",textField.text);
    if (textField.text.length) {
        self.searchBtn.enabled = YES;
    }else{
        self.searchBtn.enabled = NO;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchTf_valueChanged:)]) {
        [self.delegate searchTf_valueChanged:self];
    }
}

//-(void)textFieldDidBeginEditing:(UITextField *)textField{
////    [self animationDidSearch];
//}
//-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
//    NSLog(@"textFieldShouldEndEditing --- %@",textField.text);
//    return YES;
//}
-(void)setIsSearching:(BOOL)isSearching{
    _isSearching = isSearching;
    if (self.noSearch == YES) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchTf_searchStateChanged:)]) {
        [self.delegate searchTf_searchStateChanged:isSearching];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
//    NSLog(@"textFieldShouldReturn ---- %@",textField.text);
    if (textField.text.length == 0) {
        return NO;
    }
    self.isSearching = NO;
    [self animationNoCancel];
    [textField resignFirstResponder];
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchTf:didEndSearchWithText:)]) {
        [self.delegate performSelector:@selector(searchTf:didEndSearchWithText:) withObject:self withObject:self.searchTf.text];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (self.noSearch) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(searchTf_textFieldDidBeginEditing:)]) {
            [self.delegate performSelector:@selector(searchTf_textFieldDidBeginEditing:) withObject:self];
        }
        [textField resignFirstResponder];
        return;
    }else{
        self.isSearching = YES;
        [self animationHasCancel];
        if (self.delegate && [self.delegate respondsToSelector:@selector(searchTf_textFieldDidBeginEditing:)]) {
            [self.delegate performSelector:@selector(searchTf_textFieldDidBeginEditing:) withObject:self];
        }
    }
    
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
//    NSLog(@"textFieldDidEndEditing ---- %@",textField.text);
//    if (self.noNeedCancelBtn==NO) {//
//        [self animationHasCancel];
//    }
    
//      [self animationCancelSearch];
    //在这个里面调用一下方法就好了
    self.isSearching = NO;
    [self animationNoCancel];
   
}


- (void)doneA:(NSNotification *)noti{
    if (self.searchTf.text.length == 0) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchTf:didEndSearchWithText:)]) {
        [self.delegate performSelector:@selector(searchTf:didEndSearchWithText:) withObject:self withObject:self.searchTf.text];
    }
}

@end
