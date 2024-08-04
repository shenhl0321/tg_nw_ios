//
//  QTGroupHeadView01.h
//  BaseChat
//
//  Created by 漫漫人生路 on 2023/4/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^QTGroupHeadClickBlock)(NSInteger index);
@interface QTGroupHeadView01 : UIView

/// 群成员
@property (weak, nonatomic) IBOutlet UIButton *qcyBtn;
/// 通知
@property (weak, nonatomic) IBOutlet UIButton *tongzhiBtn;

@property (assign, nonatomic) NSInteger personNum;
@property (strong, nonatomic) NSArray *dataArr;

@property (strong, nonatomic) QTGroupHeadClickBlock chooseBlock;

@end

NS_ASSUME_NONNULL_END
