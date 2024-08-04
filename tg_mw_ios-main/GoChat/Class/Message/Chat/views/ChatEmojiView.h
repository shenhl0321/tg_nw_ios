//
//  ChatEmojiView.h
//  GoChat
//
//  Created by wangyutao on 2021/2/23.
//

#import <UIKit/UIKit.h>

@class ChatEmojiView;
@protocol ChatEmojiViewDelegate <NSObject>
@optional
- (void)ChatCollectEmojiView_Delete:(AnimationInfo *)collectModel;
- (void)ChatCollectEmojiView_Choose:(AnimationInfo *)collectModel;
- (void)ChatEmojiView_Choose:(ChatEmojiView *)view emoji:(NSString *)emoji;
- (void)ChatEmojiView_Send:(ChatEmojiView *)view;
@end

@interface ChatEmojiView : UIView
@property (nonatomic, weak) id<ChatEmojiViewDelegate> delegate;
@property (nonatomic, strong) NSArray *collectList;
@end
