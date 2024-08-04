//
//  MNSubInfoVoiceCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/22.
//

#import "BaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNSubInfoVoiceCell : BaseTableCell
@property (nonatomic, strong) UIImageView *iconImgV;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *subLabel;
- (void)fillDataWithMessage:(MessageInfo *)message;
@end

NS_ASSUME_NONNULL_END
