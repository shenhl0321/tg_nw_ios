//
//  MNLongPressChatPopView.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/5.
//

#import "BottomPopView.h"

@class MNLongPressChatPopView;
typedef void(^PopViewTouchBtnBlock)(MNLongPressChatPopView *popView,UIButton *btn);
NS_ASSUME_NONNULL_BEGIN

@interface MNLongPressChatPopView : BottomPopView
+ (MNLongPressChatPopView *)showWithChat:(ChatInfo *)chat;
@property (nonatomic, copy) PopViewTouchBtnBlock touchBtnBlock;
@property (nonatomic, weak) id<CommonDelegate>delegate;

+ (MNLongPressChatPopView *)showWithChat:(ChatInfo *)chat touchBtnBlock:(PopViewTouchBtnBlock)touchBtnBlock;
//- (void)refreshUI;
@end

NS_ASSUME_NONNULL_END
