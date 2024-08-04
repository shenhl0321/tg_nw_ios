//
//  MNContactDetailBtnCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/15.
//

#import "BaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNContactDetailBtnCell : BaseTableCell
@property (nonatomic, strong) UIButton *topBtn;
@property (nonatomic, strong) UIButton *bottomBtn;
@property (nonatomic, copy) BtnBlock clickBtnBlock;
- (void)fillDataWithUser:(UserInfo *)user chat:(ChatInfo *)chat;
@end

NS_ASSUME_NONNULL_END
