//
//  GroupRestrictedItemCell.h
//  GoChat
//
//  Created by wangyutao on 2020/12/17.
//

#import <UIKit/UIKit.h>

@interface GroupRestrictedItemCell : SWTableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
- (void)resetInfo:(UserInfo *)user;
@end
