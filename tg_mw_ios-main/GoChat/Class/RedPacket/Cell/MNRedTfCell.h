//
//  MNRedTfCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/13.
//

#import "MNBaseRedCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNRedTfCell : MNBaseRedCell
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UITextField *tf;
@end

NS_ASSUME_NONNULL_END
