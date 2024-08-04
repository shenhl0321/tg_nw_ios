//
//  MNPopBaseCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/5.
//

#import "BaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNPopBaseCell : BaseTableCell
@property (nonatomic, strong) UIImageView *iconImgV;
@property (nonatomic, strong) UILabel *titleLabel;
@property (strong, nonatomic) UIView *lineV;

//首页右上角加号弹框 图片和icon
- (void)styleMessageAdd;

//聊天页消息编辑的样式
- (void)styleChatEdit;

//群组编辑页 投诉和退出群聊
- (void)styleGroupEdit;

@end

NS_ASSUME_NONNULL_END
