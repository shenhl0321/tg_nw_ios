//
//  MessageADButtonsView.h
//  GoChat
//
//  Created by Autumn on 2022/1/21.
//

#import "DYView.h"


NS_ASSUME_NONNULL_BEGIN
@class ChatMsgInlineKeyboardButton;
@interface MessageADButtonsView : DYView

@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *rows;
@property (nonatomic, strong) UIColor *cellBgColor;

@property (nonatomic, assign, readonly) CGFloat vHeight;

/// 父视图计算好当前视图的 `frame` 后调用，
/// 用于计算 `cell` 的宽度和刷新 `collectionView`
- (void)reloadData;

@end

@interface MessageADButtonCell : DYCollectionViewCell

@property (nonatomic, strong) ChatMsgInlineKeyboardButton *buttonItem;

@end

NS_ASSUME_NONNULL_END
