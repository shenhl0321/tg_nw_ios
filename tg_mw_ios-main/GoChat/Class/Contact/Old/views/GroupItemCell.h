//
//  GroupItemCell.h
//  GoChat
//
//  Created by wangyutao on 2020/12/17.
//

#import <UIKit/UIKit.h>

@interface GroupItemCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
- (void)resetGroupInfo:(ChatInfo *)chat;
@end
