//
//  LocationSearchView.h
//  GoChat
//
//  Created by 李标 on 2021/6/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SearchViewDelegate <NSObject>
// 取消搜索
//- (void)SearchViewCancel;
// 关键词搜索
- (void)SearchViewDoSearch:(NSString *)result;
// 开始输入
- (void)TextFieldBeginEditing:(UITextField *)textField;
@end

@interface LocationSearchView : UIView

@property (nonatomic, assign) id<SearchViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
