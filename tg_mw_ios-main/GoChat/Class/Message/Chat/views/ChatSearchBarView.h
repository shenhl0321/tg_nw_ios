//
//  ChatSearchBarView.h
//  GoChat
//
//  Created by wangyutao on 2021/1/18.
//

#import <UIKit/UIKit.h>

@class ChatSearchBarView;
@protocol ChatSearchBarViewDelegate <NSObject>
@optional
- (void)ChatSearchBarView_Search:(ChatSearchBarView *)view;
- (void)ChatSearchBarView_Scan:(ChatSearchBarView *)view;
@end

@interface ChatSearchBarView : UIView
@property (nonatomic, weak) id<ChatSearchBarViewDelegate> delegate;
@end
