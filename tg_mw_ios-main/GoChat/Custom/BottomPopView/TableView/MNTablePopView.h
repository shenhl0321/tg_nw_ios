//
//  MNTablePopView.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/5.
//

#import "BottomPopView.h"
#import "MNTablePopModel.h"
typedef NS_OPTIONS(NSInteger, MNTablePopViewType) {
    MNTablePopViewTypeMsgAdd,
    MNTablePopViewTypeChatEdit,
    MNTablePopViewTypeGroupEdit,
};
@class MNTablePopView;
typedef void(^PopViewChooseBlock)(MNTablePopView *popView,NSInteger index,MNTablePopModel *model);
NS_ASSUME_NONNULL_BEGIN

@interface MNTablePopView : BottomPopView

@property (nonatomic, assign) MNTablePopViewType type;

+ (MNTablePopView *)showTablePopViewWithType:(MNTablePopViewType)type
                          dataArray:(NSArray *)dataArray
                            chooseIndexBlock:(PopViewChooseBlock)chooseIndexBlock;

- (void)showTablePopViewWithType:(MNTablePopViewType)type
                          dataArray:(NSArray *)dataArray
                chooseIndexBlock:(PopViewChooseBlock)chooseIndexBlock;

+ (MNTablePopView *)showTablePopViewWithType:(MNTablePopViewType)type chooseIndexBlock:(PopViewChooseBlock)chooseIndexBlock;

@end

NS_ASSUME_NONNULL_END
