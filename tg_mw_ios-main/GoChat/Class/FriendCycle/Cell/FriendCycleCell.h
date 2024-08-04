//
//  FriendCycleCell.h
//  GoChat
//
//  Created by 吴亮 on 2021/10/2.
//

#import <UIKit/UIKit.h>
#import "BlogInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface FriendCycleCell : UITableViewCell

@property (nonatomic, strong) UIButton * moreBtn;
-(void)setModel:(NSDictionary *)dic;

@property (nonatomic, strong) BlogInfo *blog;

@end

NS_ASSUME_NONNULL_END
