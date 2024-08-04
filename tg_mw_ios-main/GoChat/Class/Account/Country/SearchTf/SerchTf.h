//
//  SerchTf.h
//  iOSBaseTuya
//
//  Created by XMJ on 2020/8/10.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SerchTf;
@protocol SearchTfDelegate <NSObject>

- (void)searchTf:(SerchTf *)tfView didEndSearchWithText:(NSString *)text;//结束搜索
- (void)searchTf_didCancelSearch:(SerchTf *)tfView;//取消搜索
- (void)searchTf_valueChanged:(SerchTf *)tfView;
- (void)searchTf_textFieldDidBeginEditing:(SerchTf *)tfView;
- (void)searchTf_searchStateChanged:(BOOL)isSearching;
@end
@interface SerchTf : UIView
@property (nonatomic, strong) UIButton *searchBtn;
@property (nonatomic, strong) UITextField *searchTf;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, weak) id<SearchTfDelegate>delegate;
@property (assign, nonatomic) CGFloat cornerRadius;
/// 是否靠左，默认在中间
@property (assign, nonatomic) BOOL isLeft;

@property (nonatomic, assign) BOOL  isSearching;
@property (nonatomic, assign) BOOL noSearch;//不需要搜索，消息首页用

- (void)animationNoCancel;
- (void)animationHasCancel;
@end

