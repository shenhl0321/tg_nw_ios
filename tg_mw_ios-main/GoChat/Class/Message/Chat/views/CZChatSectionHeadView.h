//
//  CZChatSectionHeadView.h
//  GoChat
//
//  Created by mac on 2021/7/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZChatSectionHeadView : UIView

@property (nonatomic,assign) BOOL is_black;
- (void)bindClickEventWithfirBtn:(dispatch_block_t)blackBlock withAddFriendBtn:(dispatch_block_t)addBlock;

@end

NS_ASSUME_NONNULL_END
