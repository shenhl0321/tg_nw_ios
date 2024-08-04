//
//  QTGroupHeadView03.h
//  BaseChat
//
//  Created by 漫漫人生路 on 2023/4/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^QTGroupHeadClickBlock)(NSInteger index);
@interface QTGroupHeadView03 : UIView

@property (weak, nonatomic) IBOutlet UIButton *nickNameBtn;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLab;
@property (weak, nonatomic) IBOutlet UIButton *tongzhiBtn;

@property (strong, nonatomic) QTGroupHeadClickBlock chooseBlock;

@end

NS_ASSUME_NONNULL_END
