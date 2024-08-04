//
//  GC_MineMenuCell.h
//  GoChat
//
//  Created by wangfeiPro on 2021/12/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GC_MineMenuCell : UITableViewCell

@property (nonatomic, copy)  void(^menuBlock)(NSInteger tag);

@property (nonatomic, strong)UIView *contentV;

@end

NS_ASSUME_NONNULL_END
