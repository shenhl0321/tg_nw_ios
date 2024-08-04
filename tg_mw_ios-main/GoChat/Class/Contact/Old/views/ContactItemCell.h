//
//  ContactItemCell.h
//  GoChat
//
//  Created by wangyutao on 2020/11/24.
//

#import <UIKit/UIKit.h>

@interface ContactItemCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *chooseImageView;
@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIView *maskView;

- (void)resetUserInfo:(UserInfo *)user;
- (void)resetUserInfo:(UserInfo *)user isChoose:(BOOL)isChoose showMask:(BOOL)showMask;
@end
