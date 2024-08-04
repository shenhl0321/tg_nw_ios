//
//  RpDetailUserCell.h
//  GoChat
//
//  Created by wangyutao on 2021/4/9.
//

#import <UIKit/UIKit.h>

@interface RpDetailUserCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet UIView *bestView;
- (void)resetUserInfo:(RedPacketPickUser *)gotUser isBest:(BOOL)isBest;
@end
