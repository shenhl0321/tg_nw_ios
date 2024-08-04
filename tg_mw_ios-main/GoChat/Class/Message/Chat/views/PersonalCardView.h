//
//  PersonalCardView.h
//  GoChat
//
//  Created by mac on 2021/9/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PersonalCardView : UIView

@property (nonatomic, copy) void (^personalCardCancelBlock)(UIButton *sender);
@property (nonatomic, copy) void (^personalCardSendBlock)(UIButton *sender);
- (void)resetChatInfo:(id)chat sendChatInfo:(ChatInfo *)sendChatInfo;

@end

NS_ASSUME_NONNULL_END
