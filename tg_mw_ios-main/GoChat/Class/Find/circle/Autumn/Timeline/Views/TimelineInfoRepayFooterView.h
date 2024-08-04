//
//  TimelineInfoRepayFooterView.h
//  GoChat
//
//  Created by Autumn on 2021/11/20.
//

#import <UIKit/UIKit.h>
#import "TimelineHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimelineInfoRepayFooterView : UITableViewHeaderFooterView

@property (nonatomic, assign) RepayListDisplayMode displayMode;

/// 当前 section 显示的 cell 个数
@property (nonatomic, assign) NSInteger currentDisplayNumber;

/// 当前 section 全部的 cell 个数
@property (nonatomic, assign) NSInteger totalDisplayNumber;

@property (nonatomic, copy) dispatch_block_t moreBlock;

@end

NS_ASSUME_NONNULL_END
