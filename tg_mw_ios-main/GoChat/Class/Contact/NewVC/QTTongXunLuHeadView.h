//
//  QTTongXunLuHeadView.h
//  BaseChat
//
//  Created by 漫漫人生路 on 2023/3/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^QTXuanFuViewClickBlock)(NSInteger chooseIndex);
@interface QTTongXunLuHeadView : UIView

@property (strong, nonatomic) QTXuanFuViewClickBlock chooseBlock;

@end

NS_ASSUME_NONNULL_END
