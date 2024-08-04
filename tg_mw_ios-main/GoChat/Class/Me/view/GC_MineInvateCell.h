//
//  GC_MineInvateCell.h
//  GoChat
//
//  Created by wangfeiPro on 2021/12/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GC_MineInvateCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *inviteView;
@property (weak, nonatomic) IBOutlet UIView *contentV;
@property (weak, nonatomic) IBOutlet UIImageView *inviteImageV;

@property (weak, nonatomic) IBOutlet UILabel *inviteLab;
@property (weak, nonatomic) IBOutlet UIView *nearView;
@property (weak, nonatomic) IBOutlet UIImageView *nearImageV;
@property (weak, nonatomic) IBOutlet UILabel *nearLab;

@property (weak, nonatomic) IBOutlet UIView *groupView;
@property (weak, nonatomic) IBOutlet UIImageView *groupImageV;
@property (weak, nonatomic) IBOutlet UILabel *groupLab;

@property (nonatomic, copy)  void(^menuBlock)(NSInteger tag);
@end

NS_ASSUME_NONNULL_END
