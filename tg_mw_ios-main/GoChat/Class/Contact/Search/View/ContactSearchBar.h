//
//  ContactSearchBar.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/4.
//

#import <UIKit/UIKit.h>

@class ContactSearchBar;
@protocol MNContactSearchBarDelegate <NSObject>
@optional
- (void)searchBar:(ContactSearchBar *)bar touchUpInsideCancelBtn:(UIButton *)cancel;
- (void)searchBar:(ContactSearchBar *)bar textFieldDidBeginEditing:(UITextField *)textField;
- (void)searchBar:(ContactSearchBar *)bar textFieldShouldReturn:(UITextField *)textField;
- (void)searchBar:(ContactSearchBar *)bar textFieldDidEndEditing:(UITextField *)textField;
- (void)searchBar:(ContactSearchBar *)bar textFieldValueChanged:(UITextField *)textField;

@end
NS_ASSUME_NONNULL_BEGIN

@interface ContactSearchBar : UIView

@property (nonatomic, strong) UITextField *searchTf;

@property (assign, nonatomic) CGFloat cornerRadius;

@property (assign, nonatomic) UIColor *backColor;

@property (nonatomic, assign) BOOL interHandle;//需要内部处理

@property (nonatomic, weak) id<MNContactSearchBarDelegate>delegate;
- (void)styleHasCancel;

- (void)styleNoCancel;
@end

NS_ASSUME_NONNULL_END
