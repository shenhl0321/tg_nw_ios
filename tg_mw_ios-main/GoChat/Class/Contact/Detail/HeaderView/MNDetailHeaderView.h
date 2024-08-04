//
//  MNDetailHeaderView.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNDetailHeaderView : UIView
@property (nonatomic, strong) UIImageView *iconImgV;
@property (nonatomic, strong) UILabel *nameLabel;
/// 发消息
@property (nonatomic, strong) UIButton *sendMsgBtn;
/// 语音通话
@property (nonatomic, strong) UIButton *voiceBtn;
/// 视频通话
@property (nonatomic, strong) UIButton *videoBtn;
/// 静音
@property (nonatomic, strong) UIButton *muteBtn;
/// 更多
@property (nonatomic, strong) UIButton *moreBtn;
/// 发起群聊
@property (nonatomic, strong) UIButton *qunliaoBtn;
/// 聊天内容
@property (nonatomic, strong) UIButton *ltnrBtn;
/// 聊天背景
@property (nonatomic, strong) UIButton *ltbjBtn;
/// 推荐给好友
@property (nonatomic, strong) UIButton *tjghyBtn;
/// 开启私密聊天
@property (nonatomic, strong) UIButton *kqsmltBtn;
/// 投诉
@property (nonatomic, strong) UIButton *tousuBtn;
/// 查找收发的图片
@property (nonatomic, strong) UIButton *shoufatupianBtn;


/// avatarBtn
@property (nonatomic, strong) UIButton *avatarBtn;
/// nicknameBtn
@property (nonatomic, strong) UIButton *nicknameBtn;


@property (nonatomic, copy) BtnBlock clickBtnBlock;
- (void)refreshUIWithUserInfo:(UserInfo *)userInfo orgUserInfo:(OrgUserInfo *)orgUserInfo;
@end

NS_ASSUME_NONNULL_END
