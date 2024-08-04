//
//  QTGroupHeadView02.h
//  BaseChat
//
//  Created by 漫漫人生路 on 2023/4/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QTGroupHeadView02 : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
/// 群成员
@property (weak, nonatomic) IBOutlet UIButton *tousuBtn;
/// 
@property (weak, nonatomic) IBOutlet UIButton *jsqzBtn;

/// 查找聊天记录
@property (weak, nonatomic) IBOutlet UIButton *ltjlBtn;

@end

NS_ASSUME_NONNULL_END
