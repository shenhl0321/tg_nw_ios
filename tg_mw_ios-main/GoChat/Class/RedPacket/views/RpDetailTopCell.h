//
//  RpDetailTopCell.h
//  GoChat
//
//  Created by wangyutao on 2021/4/9.
//

#import <UIKit/UIKit.h>

@interface RpDetailTopCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *title1Label;
@property (nonatomic, weak) IBOutlet UILabel *title2Label;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
- (void)resetRpInfo:(RedPacketInfo *)rp;
@end
