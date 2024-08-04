//
//  MNGroupAnnounceHeaderView.h
//  GoChat
//
//  Created by 许蒙静 on 2022/1/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNGroupAnnounceHeaderView : UIView
@property (nonatomic, strong) UIImageView *iconImgV;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *closeBtn;
-(void)refreshDataWithChat:(ChatInfo *)chat pinnedMessage:(MessageInfo *)pinnedMessage superGroup:(SuperGroupInfo *)superGroup;

@property (nonatomic, copy) dispatch_block_t closeBlock;

@end

NS_ASSUME_NONNULL_END
