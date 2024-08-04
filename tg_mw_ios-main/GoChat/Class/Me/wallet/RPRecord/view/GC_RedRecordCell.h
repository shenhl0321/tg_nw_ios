//
//  GC_RedRecordCell.h
//  GoChat
//
//  Created by wangfeiPro on 2022/1/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GC_RedRecordCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet UILabel *desLabel;
@property (nonatomic, weak) IBOutlet UIView *bestView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;

- (void)resetRpInfo:(RedPacketInfo *)rp isSendRp:(BOOL)isSendRp;

@end

NS_ASSUME_NONNULL_END
