//
//  RecentCallsCell.h
//  GoChat
//
//  Created by 李标 on 2021/5/22.
//  最近通话 呼入和呼出

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecentCallsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbSubTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UILabel *lbDuration;
@end

NS_ASSUME_NONNULL_END
