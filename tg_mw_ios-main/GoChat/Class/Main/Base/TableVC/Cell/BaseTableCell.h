//
//  BaseTableCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/11/25.
//

#import "MGSwipeTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseTableCell : MGSwipeTableCell

- (void)initUI;

- (void)initSubUI;

@property (nonatomic, assign) BOOL needLine;
@property (nonatomic, strong) UIView *lineView;
@end

NS_ASSUME_NONNULL_END
