//
//  EmojiContainer.h
//  GoChat
//
//  Created by Autumn on 2021/11/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EmojiContainer;
@protocol EmojiContainerDelegate <NSObject>


- (void)emojiContainer_Choose:(EmojiContainer *)view emoji:(NSString *)emoji;

- (void)emojiContainer_Delete:(EmojiContainer *)view;

- (void)emojiContainer_Send:(EmojiContainer *)view;

@end

@interface EmojiContainer : UIView

+ (instancetype)loadFromNib;

@property (nonatomic, weak) id<EmojiContainerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
