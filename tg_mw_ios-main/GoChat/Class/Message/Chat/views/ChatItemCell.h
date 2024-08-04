//
//  ChatItemCell.h
//  GoChat
//
//  Created by wangyutao on 2020/12/17.
//

#import <UIKit/UIKit.h>

@interface ChatItemCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
- (void)resetChatInfo:(id)chat;
@end
